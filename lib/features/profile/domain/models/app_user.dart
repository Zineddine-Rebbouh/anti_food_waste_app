import 'package:anti_food_waste_app/core/config/app_config.dart';

double _toDoubleUser(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

/// Domain model representing an authenticated app user.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String level;
  final String joinDate;
  final int mealsSaved;
  final int ordersCount;
  final double co2Reduced;
  final double moneySaved;
  final double ecoScore;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.avatarUrl,
    required this.level,
    required this.joinDate,
    required this.mealsSaved,
    required this.ordersCount,
    required this.co2Reduced,
    required this.moneySaved,
    required this.ecoScore,
  });

  /// Returns a copy of this [AppUser] with the given fields replaced.
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? level,
    String? joinDate,
    int? mealsSaved,
    int? ordersCount,
    double? co2Reduced,
    double? moneySaved,
    double? ecoScore,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      joinDate: joinDate ?? this.joinDate,
      mealsSaved: mealsSaved ?? this.mealsSaved,
      ordersCount: ordersCount ?? this.ordersCount,
      co2Reduced: co2Reduced ?? this.co2Reduced,
      moneySaved: moneySaved ?? this.moneySaved,
      ecoScore: ecoScore ?? this.ecoScore,
    );
  }

  /// A static mock instance for UI development and testing.
  static const AppUser mock = AppUser(
    id: 'usr_001',
    name: 'Zineddine Rahim',
    email: 'zineddine@savefood.dz',
    phone: '0555123456',
    avatarUrl: '',
    level: 'Silver',
    joinDate: 'Jan 2024',
    mealsSaved: 32,
    ordersCount: 28,
    co2Reduced: 14.4,
    moneySaved: 4800.0,
    ecoScore: 78.0,
  );

  /// Builds an [AppUser] from a backend [UserDetailSerializer] JSON response.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    // Build display name: prefer first_name + last_name, fall back to email prefix
    final email = json['email'] as String? ?? '';
    final firstName = (json['first_name'] as String? ?? '').trim();
    final lastName = (json['last_name'] as String? ?? '').trim();
    final String displayName;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      displayName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    } else {
      final namePart = email.contains('@') ? email.split('@').first : email;
      displayName = namePart
          .replaceAll(RegExp(r'[._\-+]'), ' ')
          .split(' ')
          .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ')
          .trim();
    }

    // Formatted join date from ISO-8601 date_joined
    String joinDate = '';
    final dateJoinedStr = json['date_joined'] as String?;
    if (dateJoinedStr != null) {
      try {
        final dt = DateTime.parse(dateJoinedStr);
        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        joinDate = '${months[dt.month]} ${dt.year}';
      } catch (_) {}
    }

    // Eco level from eco_score
    final ecoScore = _toDoubleUser(profile['eco_score']);
    final String level;
    if (ecoScore >= 80) {
      level = 'Gold';
    } else if (ecoScore >= 40) {
      level = 'Silver';
    } else {
      level = 'Bronze';
    }

    // ~0.5 kg food saved per order; ~2.5 kg CO2 per kg food
    final foodSavedKg = _toDoubleUser(profile['total_food_saved_kg']);

    String normalizeUrl(String url) {
      if (url.isEmpty) return '';
      final baseAppUrl = AppConfig.baseUrl.split('/api/').first;
      if (url.startsWith('http')) {
        if (url.contains('://127.0.0.1') || url.contains('://localhost')) {
          final path = Uri.parse(url).path;
          return '$baseAppUrl$path';
        }
        return url;
      }
      final cleanUrl = url.startsWith('/') ? url : '/$url';
      return '$baseAppUrl$cleanUrl';
    }

    return AppUser(
      id: json['id']?.toString() ?? '',
      name: displayName.isEmpty ? email : displayName,
      email: email,
      phone: json['phone'] as String? ?? '',
      avatarUrl: normalizeUrl(json['avatar_url'] as String? ?? ''),
      level: level,
      joinDate: joinDate,
      mealsSaved: (profile['total_orders'] as num? ?? 0).toInt(),
      ordersCount: (profile['completed_orders'] as num? ?? 0).toInt(),
      co2Reduced: foodSavedKg * 2.5,
      moneySaved: 0,
      ecoScore: ecoScore,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, level: $level, '
        'ecoScore: $ecoScore, mealsSaved: $mealsSaved, ordersCount: $ordersCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        other.level == level &&
        other.joinDate == joinDate &&
        other.mealsSaved == mealsSaved &&
        other.ordersCount == ordersCount &&
        other.co2Reduced == co2Reduced &&
        other.moneySaved == moneySaved &&
        other.ecoScore == ecoScore;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        avatarUrl,
        level,
        joinDate,
        mealsSaved,
        ordersCount,
        co2Reduced,
        moneySaved,
        ecoScore,
      );
}
