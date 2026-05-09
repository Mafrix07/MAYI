import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class ReservationService {
  static const _storage = FlutterSecureStorage();

  // ÉTAPE 1 : Créer la réservation (renvoie l'ID de la réservation)
  static Future<int?> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('/reservations/', data);

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['id'];
    }

    return null;
  }

  // ÉTAPE 2 : Envoyer la capture d'écran (Image)
  static Future<bool> uploadProof(int reservationId, String filePath) async {
    final token = await _storage.read(key: 'token');

    final uri = Uri.parse(
      '${ApiService.baseUrl}/reservations/$reservationId/confirmer_paiement/',
    );

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'capture_ecran',
          filePath,
        ),
      );

    final response = await request.send();

    return response.statusCode == 200;
  }
}