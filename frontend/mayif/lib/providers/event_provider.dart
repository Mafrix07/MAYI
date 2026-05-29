import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/evenement.dart';
import '../services/api_service.dart';

class EventProvider with ChangeNotifier {
  List<Evenement> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Evenement> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/evenements/');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data is List ? data : (data['results'] as List<dynamic>);
        _events = results.map((e) => Evenement.fromJson(e)).toList();
      } else {
        _errorMessage = 'Erreur lors du chargement des événements';
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
