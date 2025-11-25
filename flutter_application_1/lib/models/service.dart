class Service {
  final int? id;
  final int businessId;
  final String serviceName;
  final String? description;
  final int duration; // dakika cinsinden
  final double price;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    required this.businessId,
    required this.serviceName,
    this.description,
    required this.duration,
    this.price = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Price string veya number olarak gelebilir
    double parsePrice(dynamic priceValue) {
      if (priceValue == null) return 0.0;
      if (priceValue is num) return priceValue.toDouble();
      if (priceValue is String) {
        return double.tryParse(priceValue) ?? 0.0;
      }
      return 0.0;
    }

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

    return Service(
      id: json['id'] as int?,
      businessId: json['business_id'] as int,
      serviceName: json['service_name'] as String,
      description: json['description'] as String?,
      duration: json['duration'] as int,
      price: parsePrice(json['price']),
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
      'service_name': serviceName,
      'description': description,
      'duration': duration,
      'price': price,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

