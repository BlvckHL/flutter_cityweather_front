import 'package:flutter_cityweather_front/services/DataConverter.dart';

class ApiResponse {
  String cod;
  int message;
  int cnt;
  List<Forcast> list;

  ApiResponse(this.cod, this.message, this.cnt, this.list);
  ApiResponse.fromJson(Map<String, dynamic> map)
    : cod = map["cod"],
      message = map["message"] ?? 0,
      cnt = map["cnt"] ?? 0,
      list = DataConverter()
          .listMappable(map["list"])
          .map((e) => Forcast.fromJson(e))
          .toList();
}
//List<Forcast> list;

class Forcast {
  final int dt;
  Main main;
  List<Weather> weather;
  Wind wind;
  Clouds clouds;
  final int visibility;
  String dt_txt;

  Forcast(
    this.dt,
    this.main,
    this.weather,
    this.wind,
    this.clouds,
    this.dt_txt,
    this.visibility,
  );
  Forcast.fromJson(Map<String, dynamic> map)
    : dt = map["dt"] ?? 0,
      main = Main.fromJson(map["main"]),
      weather = DataConverter()
          .listMappable(map["weather"])
          .map((e) => Weather.fromJson(e))
          .toList(),
      wind = Wind.fromJson(map["wind"]),
      clouds = Clouds.fromJson(map["clouds"]),
      visibility = map["visibility"] ?? 0,
      dt_txt = map["dt_txt"];
}

class Main {
  double temp;
  double feels_like;
  double temp_min;
  double temp_max;
  double pressure;
  double sea_level;
  double grnd_level;
  double humidity;
  double temp_kf;

  Main(
    this.temp,
    this.feels_like,
    this.temp_min,
    this.temp_max,
    this.pressure,
    this.sea_level,
    this.grnd_level,
    this.humidity,
    this.temp_kf,
  );

  Main.fromJson(Map<String, dynamic> map)
    : temp = map["temp"].toDouble(),
      feels_like = map["feels_like"].toDouble(),
      temp_min = map["temp_min"].toDouble(),
      temp_max = map["temp_max"].toDouble(),
      pressure = map["pressure"].toDouble(),
      sea_level = map["sea_level"].toDouble(),
      grnd_level = map["grnd_level"].toDouble(),
      humidity = map["humidity"].toDouble(),
      temp_kf = map["temp_kf"].toDouble();
}

class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather(this.id, this.main, this.description, this.icon);
  Weather.fromJson(Map<String, dynamic> map)
    : id = map["id"],
      main = map["main"],
      description = map["description"],
      icon = map["icon"];
}

class Clouds {
  int all;

  Clouds(this.all);
  Clouds.fromJson(Map<String, dynamic> map) : all = map["all"];
}

class Wind {
  double speed;
  int deg;
  double gust;

  Wind(this.speed, this.deg, this.gust);

  Wind.fromJson(Map<String, dynamic> map)
    : speed = (map["speed"] is int)
          ? (map["speed"] as int).toDouble()
          : map["speed"],
      deg = map["deg"],
      gust = (map["gust"] is int)
          ? (map["gust"] as int).toDouble()
          : map["gust"];
}
