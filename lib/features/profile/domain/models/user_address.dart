class UserAddress {
  final String id;
  final String label;
  final String street;
  final String city;
  final String wilaya;
  final String postalCode;
  final String notes;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.wilaya,
    required this.postalCode,
    this.notes = '',
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $wilaya $postalCode';

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Other',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      wilaya: json['wilaya'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'street': street,
        'city': city,
        'wilaya': wilaya,
        'postal_code': postalCode,
        'notes': notes,
        'is_default': isDefault,
      };

  UserAddress copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? wilaya,
    String? postalCode,
    String? notes,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      wilaya: wilaya ?? this.wilaya,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
