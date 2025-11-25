class Appointment {
  final int? id;
  final int customerId;
  final int businessId;
  final int? employeeId;
  final int serviceId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // İlişkili veriler (join sonuçları için)
  final String? customerName;
  final String? businessName;
  final String? employeeName;
  final String? serviceName;

  Appointment({
    this.id,
    required this.customerId,
    required this.businessId,
    this.employeeId,
    required this.serviceId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = AppointmentStatus.pending,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.businessName,
    this.employeeName,
    this.serviceName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int,
      businessId: json['business_id'] as int,
      employeeId: json['employee_id'] as int?,
      serviceId: json['service_id'] as int,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String,
      status: AppointmentStatus.fromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      customerName: json['customer_name'] as String?,
      businessName: json['business_name'] as String?,
      employeeName: json['employee_name'] as String?,
      serviceName: json['service_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'business_id': businessId,
      'employee_id': employeeId,
      'service_id': serviceId,
      'appointment_date': appointmentDate.toIso8601String().split('T')[0],
      'appointment_time': appointmentTime,
      'status': status.name,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Beklemede';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}

