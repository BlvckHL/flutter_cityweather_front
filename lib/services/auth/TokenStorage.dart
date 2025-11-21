import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_cityweather_front/models/AppUser.dart';
import 'package:flutter_cityweather_front/services/auth/AuthSession.dart';
import 'package:flutter_cityweather_front/services/auth/AuthTokens.dart';

class TokenStorage {
  static const _keyAccess = 'auth_access_token';
  static const _keyRefresh = 'auth_refresh_token';
  static const _keyExpiry = 'auth_access_expiry';
  static const _keyUser = 'auth_user';

  Future<void> persistSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccess, session.tokens.accessToken);
    await prefs.setString(_keyRefresh, session.tokens.refreshToken);
    await prefs.setString(
      _keyExpiry,
      session.tokens.expiresAt.toUtc().toIso8601String(),
    );
    if (session.user != null) {
      await prefs.setString(_keyUser, jsonEncode(session.user!.toJson()));
    } else {
      await prefs.remove(_keyUser);
    }
  }

  Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_keyAccess);
    final refresh = prefs.getString(_keyRefresh);
    final expiry = prefs.getString(_keyExpiry);
    if (access == null || refresh == null || expiry == null) {
      return null;
    }
    final tokens = AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: DateTime.parse(expiry).toUtc(),
    );
    final userJson = prefs.getString(_keyUser);
    AppUser? user;
    if (userJson != null) {
      user = AppUser.fromJson(jsonDecode(userJson));
    }
    return AuthSession(tokens: tokens, user: user);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccess);
    await prefs.remove(_keyRefresh);
    await prefs.remove(_keyExpiry);
    await prefs.remove(_keyUser);
  }
}
