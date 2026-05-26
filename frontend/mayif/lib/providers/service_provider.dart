import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _nextPageUrl;
  bool _hasMore = true;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // ── Chargement initial ────────────────────────────────────────────────────
  Future<void> fetchServices({String? categorie, String? q}) async {
    _isLoading = true;
    _hasError = false;
    _services = [];
    _nextPageUrl = null;
    _hasMore = true;
    notifyListeners();

    try {
      String endpoint = '/services/';
      final params = <String>[];
      if (categorie != null) params.add('categorie=$categorie');
      if (q != null && q.isNotEmpty) params.add('q=$q');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        _services = results.map((e) => Service.fromJson(e)).toList();
        _nextPageUrl = data['next'];
        _hasMore = _nextPageUrl != null;
      } else {
        _hasError = true;
        _errorMessage = 'Erreur serveur (${response.statusCode})';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Impossible de charger les services. Vérifiez votre connexion.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Chargement de la page suivante (infinite scroll) ─────────────────────
  Future<void> fetchMore() async {
    if (_nextPageUrl == null || _isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get(_nextPageUrl!.replaceFirst(
        RegExp(r'https?://[^/]+/api'),
        '',
      ));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        _services.addAll(results.map((e) => Service.fromJson(e)));
        _nextPageUrl = data['next'];
        _hasMore = _nextPageUrl != null;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  // ── Rafraîchissement complet ──────────────────────────────────────────────
  Future<void> refresh() => fetchServices();
}
