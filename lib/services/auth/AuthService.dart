import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_cityweather_front/services/auth/AuthException.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://city-weather-api.vercel.app',
  );

  final http.Client _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: _headers,
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw AuthException(
      data['message']?.toString() ?? 'Échec de la requête',
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };
}
