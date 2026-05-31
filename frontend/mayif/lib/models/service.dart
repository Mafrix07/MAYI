class Service {
  final int id;
  final String titre;
  final String description;
  final String categorie;
  final double prix;
  final String? imagePrincipale;
  final List<String> photos;
  final String ville;
  final double noteMoyenne;
  final bool estDisponible;
  final double montantAcompte;
  final double? latitude;
  final double? longitude;
  final String? horaireOuverture;
  final String? horaireFermeture;

  Service({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.prix,
    this.imagePrincipale,
    this.photos = const [],
    required this.ville,
    required this.noteMoyenne,
    required this.estDisponible,
    required this.montantAcompte,
    this.latitude,
    this.longitude,
    this.horaireOuverture,
    this.horaireFermeture,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    String? img;
    if (json['photo_principale'] != null) {
      img = json['photo_principale']['image'];
    }

    // Parse la galerie complète
    final photosList = <String>[];
    if (json['photos'] != null) {
      for (final p in (json['photos'] as List<dynamic>)) {
        if (p['image'] != null) photosList.add(p['image'].toString());
      }
    }
    if (photosList.isEmpty && img != null) photosList.add(img);

    return Service(
      id: json['id'],
      titre: json['nom'] ?? 'Sans nom',
      description: json['description'] ?? '',
      categorie: json['type_service'] ?? 'SERVICE',
      prix: double.parse((json['prix'] ?? 0).toString()),
      imagePrincipale: img,
      photos: photosList,
      ville: json['adresse'] ?? 'Togo',
      noteMoyenne: double.parse((json['note_moyenne'] ?? 0).toString()),
      estDisponible: json['est_actif'] ?? true,
      montantAcompte: double.parse((json['montant_acompte'] ?? 5000).toString()),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      horaireOuverture: json['horaire_ouverture'],
      horaireFermeture: json['horaire_fermeture'],
    );
  }
}
