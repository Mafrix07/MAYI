class Service {
  final int id;
  final String titre;
  final String description;
  final String categorie;
  final double prix;
  final String? imagePrincipale;
  final String ville;
  final double noteMoyenne;
  final bool estDisponible;
  final double montantAcompte;
  final double? latitude;
  final double? longitude;

  Service({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.prix,
    this.imagePrincipale,
    required this.ville,
    required this.noteMoyenne,
    required this.estDisponible,
    required this.montantAcompte,
    this.latitude,
    this.longitude,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    String? img;
    if (json['photo_principale'] != null) {
      img = json['photo_principale']['image'];
    }

    return Service(
      id: json['id'],
      titre: json['nom'] ?? 'Sans nom',
      description: json['description'] ?? '',
      categorie: json['type_service'] ?? 'SERVICE',
      prix: double.parse((json['prix'] ?? 0).toString()),
      imagePrincipale: img,
      ville: json['adresse'] ?? 'Togo',
      noteMoyenne: double.parse((json['note_moyenne'] ?? 0).toString()),
      estDisponible: json['est_actif'] ?? true,
      montantAcompte: double.parse((json['montant_acompte'] ?? 5000).toString()),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }
}
