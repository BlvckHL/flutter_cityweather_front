import 'dart:convert';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tp_flutter_cityweather/models/MyGeoposition.dart';
import 'package:http/http.dart' as http;

class OpenMeteoService {
  final String geocodingBaseUrl =
      "https://geocoding-api.open-meteo.com/v1/search";
  final String weatherBaseUrl = "https://api.open-meteo.com/v1/forecast";

  // Recherche de ville via géocodage
  Future<List<GeoPosition>> searchCities(String cityName) async {
    final query = "$geocodingBaseUrl?name=$cityName&count=5&language=fr";
    final uri = Uri.parse(query);

    final transaction = Sentry.startTransaction(
      'Geocoding API Call',
      'http.client',
    );

    try {
      final span = transaction.startChild('http.request');
      span.setData('url', query);
      span.setData('method', 'GET');

      Sentry.captureMessage("Calling Open-Meteo Geocoding API: $query");
      final response = await http.get(uri);

      span.setData('status_code', response.statusCode);
      span.finish();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        transaction.finish(status: const SpanStatus.ok());

        List<GeoPosition> cities = [];
        if (data['results'] != null) {
          for (var result in data['results']) {
            cities.add(
              GeoPosition(
                city: result['name'] ?? '',
                latitude: result['latitude']?.toDouble() ?? 0.0,
                longitude: result['longitude']?.toDouble() ?? 0.0,
              ),
            );
          }
        }
        return cities;
      } else {
        transaction.finish(status: const SpanStatus.internalError());
        Sentry.captureMessage("Geocoding API failed: ${response.statusCode}");
        return [];
      }
    } catch (error, stackTrace) {
      transaction.finish(status: const SpanStatus.internalError());
      Sentry.captureException(error, stackTrace: stackTrace);
      return [];
    }
  }

  // Récupération des données météo
  Future<Map<String, dynamic>?> getWeatherForecast(GeoPosition position) async {
    final query =
        "$weatherBaseUrl?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=Europe/Paris";
    final uri = Uri.parse(query);

    final transaction = Sentry.startTransaction(
      'Weather API Call',
      'http.client',
    );

    try {
      final span = transaction.startChild('http.request');
      span.setData('url', query);
      span.setData('method', 'GET');

      Sentry.captureMessage("Calling Open-Meteo Weather API: $query");
      final response = await http.get(uri);

      span.setData('status_code', response.statusCode);
      span.finish();

      if (response.statusCode == 200) {
        transaction.finish(status: const SpanStatus.ok());
        Sentry.captureMessage("Weather API response received successfully.");
        return json.decode(response.body);
      } else {
        transaction.finish(status: const SpanStatus.internalError());
        Sentry.captureMessage("Weather API failed: ${response.statusCode}");
        return null;
      }
    } catch (error, stackTrace) {
      transaction.finish(status: const SpanStatus.internalError());
      Sentry.captureException(error, stackTrace: stackTrace);
      return null;
    }
  }
}
