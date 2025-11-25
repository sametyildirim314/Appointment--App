import '../models/appointment.dart';
import '../models/business.dart';
import '../models/service.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AppointmentService {
  final ApiService _apiService = ApiService();

  // Randevu oluştur
  Future<Map<String, dynamic>> createAppointment(Appointment appointment) async {
    return await _apiService.post(
      ApiConfig.createAppointment,
      appointment.toJson(),
    );
  }

  // Randevu güncelle
  Future<Map<String, dynamic>> updateAppointment(Appointment appointment) async {
    return await _apiService.put(
      '${ApiConfig.updateAppointment}/${appointment.id}',
      appointment.toJson(),
    );
  }

  // Randevu durumunu güncelle
  Future<Map<String, dynamic>> updateAppointmentStatus(
    int appointmentId,
    AppointmentStatus status,
  ) async {
    return await _apiService.put(
      '${ApiConfig.updateAppointment}/$appointmentId',
      {'status': status.name},
    );
  }

  // Randevu iptal et
  Future<Map<String, dynamic>> cancelAppointment(int appointmentId) async {
    return await _apiService.put(
      '${ApiConfig.cancelAppointment}/$appointmentId',
      {'status': 'cancelled'},
    );
  }

  // Müşteri randevularını getir
  Future<List<Appointment>> getCustomerAppointments(int customerId) async {
    final response = await _apiService.get(
      '${ApiConfig.getCustomerAppointments}/$customerId',
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final appointments = data['appointments'] as List<dynamic>;
      return appointments
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // İşletme randevularını getir
  Future<List<Appointment>> getBusinessAppointments(int businessId) async {
    final response = await _apiService.get(
      '${ApiConfig.getBusinessAppointments}/$businessId',
    );

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
    final response = await _apiService.get(ApiConfig.getBusinesses);

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final businesses = data['businesses'] as List<dynamic>;
      return businesses
          .map((json) => Business.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // İşletme hizmetlerini getir
  Future<List<Service>> getServices(int businessId) async {
    try {
      print('Fetching services for business_id: $businessId');
      final endpoint = '${ApiConfig.getServices}?business_id=$businessId';
      print('Full endpoint: $endpoint');
      
      final response = await _apiService.get(endpoint);
      print('Services response success: ${response['success']}');
      print('Services response keys: ${response.keys}');
      
      if (response['success'] == true) {
        if (response['data'] != null) {
          final data = response['data'];
          print('Data keys: ${data.keys}');
          
          if (data['services'] != null) {
            final services = data['services'] as List<dynamic>;
            print('Found ${services.length} services in response');
            
            final serviceList = <Service>[];
            for (var i = 0; i < services.length; i++) {
              try {
                final serviceJson = services[i] as Map<String, dynamic>;
                print('Parsing service $i: ${serviceJson['service_name']}');
                final service = Service.fromJson(serviceJson);
                serviceList.add(service);
                print('  ✓ Parsed: ${service.serviceName} - ${service.price} ₺');
              } catch (e) {
                print('  ✗ Error parsing service $i: $e');
                print('  Service JSON: ${services[i]}');
              }
            }
            
            print('Successfully parsed ${serviceList.length} services');
            return serviceList;
          } else {
            print('No "services" key in data');
            return [];
          }
        } else {
          print('Response data is null');
          return [];
        }
      } else {
        print('Services failed: ${response['message'] ?? 'Unknown error'}');
        print('Full response: $response');
        return [];
      }
    } catch (e, stackTrace) {
      print('Services error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // İşletme çalışanlarını getir
  Future<List<Employee>> getEmployees(int businessId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.getEmployees}?business_id=$businessId',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final employees = data['employees'] as List<dynamic>;
        return employees
            .map((json) => Employee.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Employees error: $e');
      return [];
    }
  }

  // Çalışan çalışma saatlerini getir
  Future<List<Map<String, dynamic>>> getEmployeeSchedule(int employeeId) async {
    try {
      final response = await _apiService.get(
        '/employee/schedule?employee_id=$employeeId',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        return (data['schedules'] as List<dynamic>)
            .map((json) => json as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      print('Employee schedule error: $e');
      return [];
    }
  }
}

