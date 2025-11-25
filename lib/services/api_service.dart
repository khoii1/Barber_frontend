import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (includeAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    return await http.get(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: headers,
    );
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    return await http.post(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    return await http.patch(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: headers,
      body: json.encode(body),
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    return await http.delete(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: headers,
    );
  }
}
