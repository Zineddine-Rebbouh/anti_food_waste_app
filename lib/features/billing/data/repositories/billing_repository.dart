import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';
import 'package:anti_food_waste_app/features/billing/domain/models/billing_models.dart';

class BillingRepository {
  final Dio _dio;

  BillingRepository({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Fetch all active subscription plans.
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final response = await _dio.get('billing/plans/');
    final data = response.data;
    final list = _extractResults(data);
    return list.map((json) => SubscriptionPlan.fromJson(json)).toList();
  }

  /// Fetch the current logged-in merchant's subscription.
  Future<MerchantSubscription> fetchMySubscription() async {
    final response = await _dio.get('billing/subscriptions/me/');
    return MerchantSubscription.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch the payment history for this merchant.
  Future<List<SubscriptionPayment>> fetchMyPayments() async {
    final response = await _dio.get('billing/payments/');
    final list = _extractResults(response.data);
    return list.map((json) => SubscriptionPayment.fromJson(json)).toList();
  }

  /// Request a subscription upgrade or renewal by posting a pending payment.
  Future<SubscriptionPayment> createPaymentRequest({
    required int planId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String paymentMethod,
    required String referenceNumber,
    String notes = '',
  }) async {
    final payload = {
      'plan_id': planId,
      'period_start': periodStart.toIso8601String().substring(0, 10),
      'period_end': periodEnd.toIso8601String().substring(0, 10),
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'notes': notes,
    };
    final response = await _dio.post('billing/payments/', data: payload);
    return SubscriptionPayment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch the commission ledger entries.
  Future<List<CommissionLedger>> fetchMyCommissions() async {
    final response = await _dio.get('billing/commissions/');
    final list = _extractResults(response.data);
    return list.map((json) => CommissionLedger.fromJson(json)).toList();
  }

  /// Fetch the active/expired sponsored slots purchased by the merchant.
  Future<List<SponsoredSlot>> fetchMySponsoredSlots() async {
    final response = await _dio.get('billing/sponsored-slots/');
    final list = _extractResults(response.data);
    return list.map((json) => SponsoredSlot.fromJson(json)).toList();
  }

  /// Fetch current listing sponsorships for the merchant.
  Future<List<SponsoredListing>> fetchMySponsoredListings() async {
    final response = await _dio.get('billing/sponsored-listings/');
    final list = _extractResults(response.data);
    return list.map((json) => SponsoredListing.fromJson(json)).toList();
  }

  /// Sponsor a listing using an available slot from a sponsored slot package.
  Future<SponsoredListing> createSponsoredListing({
    required String slotId,
    required String listingId,
  }) async {
    final payload = {
      'slot': slotId,
      'listing': listingId,
    };
    final response = await _dio.post('billing/sponsored-listings/', data: payload);
    return SponsoredListing.fromJson(response.data as Map<String, dynamic>);
  }

  /// Cancel/Remove a sponsored listing allocation.
  Future<void> cancelSponsoredListing(String id) async {
    await _dio.delete('billing/sponsored-listings/$id/');
  }

  /// Normalises lists and cursor-paginated objects.
  List<Map<String, dynamic>> _extractResults(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map) {
      final results = data['results'];
      if (results is List) return results.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
