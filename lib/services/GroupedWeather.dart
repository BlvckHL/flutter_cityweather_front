class GroupedWeather {
  final double minTemperature;
  final double maxTemperature;
  final double precipitation;
  final String dayLabel;
  final DateTime date;
  final int weatherCode;

  GroupedWeather({
    required this.minTemperature,
    required this.maxTemperature,
    required this.precipitation,
    required this.dayLabel,
    required this.date,
    required this.weatherCode,
  });

  String minAndMax() {
    return "Min: ${minTemperature.toStringAsFixed(1)}°C - "
        "Max: ${maxTemperature.toStringAsFixed(1)}°C";
  }
}