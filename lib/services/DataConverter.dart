
import 'package:flutter_cityweather_front/services/ApiResponse.dart';
import 'package:flutter_cityweather_front/services/GroupedWeather.dart';

class DataConverter {
  List<GroupedWeather> byDay(ApiResponse response) {
    return response.daily
        .map(
          (daily) => GroupedWeather(
            minTemperature: daily.minTemperature,
            maxTemperature: daily.maxTemperature,
            precipitation: daily.precipitation,
            dayLabel: dayFromInt(daily.date.weekday),
            date: daily.date,
            weatherCode: daily.weatherCode,
          ),
        )
        .toList();
  }

  String dayFromInt(int day) {
    switch (day) {
      case 1:
        return "Lundi";
      case 2:
        return "Mardi";
      case 3:
        return "Mercredi";
      case 4:
        return "Jeudi";
      case 5:
        return "Vendredi";
      case 6:
        return "Samedi";
      default:
        return "Dimanche";
    }
  }

  String descriptionFromWeatherCode(int code) {
    if (code == 0) return "Ciel dégagé";
    if (code == 1 || code == 2) return "Peu nuageux";
    if (code == 3) return "Ciel couvert";
    if (code == 45 || code == 48) return "Brouillard";
    if (code == 51 || code == 53 || code == 55) return "Bruine";
    if (code == 56 || code == 57) return "Bruine verglaçante";
    if (code == 61 || code == 63 || code == 65) return "Pluie";
    if (code == 66 || code == 67) return "Pluie verglaçante";
    if (code == 71 || code == 73 || code == 75) return "Neige";
    if (code == 77) return "Grains de neige";
    if (code == 80 || code == 81 || code == 82) return "Averses";
    if (code == 85 || code == 86) return "Averses de neige";
    if (code == 95) return "Orage";
    if (code == 96 || code == 99) return "Orage avec grêle";
    return "Conditions inconnues";
  }
}