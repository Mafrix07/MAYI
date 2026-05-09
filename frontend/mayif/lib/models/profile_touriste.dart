class ProfileTouriste {
  final String? photo;
  final String? bio;
  final String? preferences;

  ProfileTouriste({
    this.photo,
    this.bio,
    this.preferences,
  });

  factory ProfileTouriste.fromJson(Map<String, dynamic> json) {
    return ProfileTouriste(
      photo: json['photo'], // Django renvoie l'URL absolue ici
      bio: json['bio'],
      preferences: json['preferences'],
    );
  }
}