import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const _storage = FlutterSecureStorage();// For Android Emulator

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
  final token = await _storage.read(key: 'token'); // Récupère le token tout seul

  return await http.post(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
    body: jsonEncode(data),
  );
}

static Future<http.Response> get(String endpoint) async {
  final token = await _storage.read(key: 'token');

  return await http.get(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
}
}
