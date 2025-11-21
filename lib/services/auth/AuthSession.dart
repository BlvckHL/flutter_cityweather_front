import 'package:flutter_cityweather_front/models/AppUser.dart';
import 'package:flutter_cityweather_front/services/auth/AuthTokens.dart';

class AuthSession {
  final AuthTokens tokens;
  final AppUser? user;

  const AuthSession({required this.tokens, this.user});

  bool get isValid => !tokens.isExpired;

  AuthSession copyWith({AuthTokens? tokens, AppUser? user}) {
    return AuthSession(tokens: tokens ?? this.tokens, user: user ?? this.user);
  }
}
