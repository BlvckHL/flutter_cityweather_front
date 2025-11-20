
import 'package:flutter_cityweather_front/models/MyGeoposition.dart';
import 'package:flutter_cityweather_front/services/ApiResponse.dart';
import 'package:flutter_cityweather_front/services/OpenMeteoService.dart';

class ApiService {
  final OpenMeteoService _openMeteoService = OpenMeteoService();

  Future<Map<String, dynamic>?> getWeatherData(GeoPosition position) async {
    return await _openMeteoService.getWeatherForecast(position);
  }

  Future<ApiResponse?> CallApi(GeoPosition position) async {
    final weatherData = await getWeatherData(position);
    if (weatherData != null) {
      return ApiResponse.fromJson(weatherData);
    }
    return null;
  }
}