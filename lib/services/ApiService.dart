
import 'package:tp_flutter_cityweather/models/MyGeoposition.dart';
import 'package:tp_flutter_cityweather/services/ApiResponse.dart';
import 'package:tp_flutter_cityweather/services/OpenMeteoService.dart';

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