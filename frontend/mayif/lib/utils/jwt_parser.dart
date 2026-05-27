import 'dart:convert';

class JwtParser {
  static Map<String, dynamic> parse(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid token');
    // On décode la partie centrale (payload)
    String payload = parts[1];
    String normalized = base64Url.normalize(payload);
    return json.decode(utf8.decode(base64Url.decode(normalized)));



  }
}
