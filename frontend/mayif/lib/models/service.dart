class Service {
  final int id;
  final String titre;
  final String description;
  final String categorie;
  final double prixTotal;
  final double montantAcompte;
  final String adresse;
  final String? imagePrincipale;
  final int prestataireId;

  Service({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.prixTotal,
    required this.montantAcompte,
    required this.adresse,
    this.imagePrincipale,
    required this.prestataireId,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      categorie: json['categorie'],
      prixTotal: double.parse(json['prix_total'].toString()),
      montantAcompte: double.parse(json['montant_acompte'].toString()),
      adresse: json['adresse'],
      imagePrincipale: json['image_principale'],
      prestataireId: json['prestataire'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'categorie': categorie,
      'prix_total': prixTotal,
      'montant_acompte': montantAcompte,
      'adresse': adresse,
      'image_principale': imagePrincipale,
      'prestataire': prestataireId,
    };
  }
}
