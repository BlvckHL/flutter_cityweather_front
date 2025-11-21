import 'package:flutter_cityweather_front/models/AppUser.dart';
import 'package:flutter_cityweather_front/services/auth/AuthException.dart';
import 'package:flutter_cityweather_front/services/auth/AuthService.dart';
import 'package:flutter_cityweather_front/services/auth/AuthSession.dart';
import 'package:flutter_cityweather_front/services/auth/AuthTokens.dart';
import 'package:flutter_cityweather_front/services/auth/JwtUtils.dart';
import 'package:flutter_cityweather_front/services/auth/TokenStorage.dart';

class AuthRepository {
  AuthRepository({AuthService? service, TokenStorage? storage})
    : _service = service ?? AuthService(),
      _storage = storage ?? TokenStorage();

  final AuthService _service;
  final TokenStorage _storage;

  Future<AuthSession> login(String email, String password) async {
    final json = await _service.login(email: email, password: password);
    final session = _mapSession(json, fallbackEmail: email);
    await _storage.persistSession(session);
    return session;
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final json = await _service.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    final session = _mapSession(json);
    await _storage.persistSession(session);
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final stored = await _storage.readSession();
    if (stored == null) {
      return null;
    }
    if (!stored.tokens.isExpired) {
      return stored;
    }
    try {
      final refreshed = await _refresh(stored.tokens.refreshToken);
      final session = stored.copyWith(tokens: refreshed);
      await _storage.persistSession(session);
      return session;
    } on AuthException {
      await _storage.clear();
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
  }

  Future<AuthTokens> _refresh(String refreshToken) async {
    final json = await _service.refresh(refreshToken);
    return _mapTokens(json);
  }

  AuthSession _mapSession(Map<String, dynamic> json, {String? fallbackEmail}) {
    final tokens = _mapTokens(json);
    AppUser? user;
    if (json['user'] != null) {
      user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
    } else {
      final payload = JwtUtils.decodePayload(tokens.accessToken);
      user = AppUser.fromJson({
        'id': payload['sub'] ?? '',
        'email': payload['email'] ?? fallbackEmail ?? '',
        'firstName': payload['firstName'],
        'lastName': payload['lastName'],
      });
    }
    return AuthSession(tokens: tokens, user: user);
  }

  AuthTokens _mapTokens(Map<String, dynamic> json) {
    final access = json['access_token']?.toString();
    final refresh = json['refresh_token']?.toString();
    if (access == null || refresh == null) {
      throw const AuthException('Réponse inattendue du serveur');
    }
    final expiresAt = JwtUtils.extractExpiry(access);
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiresAt,
    );
  }
}
