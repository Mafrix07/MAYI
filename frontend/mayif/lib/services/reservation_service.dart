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

  // ── Créer une réservation → retourne {id, montantAcompte} ou {error: "message"} ─
  static Future<Map<String, dynamic>> createWithError(Map<String, dynamic> data) async {
    final response = await ApiService.post('/reservations/', data);
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return {
        'id': body['id'] as int,
        'montantAcompte': double.tryParse(body['montant_acompte']?.toString() ?? '') ?? 0.0,
      };
    }
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final firstVal = body[body.keys.first];
        if (firstVal is List && firstVal.isNotEmpty) {
          return {'error': firstVal.first.toString()};
        }
        return {'error': body.toString()};
      }
    } catch (_) {}
    return {'error': 'Erreur ${response.statusCode}. Réessayez.'};
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

  // ── Annuler une réservation (touriste) ───────────────────────────────────
  static Future<bool> annuler(int reservationId) async {
    final response =
        await ApiService.post('/reservations/$reservationId/annuler/', {});
    return response.statusCode == 200;
  }

  // ── Modifier les dates (touriste) ─────────────────────────────────────────
  static Future<bool> modifierDates(int id, {required String debut, String? fin}) async {
    final response = await ApiService.patch('/reservations/$id/', {
      'date_debut': debut,
      if (fin != null) 'date_fin': fin,
    });
    return response.statusCode == 200;
  }

  // ── Changer statut (Pro : CONFIRMEE / ANNULEE) ────────────────────────────
  static Future<bool> changerStatut(int id, String statut) async {
    final response = await ApiService.patch('/reservations/$id/', {'statut': statut});
    return response.statusCode == 200;
  }

  // ── Réservations reçues pour un Pro ──────────────────────────────────────
  static Future<List<dynamic>> getReservationsRecues() async {
    final response = await ApiService.get('/reservations/');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'] ?? data;
    }
    return [];
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
