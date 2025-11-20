
import 'package:flutter_cityweather_front/models/MyGeoposition.dart';
import 'package:flutter_cityweather_front/services/ApiResponse.dart';
import 'package:flutter_cityweather_front/services/OpenMeteoService.dart';

class ApiService {
  final OpenMeteoService _openMeteoService = OpenMeteoService();

  Future<ApiResponse?> fetchForecast(GeoPosition position) async {
    final weatherData = await _openMeteoService.getWeatherForecast(position);
    if (weatherData == null) {
      return null;
    }
    return ApiResponse.fromJson(weatherData);
  }
}