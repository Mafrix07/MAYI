import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../main.dart';

class ApiService {
  /// Callback enregistré par AuthProvider pour vider l'état en mémoire
  /// quand le serveur répond 401 (token expiré / invalide).
  static VoidCallback? onUnauthorized;

  // ── URL de base ────────────────────────────────────────────────────────────
  // Passée au build via --dart-define=API_URL=https://ton-app.railway.app/api
  // Si non définie : URLs locales selon la plateforme (développement)
  static const String _prodUrl = String.fromEnvironment('API_URL', defaultValue: '');

  static String get baseUrl {
    if (_prodUrl.isNotEmpty) return _prodUrl;
    // Développement local
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api'; // émulateur → remplacer par IP LAN sur vrai téléphone
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000/api';
      default:
        return 'http://127.0.0.1:8000/api';
    }
  }

  static const _storage = FlutterSecureStorage();

  // ── Récupérer le token (une seule clé : 'token') ──────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET ───────────────────────────────────────────────────────────────────
  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  // ── POST ──────────────────────────────────────────────────────────────────
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data,
      {bool handleUnauthorized = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return handleUnauthorized ? _handleResponse(response) : response;
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────
  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  static Future<http.Response> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  // ── Upload multipart ───────────────────────────────────────────────────
  static Future<http.Response> uploadFile(
      String endpoint, String fieldName, {String? filePath, Uint8List? bytes, String? fileName}) async {
    final token = await _storage.read(key: 'token');
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (kIsWeb && bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: fileName ?? 'upload.jpg',
      ));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // ── Gestion centralisée des réponses ──────────────────────────────────────
  static http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Token expiré → vider le storage sécurisé
      const FlutterSecureStorage().delete(key: 'token');
      // Notifier AuthProvider pour vider son état en mémoire
      onUnauthorized?.call();
      // Rediriger vers login
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
    return response;
  }
}
