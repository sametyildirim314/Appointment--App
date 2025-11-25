import '../config/api_config.dart';
import '../models/business.dart';
import '../models/service.dart';
import '../models/employee.dart';
import 'api_service.dart';

class BusinessService {
  final ApiService _apiService = ApiService();

  Future<List<Service>> getMyServices() async {
    final response = await _apiService.get(ApiConfig.businessServices);
    if (response['success'] == true && response['data'] != null) {
      final services = response['data']['services'] as List<dynamic>;
      return services
          .map((json) => Service.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Service?> createService({
    required String name,
    required int duration,
    required double price,
    String? description,
    bool isActive = true,
  }) async {
    final response = await _apiService.post(ApiConfig.businessServices, {
      'service_name': name,
      'description': description,
      'duration': duration,
      'price': price,
      'is_active': isActive,
    });

    if (response['success'] == true && response['data'] != null) {
      final serviceJson =
          response['data']['service'] as Map<String, dynamic>? ?? {};
      if (serviceJson.isNotEmpty) {
        return Service.fromJson(serviceJson);
      }
    }
    return null;
  }

  Future<Service?> updateService(
    int serviceId, {
    String? name,
    String? description,
    int? duration,
    double? price,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['service_name'] = name;
    if (description != null) body['description'] = description;
    if (duration != null) body['duration'] = duration;
    if (price != null) body['price'] = price;
    if (isActive != null) body['is_active'] = isActive;

    if (body.isEmpty) {
      return null;
    }

    final response = await _apiService.put(
      '${ApiConfig.businessServices}/$serviceId',
      body,
    );

    if (response['success'] == true && response['data'] != null) {
      final serviceJson =
          response['data']['service'] as Map<String, dynamic>? ?? {};
      if (serviceJson.isNotEmpty) {
        return Service.fromJson(serviceJson);
      }
    }

    return null;
  }

  Future<bool> deleteService(int serviceId) async {
    final response = await _apiService.delete(
      '${ApiConfig.businessServices}/$serviceId',
    );
    return response['success'] == true;
  }

  Future<Business?> updateBusinessHours({
    required String openingTime,
    required String closingTime,
  }) async {
    final response = await _apiService.put(ApiConfig.businessHours, {
      'opening_time': openingTime,
      'closing_time': closingTime,
    });

    if (response['success'] == true && response['data'] != null) {
      final businessJson =
          response['data']['business'] as Map<String, dynamic>? ?? {};
      if (businessJson.isNotEmpty) {
        return Business.fromJson(businessJson);
      }
    }

    return null;
  }

  Future<List<Employee>> getMyEmployees() async {
    final response = await _apiService.get(ApiConfig.businessEmployees);
    if (response['success'] == true && response['data'] != null) {
      final employees = response['data']['employees'] as List<dynamic>;
      return employees
          .map((json) => Employee.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Employee?> createEmployee({
    required String name,
    required String email,
    required String phone,
    String? specialization,
    bool isActive = true,
  }) async {
    final response = await _apiService.post(ApiConfig.businessEmployees, {
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'is_active': isActive,
    });

    if (response['success'] == true && response['data'] != null) {
      final employeeJson =
          response['data']['employee'] as Map<String, dynamic>? ?? {};
      if (employeeJson.isNotEmpty) {
        return Employee.fromJson(employeeJson);
      }
    }
    return null;
  }

  Future<Employee?> updateEmployee(
    int employeeId, {
    String? name,
    String? email,
    String? phone,
    String? specialization,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (specialization != null) body['specialization'] = specialization;
    if (isActive != null) body['is_active'] = isActive;

    if (body.isEmpty) {
      return null;
    }

    final response = await _apiService.put(
      '${ApiConfig.businessEmployees}/$employeeId',
      body,
    );

    if (response['success'] == true && response['data'] != null) {
      final employeeJson =
          response['data']['employee'] as Map<String, dynamic>? ?? {};
      if (employeeJson.isNotEmpty) {
        return Employee.fromJson(employeeJson);
      }
    }
    return null;
  }

  Future<bool> deleteEmployee(int employeeId) async {
    final response = await _apiService.delete(
      '${ApiConfig.businessEmployees}/$employeeId',
    );
    return response['success'] == true;
  }
}
