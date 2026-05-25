import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'api_service.dart';

class ReservationService {
  // ── Créer une réservation → retourne l'ID ────────────────────────────────
  static Future<int?> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('/reservations/', data);
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['id'];
    }
    return null;
  }

  // ── Lister mes réservations ───────────────────────────────────────────────
  static Future<List<dynamic>> getMesReservations() async {
    final response = await ApiService.get('/reservations/');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'] ?? data;
    }
    return [];
  }

  // ── Annuler une réservation ───────────────────────────────────────────────
  static Future<bool> annuler(int reservationId) async {
    final response =
        await ApiService.post('/reservations/$reservationId/annuler/', {});
    return response.statusCode == 200;
  }

  // ── Upload capture écran paiement ─────────────────────────────────────────
  static Future<bool> uploadProof(int reservationId, XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    final response = await ApiService.uploadFile(
      '/reservations/$reservationId/confirmer_paiement/',
      'capture_ecran',
      filePath: kIsWeb ? null : xFile.path,
      bytes: bytes,
      fileName: xFile.name,
    );
    return response.statusCode == 200;
  }
}
