class Constants {
  // Adresse IP pour l'émulateur Android (pointe vers le localhost du PC)
  static const String baseUrl = "http://10.0.2.2:8000/api/";
  
  // Endpoints spécifiques
  static const String loginUrl = "token/";
  static const String refreshUrl = "token/refresh/";
  static const String registerUrl = "users/inscription/";
}
