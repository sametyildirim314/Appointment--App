import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/business.dart';
import '../models/admin.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final String _customerKey = 'customer_data';
  final String _businessKey = 'business_data';
  final String _adminKey = 'admin_data';
  final String _tokenKey = 'auth_token';
  final String _userTypeKey = 'user_type';
  final String _tokenExpiryKey = 'auth_token_expiry';
  final Duration _sessionDuration = const Duration(minutes: 5);

  // Müşteri girişi
  Future<Map<String, dynamic>> customerLogin(String email, String password) async {
    final response = await _apiService.post(
      ApiConfig.customerLogin,
      {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final customer = Customer.fromJson(data['customer'] as Map<String, dynamic>);
      final token = data['token'] as String?;

      if (token != null) {
        await _saveAuthData(customer.toJson(), token, 'customer');
        _apiService.setToken(token, 'customer');
      }

      return {
        'success': true,
        'customer': customer,
      };
    }

    return response;
  }

  // Müşteri kaydı
  Future<Map<String, dynamic>> customerRegister(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final response = await _apiService.post(
      ApiConfig.customerRegister,
      {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final customer = Customer.fromJson(data['customer'] as Map<String, dynamic>);
      final token = data['token'] as String?;

      if (token != null) {
        await _saveAuthData(customer.toJson(), token, 'customer');
        _apiService.setToken(token, 'customer');
      }

      return {
        'success': true,
        'customer': customer,
      };
    }

    return response;
  }

  // İşletme girişi
  Future<Map<String, dynamic>> businessLogin(String email, String password) async {
    final response = await _apiService.post(
      ApiConfig.businessLogin,
      {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final business = Business.fromJson(data['business'] as Map<String, dynamic>);
      final token = data['token'] as String?;

      if (token != null) {
        await _saveAuthData(business.toJson(), token, 'business');
        _apiService.setToken(token, 'business');
      }

      return {
        'success': true,
        'business': business,
      };
    }

    return response;
  }

  // İşletme kaydı
  Future<Map<String, dynamic>> businessRegister(
    String businessName,
    String ownerName,
    String email,
    String phone,
    String password,
    String? address,
    String? city,
    String? district,
  ) async {
    final response = await _apiService.post(
      ApiConfig.businessRegister,
      {
        'business_name': businessName,
        'owner_name': ownerName,
        'email': email,
        'phone': phone,
        'password': password,
        'address': address,
        'city': city,
        'district': district,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final business = Business.fromJson(data['business'] as Map<String, dynamic>);
      final token = data['token'] as String?;

      if (token != null) {
        await _saveAuthData(business.toJson(), token, 'business');
        _apiService.setToken(token, 'business');
      }

      return {
        'success': true,
        'business': business,
      };
    }

    return response;
  }

  // Admin girişi
  Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    final response = await _apiService.post(
      ApiConfig.adminLogin,
      {
        'username': username,
        'password': password,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final admin = Admin.fromJson(data['admin'] as Map<String, dynamic>);
      final token = data['token'] as String?;

      if (token != null) {
        await _saveAuthData(admin.toJson(), token, 'admin');
        _apiService.setToken(token, 'admin');
      }

      return {
        'success': true,
        'admin': admin,
      };
    }

    return response;
  }

  // Oturum verilerini kaydet
  Future<void> _saveAuthData(
    Map<String, dynamic> userData,
    String token,
    String userType,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = userType == 'customer'
        ? _customerKey
        : userType == 'business'
            ? _businessKey
            : _adminKey;

    await prefs.setString(userKey, jsonEncode(userData));
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userTypeKey, userType);
    final expiry = DateTime.now().add(_sessionDuration);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  Future<void> updateStoredBusinessData(Map<String, dynamic> businessData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessKey, jsonEncode(businessData));
    final expiry = DateTime.now().add(_sessionDuration);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  // Oturum verilerini yükle
  Future<Map<String, dynamic>?> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString(_userTypeKey);
    final token = prefs.getString(_tokenKey);
    final expiryStr = prefs.getString(_tokenExpiryKey);

    if (userType == null || token == null || expiryStr == null) {
      await logout();
      return null;
    }

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      await logout();
      return null;
    }

    final userKey = userType == 'customer'
        ? _customerKey
        : userType == 'business'
            ? _businessKey
            : _adminKey;

    final userDataStr = prefs.getString(userKey);
    if (userDataStr == null) {
      await logout();
      return null;
    }

    _apiService.setToken(token, userType);
    // Oturum süresini uzat
    final newExpiry = DateTime.now().add(_sessionDuration);
    await prefs.setString(_tokenExpiryKey, newExpiry.toIso8601String());

    return {
      'userType': userType,
      'userData': jsonDecode(userDataStr),
      'token': token,
    };
  }

  // Çıkış yap
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customerKey);
    await prefs.remove(_businessKey);
    await prefs.remove(_adminKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_tokenExpiryKey);
    _apiService.setToken(null, null);
  }

  // Oturum kontrolü
  Future<bool> isLoggedIn() async {
    final authData = await loadAuthData();
    return authData != null;
  }

  // Kullanıcı tipini al
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }
}

