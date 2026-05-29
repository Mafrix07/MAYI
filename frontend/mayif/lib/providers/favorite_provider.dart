import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<Service> _favorites = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;

  List<Service> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    _loadLocalIds();
  }

  // ── Chargement local (pour affichage instantané) ─────────────────────────
  Future<void> _loadLocalIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? [];
    _favoriteIds = ids.map((e) => int.parse(e)).toSet();
    notifyListeners();
  }

  Future<void> _saveLocalIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_ids', _favoriteIds.map((e) => e.toString()).toList());
  }

  bool isFavorite(int serviceId) => _favoriteIds.contains(serviceId);

  // ── Charger depuis le serveur ───────────────────────────────────────────
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/favorites/');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data is List ? data : (data['results'] as List<dynamic>);
        _favorites = results.map((e) => Service.fromJson(e['service'] ?? e)).toList();
        
        // Synchroniser les IDs locaux
        _favoriteIds = _favorites.map((e) => e.id).toSet();
        await _saveLocalIds();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Basculer favori (Toggle) ────────────────────────────────────────────
  Future<void> toggleFavorite(Service service) async {
    final serviceId = service.id;
    final exists = _favoriteIds.contains(serviceId);
    
    // Mise à jour immédiate UI (optimiste)
    if (exists) {
      _favoriteIds.remove(serviceId);
      _favorites.removeWhere((element) => element.id == serviceId);
    } else {
      _favoriteIds.add(serviceId);
      _favorites.insert(0, service);
    }
    notifyListeners();
    await _saveLocalIds();

    try {
      if (exists) {
        // Le backend attend souvent l'ID de la relation favori ou l'ID du service
        await ApiService.delete('/favorites/$serviceId/');
      } else {
        await ApiService.post('/favorites/', {'service': serviceId});
      }
    } catch (e) {
      // En cas d'erreur serveur, on pourrait annuler le changement local
      debugPrint('Error toggling favorite: $e');
    }
  }
}
