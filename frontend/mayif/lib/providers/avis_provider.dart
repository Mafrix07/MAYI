import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/avis.dart';
import '../services/api_service.dart';

class AvisProvider with ChangeNotifier {
  List<Avis> _avis = [];
  bool _isLoading = false;
  bool _dejaPoste = false;
  String? _errorMessage;

  List<Avis> get avis => _avis;
  bool get isLoading => _isLoading;
  bool get dejaPoste => _dejaPoste;
  String? get errorMessage => _errorMessage;

  // ── Récupérer les avis d'un service ───────────────────────────────────────
  Future<void> fetchAvis(int serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    _avis = [];
    notifyListeners();

    try {
      final response = await ApiService.get('/reviews/?service=$serviceId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data is List ? data : (data['results'] as List<dynamic>);
        _avis = results.map((e) => Avis.fromJson(e)).toList();
      } else {
        _errorMessage = 'Erreur lors du chargement des avis';
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Poster un avis ────────────────────────────────────────────────────────
  Future<bool> posterAvis({
    required int serviceId,
    required double note,
    required String commentaire,
  }) async {
    _isLoading = true;
    _dejaPoste = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/reviews/', {
        'service': serviceId,
        'note': note,
        'commentaire': commentaire,
      });

      if (response.statusCode == 201) {
        final nouvelAvis = Avis.fromJson(jsonDecode(response.body));
        _avis.insert(0, nouvelAvis);
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        // Django renvoie souvent une erreur si l'utilisateur a déjà posté
        if (data.toString().contains('déjà posté') || data.toString().contains('already exists')) {
          _dejaPoste = true;
        }
        _errorMessage = 'Vous avez déjà laissé un avis pour ce service.';
      } else {
        _errorMessage = 'Impossible de publier l\'avis (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
