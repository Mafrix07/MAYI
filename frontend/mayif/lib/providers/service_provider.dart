import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<dynamic> _services = [];
  bool _isLoading = false;
  String? _nextPageUrl; // Stocke le lien "next" de Django

  List<dynamic> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.get('/services/');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _services = data['results']; // Django met la liste dans 'results'
      _nextPageUrl = data['next']; // Et le lien suivant dans 'next'
    }

    _isLoading = false;
    notifyListeners();
  }
}