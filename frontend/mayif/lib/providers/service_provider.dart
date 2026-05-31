import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<Service> _services = [];
  List<Service> _topRatedServices = [];
  List<Service> _activityServices = [];
  bool _isLoading = false;
  bool _isTopRatedLoading = false;
  bool _isActivitiesLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _nextPageUrl;
  bool _hasMore = true;

  List<Service> get services => _services;
  List<Service> get topRatedServices => _topRatedServices;
  List<Service> get activityServices => _activityServices;
  bool get isLoading => _isLoading;
  bool get isTopRatedLoading => _isTopRatedLoading;
  bool get isActivitiesLoading => _isActivitiesLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // ── Chargement initial avec filtres ──────────────────────────────────────
  Future<void> fetchServices({
    String? typeService,
    String? search,
    double? prixMin,
    double? prixMax,
    double? noteMin,
    String? ordering,
  }) async {
    _isLoading = true;
    _hasError = false;
    _services = [];
    _nextPageUrl = null;
    _hasMore = true;
    notifyListeners();

    try {
      String endpoint = '/services/';
      final params = <String>[];

      if (typeService != null && typeService != 'TOUT') {
        params.add('type_service=$typeService');
      }
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      if (prixMin != null) params.add('prix_min=$prixMin');
      if (prixMax != null) params.add('prix_max=$prixMax');
      if (noteMin != null) params.add('note_min=$noteMin');
      if (ordering != null) params.add('ordering=$ordering');

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

  // ── Chargement des mieux notés ───────────────────────────────────────────
  Future<void> fetchTopRated() async {
    _isTopRatedLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/services/?ordering=-note_moyenne');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        _topRatedServices = results.map((e) => Service.fromJson(e)).take(5).toList();
      }
    } catch (_) {}
    _isTopRatedLoading = false;
    notifyListeners();
  }

  // ── Chargement des activités (type ACTIVITE) ─────────────────────────────
  Future<void> fetchActivities() async {
    _isActivitiesLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/services/?type_service=ACTIVITE');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        _activityServices = results.map((e) => Service.fromJson(e)).take(6).toList();
      }
    } catch (_) {}
    _isActivitiesLoading = false;
    notifyListeners();
  }

  // ── Récupérer par ID ─────────────────────────────────────────────────────
  Future<Service?> fetchById(int id) async {
    try {
      final response = await ApiService.get('/services/$id/');
      if (response.statusCode == 200) {
        return Service.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching service $id: $e');
    }
    return null;
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
  Future<void> refresh() async {
    await Future.wait([
      fetchServices(),
      fetchTopRated(),
      fetchActivities(),
    ]);
  }
}
