import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  // 1. INSCRIPTION
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.baseUrl + Constants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        return {"success": true, "message": data['message']};
      } else {
        return {"success": false, "errors": data['errors'] ?? data['detail']};
      }
    } catch (e) {
      return {"success": false, "errors": "Erreur de connexion : $e"};
    }
  }

  // 2. CONNEXION (LOGIN)
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.baseUrl + Constants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        // Sauvegarder les tokens en sécurité
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        
        return {"success": true, "access": data['access']};
      } else {
        return {"success": false, "error": data['detail'] ?? "Erreur de connexion"};
      }
    } catch (e) {
      return {"success": false, "error": "Erreur de connexion : $e"};
    }
  }

  // 3. RECUPERER LE TOKEN STOCKÉ
  Future<String?> getToken() async {
    return await storage.read(key: 'access_token');
  }

  // 4. DECONNEXION
  Future<void> logout() async {
    await storage.deleteAll();
  }
}
