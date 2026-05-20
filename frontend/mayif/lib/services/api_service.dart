import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import '../main.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }

  static const _storage = FlutterSecureStorage();

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'token');
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  static Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await _storage.delete(key: 'token');
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
    return response;
  }
}
