/// Domain model representing an authenticated app user.
class AppUser {
  final String id;
  final String name;
  final String email;
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
    avatarUrl: '',
    level: 'Silver',
    joinDate: 'Jan 2024',
    mealsSaved: 32,
    ordersCount: 28,
    co2Reduced: 14.4,
    moneySaved: 4800.0,
    ecoScore: 78.0,
  );

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
