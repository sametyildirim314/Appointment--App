class Employee {
  final int? id;
  final int businessId;
  final String name;
  final String? email;
  final String? phone;
  final String? specialization;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Employee({
    this.id,
    required this.businessId,
    required this.name,
    this.email,
    this.phone,
    this.specialization,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
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

    return Employee(
      id: json['id'] as int?,
      businessId: json['business_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      specialization: json['specialization'] as String?,
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
      'business_id': businessId,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

