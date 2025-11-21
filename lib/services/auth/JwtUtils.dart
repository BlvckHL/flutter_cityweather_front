import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Jeton JWT invalide');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(
      base64Url.decode(normalized),
      allowMalformed: true,
    );
    final Map<String, dynamic> jsonMap = jsonDecode(decoded);
    return jsonMap;
  }

  static DateTime extractExpiry(String token) {
    final json = decodePayload(token);
    final exp = json['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    } else if (exp is String) {
      return DateTime.fromMillisecondsSinceEpoch(
        int.parse(exp) * 1000,
        isUtc: true,
      );
    }
    throw const FormatException(
      'Impossible de récupérer la date d\'expiration',
    );
  }
}
