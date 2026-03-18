// Safely parse a value that Django may return as String or num.
double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

int _toInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

class MerchantDailyStats {
  final int ordersToday;
  final int ordersDelta;
  final double revenueToday;
  final double netRevenueToday;
  final double foodSavedKgToday;
  final double co2AvoidedKgToday;

  const MerchantDailyStats({
    required this.ordersToday,
    required this.ordersDelta,
    required this.revenueToday,
    required this.netRevenueToday,
    required this.foodSavedKgToday,
    required this.co2AvoidedKgToday,
  });

  /// Builds daily stats from GET /analytics/merchant/?period=1 response.
  factory MerchantDailyStats.fromAnalyticsJson(Map<String, dynamic> json) {
    final orders = _toInt(json['total_orders']);
    final revenue = _toDouble(json['total_revenue']);
    final foodSaved = orders * 0.5; // ~0.5 kg per order (estimate)
    return MerchantDailyStats(
      ordersToday: orders,
      ordersDelta: 0,
      revenueToday: revenue,
      netRevenueToday: revenue * 0.88,
      foodSavedKgToday: foodSaved,
      co2AvoidedKgToday: foodSaved * 4.0,
    );
  }
}

class MerchantPeriodStats {
  final int orders;
  final double revenue;
  final double foodSavedKg;
  final String period;

  const MerchantPeriodStats({
    required this.orders,
    required this.revenue,
    required this.foodSavedKg,
    required this.period,
  });

  /// Builds period stats from GET /analytics/merchant/?period=N response.
  factory MerchantPeriodStats.fromAnalyticsJson(
    Map<String, dynamic> json,
    String period,
  ) {
    final orders = _toInt(json['total_orders']);
    return MerchantPeriodStats(
      orders: orders,
      revenue: _toDouble(json['total_revenue']),
      foodSavedKg: orders * 0.5,
      period: period,
    );
  }
}

class MerchantProfile {
  final String id;
  final String businessName;
  final String businessType;
  final String avatarUrl;
  final double trustScore;
  final String phone;
  final String address;
  final String wilaya;
  final double? latitude;
  final double? longitude;
  final MerchantDailyStats dailyStats;
  final MerchantPeriodStats weeklyStats;
  final MerchantPeriodStats monthlyStats;
  final MerchantPeriodStats allTimeStats;

  const MerchantProfile({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.avatarUrl,
    required this.trustScore,
    required this.phone,
    required this.address,
    required this.wilaya,
    this.latitude,
    this.longitude,
    required this.dailyStats,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.allTimeStats,
  });

  // ── JSON deserialization ─────────────────────────────────────────────────

  /// Constructs a full [MerchantProfile] from three parallel API responses:
  /// - [userMeJson]       → GET /users/me/
  /// - [dailyAnalytics]   → GET /analytics/merchant/?period=1
  /// - [weeklyAnalytics]  → GET /analytics/merchant/?period=7
  /// - [monthlyAnalytics] → GET /analytics/merchant/?period=30
  factory MerchantProfile.fromApiJson({
    required Map<String, dynamic> userMeJson,
    required Map<String, dynamic> dailyAnalytics,
    required Map<String, dynamic> weeklyAnalytics,
    required Map<String, dynamic> monthlyAnalytics,
  }) {
    final profile = (userMeJson['profile'] as Map<String, dynamic>?) ?? {};
    final allTimeOrders = _toInt(profile['total_orders_fulfilled']);
    final allTimeFoodKg =
        _toDouble(profile['food_saved_kg'], allTimeOrders * 0.5);

    return MerchantProfile(
      id: profile['id']?.toString() ?? userMeJson['id'] as String? ?? '',
      businessName: profile['business_name'] as String? ?? '',
      businessType: profile['business_type'] as String? ?? '',
      avatarUrl: profile['logo_url'] as String? ??
          userMeJson['avatar_url'] as String? ??
          '',
      trustScore: _toDouble(profile['trust_score']),
      phone: profile['phone'] as String? ??
          userMeJson['phone'] as String? ??
          '',
      address: profile['address'] as String? ?? '',
      wilaya: profile['wilaya'] as String? ?? '',
      latitude: _toDoubleOrNull(profile['latitude']),
      longitude: _toDoubleOrNull(profile['longitude']),
      dailyStats: MerchantDailyStats.fromAnalyticsJson(dailyAnalytics),
      weeklyStats:
          MerchantPeriodStats.fromAnalyticsJson(weeklyAnalytics, 'week'),
      monthlyStats:
          MerchantPeriodStats.fromAnalyticsJson(monthlyAnalytics, 'month'),
      allTimeStats: MerchantPeriodStats(
        orders: allTimeOrders,
        revenue: _toDouble(profile['total_revenue'], allTimeOrders * 50.0),
        foodSavedKg: allTimeFoodKg,
        period: 'allTime',
      ),
    );
  }

  String get initials {
    if (businessName.isEmpty) return '??';
    final words = businessName.trim().split(RegExp(r'\s+'));
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    final stripped = businessName.replaceAll(RegExp(r'\s'), '');
    if (stripped.length >= 2) return stripped.substring(0, 2).toUpperCase();
    if (stripped.isNotEmpty) return stripped.toUpperCase();
    return '??';
  }

  MerchantProfile copyWith({
    String? id,
    String? businessName,
    String? businessType,
    String? avatarUrl,
    double? trustScore,
    String? phone,
    String? address,
    String? wilaya,
    double? latitude,
    double? longitude,
    MerchantDailyStats? dailyStats,
    MerchantPeriodStats? weeklyStats,
    MerchantPeriodStats? monthlyStats,
    MerchantPeriodStats? allTimeStats,
  }) {
    return MerchantProfile(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      trustScore: trustScore ?? this.trustScore,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      wilaya: wilaya ?? this.wilaya,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dailyStats: dailyStats ?? this.dailyStats,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      allTimeStats: allTimeStats ?? this.allTimeStats,
    );
  }
}

class ActivityItem {
  final String type; // 'new_order', 'completed', 'donation', 'cancelled'
  final String primaryText;
  final String secondaryText;
  final DateTime timestamp;
  final String? orderId;

  const ActivityItem({
    required this.type,
    required this.primaryText,
    required this.secondaryText,
    required this.timestamp,
    this.orderId,
  });
}
