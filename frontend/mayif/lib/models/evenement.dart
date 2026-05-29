import 'package:intl/intl.dart';

class Evenement {
  final int id;
  final String titre;
  final String description;
  final String typeEvenement;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String lieu;
  final double? latitude;
  final double? longitude;
  final String? image;
  final bool estActif;

  Evenement({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeEvenement,
    required this.dateDebut,
    this.dateFin,
    required this.lieu,
    this.latitude,
    this.longitude,
    this.image,
    required this.estActif,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      id: json['id'],
      titre: json['titre'],
      description: json['description'] ?? '',
      typeEvenement: json['type_evenement'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      lieu: json['lieu'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      image: json['image'],
      estActif: json['est_actif'] ?? true,
    );
  }

  String get dateAffiche {
    final fmt = DateFormat('dd MMM yyyy à HH:mm');
    if (dateFin == null) return fmt.format(dateDebut);
    return '${fmt.format(dateDebut)} - ${fmt.format(dateFin!)}';
  }
}
