class Avis {
  final int id;
  final String auteurNom;
  final double note;
  final String commentaire;
  final String dateCreation;

  Avis({
    required this.id,
    required this.auteurNom,
    required this.note,
    required this.commentaire,
    required this.dateCreation,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    // Gestion de l'auteur qui peut être un objet ou juste un nom selon le serializer Django
    String auteur = 'Anonyme';
    if (json['auteur'] != null) {
      if (json['auteur'] is Map) {
        auteur = '${json['auteur']['first_name'] ?? ''} ${json['auteur']['last_name'] ?? ''}'.trim();
        if (auteur.isEmpty) auteur = json['auteur']['username'] ?? 'Anonyme';
      } else {
        auteur = json['auteur'].toString();
      }
    }

    return Avis(
      id: json['id'],
      auteurNom: auteur,
      note: double.parse((json['note'] ?? 0).toString()),
      commentaire: json['commentaire'] ?? '',
      dateCreation: json['date_creation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'commentaire': commentaire,
    };
  }
}
