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
    required this.dailyStats,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.allTimeStats,
  });

  String get initials {
    final parts = businessName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return businessName.substring(0, 2).toUpperCase();
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
