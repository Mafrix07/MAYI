class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? role;
  final Map<String, dynamic>? profilTouriste;
  final Map<String, dynamic>? profilProfessionnel;


  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.role,
    this.profilTouriste,
    this.profilProfessionnel,


  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      role: json['role'],
      profilTouriste: json['profil_touriste'],
      profilProfessionnel: json['profil_professionnel'],


    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
    };
  }
  String? get photoUrl => profilTouriste?['photo'] ?? profilProfessionnel?['photo'];
}
