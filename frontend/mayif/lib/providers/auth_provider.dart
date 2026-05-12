import '../utils/jwt_parser.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  String? _role;
  String? get role => _role;
  bool _isReady = false;
  bool get isReady => _isReady;

  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;



  Future<bool> login(String username, String password) async {
    try {
      final response = await ApiService.post('/auth/login/', {
          'username': username,
          'password': password,
      }
      ) ;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access'];
        _decodeToken();
        await _storage.write(key: 'token', value: _token);

        // Fetch user profile
        await fetchProfile();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.post('/auth/register/', userData);
      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }
    return false;
  }

  Future<void> fetchProfile() async {
    if (_token == null) return;
    try {
      final response = await ApiService.get('/auth/me/');
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        _token = token;
        _decodeToken();
        await fetchProfile();
      }
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Auto-login error: $e');
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }
  void _decodeToken() {
  if (_token != null) {
    final payload = JwtParser.parse(_token!);
    _role = payload['role'];
  }
}
}
