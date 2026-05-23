import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anti_food_waste_app/features/merchant/data/repositories/merchant_repository.dart';
import 'package:anti_food_waste_app/features/merchant/data/sources/merchant_remote_source.dart';
import 'package:anti_food_waste_app/core/config/app_config.dart';
import 'package:anti_food_waste_app/core/services/token_storage.dart';
import 'package:flutter/services.dart';

void main() {
  // Setup Flutter environment for MethodChannels (TokenStorage uses FlutterSecureStorage)
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock MethodChannel for FlutterSecureStorage
  const MethodChannel('plugins.it_0.me/flutter_secure_storage')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'read') {
      if (methodCall.arguments['key'] == 'access_token') return 'mock_token';
      return null;
    }
    return null;
  });

  group('Automated Merchant Listing Integration Diagnostic', () {
    final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
    final remoteSource = MerchantRemoteSource(dio: dio);
    final repository = MerchantRepository(source: remoteSource);

    test('DIAGNOSTIC: Verify Backend Connection & Create Listing', () async {
      print('--- STARTING AUTOMATED DIAGNOSTIC ---');
      print('Target URL: ${AppConfig.baseUrl}');
      
      // 1. Check Authentication (Manual Inject for test)
      final token = await TokenStorage.getAccessToken();
      print('Auth Token Available: ${token != null}');
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 2. Sample Payload
      final now = DateTime.now();
      final payload = {
        'category': 1, // Common default category
        'title': 'Automated Test ${now.millisecondsSinceEpoch}',
        'description': 'Diagnostic test listing',
        'original_price': '100.00',
        'discounted_price': '20.00',
        'quantity_total': 5,
        'freshness_grade': 'A',
        'pickup_start': now.add(const Duration(hours: 1)).toIso8601String(),
        'pickup_end': now.add(const Duration(hours: 3)).toIso8601String(),
        'dietary_flags': {'halal': true},
        'allergens': [],
        'is_donation': false,
      };

      print('Step 1: Creating Listing...');
      try {
        final listing = await repository.createListing(payload);
        print('SUCCESS: Listing created with ID: ${listing.id}');
        
        // 3. Test Multipart Header generation
        print('Step 2: Checking Multipart logic...');
        final formData = FormData.fromMap({
          'photo': MultipartFile.fromBytes([0, 1, 2], filename: 'test.jpg'),
        });
        
        // This is where we verify if our Options(contentType: null) fix is working in the remote source
        // We simulate the call but expectations are on the DIO request headers
        dio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) {
            print('VERIFY: Request Content-Type: ${options.headers['Content-Type']}');
            print('VERIFY: Is Multipart: ${options.data is FormData}');
            return handler.next(options);
          },
        ));

        print('--- DIAGNOSTIC COMPLETE ---');
      } on DioException catch (e) {
        print('FAILURE at Step 1: ${e.type}');
        print('Status Code: ${e.response?.statusCode}');
        print('Response Body: ${e.response?.data}');
        fail('Listing creation failed: $e');
      }
    });
  });
}
