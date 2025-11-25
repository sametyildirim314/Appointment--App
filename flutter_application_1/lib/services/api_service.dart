import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? _userType; // 'customer', 'business', 'admin'

  void setToken(String? token, String? userType) {
    _token = token;
    _userType = userType;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Backend zaten success ve data içeriyor, direkt döndür
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Bir hata oluştu',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Veri işlenirken hata oluştu: $e',
      };
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http
          .post(
            url,
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http
          .get(
            url,
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http
          .put(
            url,
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http
          .delete(
            url,
            headers: _headers,
          )
          .timeout(ApiConfig.connectTimeout);

      return await _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı hatası: $e',
      };
    }
  }
}

