class ApiResponse {
  final String timezone;
  final CurrentWeather current;
  final List<DailyWeather> daily;

  ApiResponse({
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> map) {
    final currentMap =
        (map['current'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return ApiResponse(
      timezone: map['timezone'] ?? 'Europe/Paris',
      current: CurrentWeather.fromJson(currentMap),
      daily: _buildDailyWeather(map),
    );
  }

  static List<DailyWeather> _buildDailyWeather(Map<String, dynamic> map) {
    final dailyData =
        (map['daily'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final time = List<String>.from(dailyData['time'] ?? const []);
    final minTemps = List<num>.from(
      dailyData['temperature_2m_min'] ?? const [],
    );
    final maxTemps = List<num>.from(
      dailyData['temperature_2m_max'] ?? const [],
    );
    final precipitation = List<num>.from(
      dailyData['precipitation_sum'] ?? const [],
    );
    final codes = List<num>.from(dailyData['weather_code'] ?? const []);

    final List<DailyWeather> result = [];
    for (var i = 0; i < time.length; i++) {
      result.add(
        DailyWeather(
          date: DateTime.tryParse(time[i]) ?? DateTime.now(),
          minTemperature: i < minTemps.length ? minTemps[i].toDouble() : 0,
          maxTemperature: i < maxTemps.length ? maxTemps[i].toDouble() : 0,
          precipitation: i < precipitation.length
              ? precipitation[i].toDouble()
              : 0,
          weatherCode: i < codes.length ? codes[i].toInt() : 0,
        ),
      );
    }
    return result;
  }
}

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final int weatherCode;

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> map) {
    return CurrentWeather(
      time: DateTime.tryParse(map['time'] ?? '') ?? DateTime.now(),
      temperature: (map['temperature_2m'] ?? 0).toDouble(),
      windSpeed: (map['wind_speed_10m'] ?? 0).toDouble(),
      weatherCode: (map['weather_code'] ?? 0).toInt(),
    );
  }
}

class DailyWeather {
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final double precipitation;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.precipitation,
    required this.weatherCode,
  });
}
