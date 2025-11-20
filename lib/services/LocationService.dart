import 'package:geolocator/geolocator.dart';
import 'package:flutter_cityweather_front/models/MyGeoposition.dart';
import 'package:flutter_cityweather_front/services/OpenMeteoService.dart';

class LocationService {
  final OpenMeteoService _openMeteoService = OpenMeteoService();

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Convertir position GPS en ville (reverse geocoding Open-Meteo)
  Future<GeoPosition?> getCity() async {
    try {
      final position = await _determinePosition();
      if (position == null) {
        return null;
      }

      final reverse = await _openMeteoService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (reverse != null) {
        return reverse;
      }

      return GeoPosition(
        city: "Position actuelle",
        longitude: position.longitude,
        latitude: position.latitude,
      );
    } catch (_) {
      return null;
    }
  }

  // Rechercher une ville via Open-Meteo
  Future<List<GeoPosition>> searchCities(String cityName) async {
    return await _openMeteoService.searchCities(cityName);
  }

  // Obtenir les coordonnées d'une ville spécifique
  Future<GeoPosition?> getCoordsFromCity(String city) async {
    final cities = await searchCities(city);
    return cities.isNotEmpty ? cities.first : null;
  }
}
