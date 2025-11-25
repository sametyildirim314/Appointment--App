class Business {
  final int? id;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String? password;
  final String? address;
  final String? city;
  final String? district;
  final String? description;
  final String? openingTime;
  final String? closingTime;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Business({
    this.id,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.password,
    this.address,
    this.city,
    this.district,
    this.description,
    this.openingTime,
    this.closingTime,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    bool parseIsActive(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == '1' || lower == 'true' || lower == 'yes';
      }
      return true;
    }

    return Business(
      id: json['id'] as int?,
      businessName: json['business_name'] as String,
      ownerName: json['owner_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      description: json['description'] as String?,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      isActive: parseIsActive(json['is_active']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'email': email,
      'phone': phone,
      'password': password,
      'address': address,
      'city': city,
      'district': district,
      'description': description,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Business copyWith({
    int? id,
    String? businessName,
    String? ownerName,
    String? email,
    String? phone,
    String? password,
    String? address,
    String? city,
    String? district,
    String? description,
    String? openingTime,
    String? closingTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      description: description ?? this.description,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

