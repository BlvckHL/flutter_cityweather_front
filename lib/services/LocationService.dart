import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:tp_flutter_cityweather/models/MyGeoposition.dart';
import 'package:tp_flutter_cityweather/services/OpenMeteoService.dart';

class LocationService {
  final OpenMeteoService _openMeteoService = OpenMeteoService();

  // get position
  Future<LocationData?> getPosition() async {
    try {
      Location location = Location();

      // Vérifier les permissions
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      return await location.getLocation();
    } on PlatformException catch (error) {
      return null;
    }
  }

  // Convertir position en ville (utilise Open-Meteo geocoding inverse si nécessaire)
  Future<GeoPosition?> getCity() async {
    final position = await getPosition();
    if (position == null) {
      return null;
    }
    final lat = position.latitude ?? 0;
    final lon = position.longitude ?? 0;

    // Pour l'instant, retourner juste les coordonnées
    // Open-Meteo n'a pas de reverse geocoding direct
    return GeoPosition(
      city: "Position actuelle",
      longitude: lon,
      latitude: lat,
    );
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
