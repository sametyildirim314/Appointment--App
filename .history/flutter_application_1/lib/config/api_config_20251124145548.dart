import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Backend API base URL - Node.js backend URL'i
  // Platform'a göre otomatik ayarlanır
  static String get baseUrl {
    if (kIsWeb) {
      // Web için localhost
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android emulator için 10.0.2.2 (localhost yerine)
      return 'http://10.0.2.2:3000/api';
    } else {
      // iOS simulator ve fiziksel cihazlar için localhost
      return 'http://localhost:3000/api';
    }
  }
  
  // API endpoints
  static const String customerLogin = '/auth/customer/login';
  static const String customerRegister = '/auth/customer/register';
  static const String businessLogin = '/auth/business/login';
  static const String businessRegister = '/auth/business/register';
  static const String adminLogin = '/auth/admin/login';
  
  static const String getBusinesses = '/businesses';
  static const String getServices = '/services';
  static const String getEmployees = '/employees';
  static const String getAppointments = '/appointments';
  static const String createAppointment = '/appointments/create';
  static const String updateAppointment = '/appointments/update';
  static const String cancelAppointment = '/appointments/cancel';
  
  static const String getCustomerAppointments = '/appointments/customer';
  static const String getBusinessAppointments = '/appointments/business';
  
  // Business management endpoints
  static const String businessServices = '/business/services';
  static const String businessHours = '/business/hours';
  
  // Admin endpoints
  static const String getAdminStats = '/admin/stats';
  static const String getAllCustomers = '/customers';
  static const String getAllAppointments = '/appointments/all';
  
  // Timeout süreleri
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

