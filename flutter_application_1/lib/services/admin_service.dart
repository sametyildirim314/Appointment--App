import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/customer.dart';
import '../models/business.dart';
import '../models/appointment.dart';

class AdminService {
  final ApiService _apiService;
  
  // Singleton pattern - aynı ApiService instance'ını kullan
  static final AdminService _instance = AdminService._internal(ApiService());
  factory AdminService() => _instance;
  AdminService._internal(this._apiService);

  // Admin istatistikleri
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      print('Fetching admin stats...');
      final response = await _apiService.get('/admin/stats');
      print('Stats response: $response');

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }

      print('Stats failed: ${response['message'] ?? 'Unknown error'}');
      return {
        'totalBusinesses': 0,
        'totalCustomers': 0,
        'totalAppointments': 0,
        'todayAppointments': 0,
        'pendingAppointments': 0,
      };
    } catch (e) {
      print('Stats error: $e');
      return {
        'totalBusinesses': 0,
        'totalCustomers': 0,
        'totalAppointments': 0,
        'todayAppointments': 0,
        'pendingAppointments': 0,
      };
    }
  }

  // Tüm müşterileri getir
  Future<List<Customer>> getCustomers() async {
    try {
      print('Fetching customers...');
      final response = await _apiService.get('/customers');
      print('Customers response: ${response['success']}');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final customers = data['customers'] as List<dynamic>;
        print('Found ${customers.length} customers');
        return customers
            .map((json) => Customer.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      print('Customers failed: ${response['message'] ?? 'Unknown error'}');
      return [];
    } catch (e) {
      print('Customers error: $e');
      return [];
    }
  }

  // Tüm randevuları getir
  Future<List<Appointment>> getAllAppointments() async {
    final response = await _apiService.get('/appointments/all');

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final appointments = data['appointments'] as List<dynamic>;
      return appointments
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // Tüm işletmeleri getir
  Future<List<Business>> getBusinesses() async {
    final response = await _apiService.get('/businesses?include_inactive=1');

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final businesses = data['businesses'] as List<dynamic>;
      return businesses
          .map((json) => Business.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<Business?> updateBusinessStatus(int businessId, bool isActive) async {
    try {
      final response = await _apiService.put(
        '/businesses/$businessId/status',
        {'is_active': isActive},
      );

      if (response['success'] == true && response['data'] != null) {
        final businessJson =
            (response['data'] as Map<String, dynamic>)['business']
                as Map<String, dynamic>;
        return Business.fromJson(businessJson);
      }

      return null;
    } catch (e) {
      print('Update business status error: $e');
      return null;
    }
  }
}

