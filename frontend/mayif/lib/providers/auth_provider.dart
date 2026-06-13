import '../utils/jwt_parser.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  String? _role;
  String? get role => _role;
  bool _isReady = false;
  bool get isReady => _isReady;

  bool _onboardingComplete = false;
  bool get onboardingComplete => _onboardingComplete;

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    _onboardingComplete = true;
    notifyListeners();
  }

  AuthProvider() {
    ApiService.onUnauthorized = () {
      _token = null;
      _user = null;
      _role = null;
      notifyListeners();
    };
  }

  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService.post('/auth/login/', {
          'username': username,
          'password': password,
      }, handleUnauthorized: false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('access')) {
          _token = data['access'];
          _decodeToken();
          await _storage.write(key: 'token', value: _token);

          await fetchProfile();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = "Réponse invalide (token manquant)";
        }
      } else {
        if (response.statusCode == 400 || response.statusCode == 401) {
          _errorMessage = 'Identifiants incorrects. Vérifiez votre email et mot de passe.';
        } else {
          try {
            final data = jsonDecode(response.body);
            _errorMessage = data['detail'] ?? data['message'] ?? 'Erreur de connexion (${response.statusCode})';
          } catch (_) {
            _errorMessage = 'Erreur de connexion (${response.statusCode})';
          }
        }
      }
    } catch (e) {
      _errorMessage = "Erreur réseau ou serveur : $e";
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.patch('/auth/me/', {
        'first_name': firstName,
        'last_name': lastName,
        'telephone': phone,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('id')) {
          _user = User.fromJson(data);
        } else {
          await fetchProfile();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Log silencieux pour la production
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> uploadProfilePhoto(XFile xFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bytes = await xFile.readAsBytes();
      final response = await ApiService.uploadFile(
        '/auth/me/photo/',
        'photo_profil',
        filePath: kIsWeb ? null : xFile.path,
        bytes: bytes,
        fileName: xFile.name,
      );
      
      if (response.statusCode == 200) {
        await fetchProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Log silencieux
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService.post('/auth/register/', userData);
      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['detail'] ?? data['message'] ?? 'Erreur lors de l\'inscription (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Erreur réseau ou serveur : $e";
    }
    _isLoading = false;
    notifyListeners();
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
      // Log silencieux
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
      final prefs = await SharedPreferences.getInstance();
      _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      final token = await _storage.read(key: 'token');
      if (token != null) {
        _token = token;
        _decodeToken();
        await fetchProfile();
      }
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      // Log silencieux
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
