import 'package:flutter/foundation.dart';
import 'package:flutter_cityweather_front/models/MyGeoposition.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncherService {
  static Future<void> openMap(GeoPosition position) async {
    final lat = position.latitude;
    final lon = position.longitude;

    // URL pour Google Maps
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
    );

    // URL pour Apple Maps (iOS)
    final appleMapsUrl = Uri.parse("https://maps.apple.com/?q=$lat,$lon");

    try {
      // Essayer Google Maps d'abord
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir les cartes';
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture des cartes: $e');
      rethrow;
    }
  }
}
