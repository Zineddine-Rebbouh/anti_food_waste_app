import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:anti_food_waste_app/core/navigation/app_router.dart';
import 'package:anti_food_waste_app/core/network/api_client.dart';
import 'package:anti_food_waste_app/core/services/preferences_service.dart';
import 'package:anti_food_waste_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PushNotificationService {
  PushNotificationService._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'tawfir_main',
    'Tawfir Notifications',
    description: 'Notifications from Tawfir',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initializeLocalNotifications();
    await _requestPermission();
    await registerDeviceToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      registerDeviceToken();
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  static Future<void> registerDeviceToken() async {
    if (kIsWeb) return;

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await ApiClient.dio.post(
        'devices/register/',
        data: {
          'registration_id': token,
          'device_type': _deviceType,
          'device_id': await _deviceId(),
          'app_version': '',
        },
      );
    } catch (e) {
      debugPrint('Push token registration skipped: $e');
    }
  }

  static Future<void> unregisterDeviceToken() async {
    if (kIsWeb) return;

    try {
      await ApiClient.dio.delete(
        'devices/unregister/',
        data: {'device_id': await _deviceId()},
      );
    } catch (e) {
      debugPrint('Push token unregister skipped: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _navigateFromData({'screen': payload});
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tawfir_main',
          'Tawfir Notifications',
          channelDescription: 'Notifications from Tawfir',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF2D8659),
        ),
        iOS: DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: message.data['screen']?.toString(),
    );
  }

  static void _handleMessageTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final screen = data['screen']?.toString();
    final route = switch (screen) {
      'notifications' => AppRoutes.notifications,
      'home' || 'listing_detail' => AppRoutes.consumer,
      'dashboard' || 'merchant_dashboard' || 'analytics' => AppRoutes.merchant,
      'charity_dashboard' || 'donation_detail' => AppRoutes.charity,
      'support' => AppRoutes.help,
      'eco_score' => AppRoutes.impactDashboard,
      _ => AppRoutes.notifications,
    };

    navigator.pushNamed(route);
  }

  static String get _deviceType {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'web',
    };
  }

  static Future<String> _deviceId() async {
    final existing = PreferencesService.getPushDeviceId();
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await PreferencesService.setPushDeviceId(id);
    return id;
  }
}
