import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_cityweather_front/models/MyGeoposition.dart';
import 'package:flutter_cityweather_front/services/ApiResponse.dart';
import 'package:flutter_cityweather_front/services/ApiService.dart';
import 'package:flutter_cityweather_front/services/DataService.dart';
import 'package:flutter_cityweather_front/services/LocationService.dart';
import 'package:flutter_cityweather_front/services/MapLauncherService.dart';
import 'package:flutter_cityweather_front/views/CitySearch.dart';
import 'package:flutter_cityweather_front/views/MyDrawerView.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeView> {
  GeoPosition? userPosition;
  GeoPosition? CallPositionApi;
  ApiResponse? apiResponse;
  List<String> cities = [];
  bool isLoadingLocation = false;

  @override
  void initState() {
    getUserLocation();
    updateCities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(CallPositionApi?.city ?? "Ma meteo"),
        actions: [
          // Bouton pour rechercher une ville
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showCitySearchDialog(),
          ),
          // Bouton pour localisation GPS
          IconButton(
            icon: isLoadingLocation
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.my_location),
            onPressed: isLoadingLocation ? null : _getCurrentLocation,
          ),
          // Bouton pour ouvrir les cartes
          if (CallPositionApi != null)
            IconButton(icon: Icon(Icons.map), onPressed: () => _openInMaps()),
        ],
      ),
      drawer: MyDrawer(
        myPosition: userPosition,
        cities: cities,
        onTap: onTap,
        onDelete: remouveCity,
      ),
      body: Column(
        children: [
          // Informations sur la position actuelle
          if (CallPositionApi != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${CallPositionApi!.city}\nLat: ${CallPositionApi!.latitude.toStringAsFixed(4)}, Lon: ${CallPositionApi!.longitude.toStringAsFixed(4)}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.map_outlined),
                    onPressed: _openInMaps,
                    tooltip: "Ouvrir dans les cartes",
                  ),
                ],
              ),
            ),
          // AddCityView(onAddCity: onAddCity),
          // Expanded(
          //   child: (apiResponse == null)
          //     ? NNoDataView()
          //     : ForcastView(response: apiResponse!),
          // )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCitySearchDialog,
        child: Icon(Icons.add_location),
        tooltip: "Rechercher une ville",
      ),
    );
  }

  // Méthode pour afficher la recherche de ville
  void _showCitySearchDialog() {
    showDialog(
      context: context,
      builder: (context) => CitySearchDialog(
        onCitySelected: (GeoPosition position) {
          Navigator.of(context).pop();
          _selectCity(position);
        },
      ),
    );
  }

  // Sélectionner une ville depuis la recherche
  void _selectCity(GeoPosition position) {
    setState(() {
      CallPositionApi = position;
    });
    CallApi();
  }

  // Obtenir la position GPS actuelle
  void _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      Sentry.captureMessage("Getting current GPS location...");
      final loc = await LocationService().getCity();
      if (loc != null) {
        setState(() {
          userPosition = loc;
          CallPositionApi = loc;
        });
        Sentry.captureMessage("GPS location obtained: ${loc.city}");
        CallApi();
      } else {
        _showLocationError();
      }
    } catch (error) {
      Sentry.captureException(error);
      _showLocationError();
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  // Ouvrir dans l'application de cartes
  void _openInMaps() async {
    if (CallPositionApi != null) {
      try {
        await MapLauncherService.openMap(CallPositionApi!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ouvrir les cartes: $e")),
        );
      }
    }
  }

  void _showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Impossible d'obtenir votre position. Vérifiez vos permissions GPS.",
        ),
        action: SnackBarAction(
          label: "Réessayer",
          onPressed: _getCurrentLocation,
        ),
      ),
    );
  }

  getUserLocation() async {
    try {
      Sentry.captureMessage("Attempting to get user location...");
      final loc = await LocationService().getCity();
      if (loc != null) {
        setState(() {
          userPosition = loc;
          CallPositionApi = loc;
        });
        Sentry.captureMessage(
          "User location obtained: ${loc.city}, Latitude: ${loc.latitude}, Longitude: ${loc.longitude}",
        );
        CallApi();
      } else {
        Sentry.captureMessage("Failed to get user location: Location is null.");
      }
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
      Sentry.captureMessage(
        "Error occurred while getting user location: $error",
      );
    }
  }

  CallApi() async {
    if (CallPositionApi == null) return;
    apiResponse = await ApiService().CallApi(CallPositionApi!);
    setState(() {});
  }

  //New city
  onTap(String string) async {
    Navigator.of(context).pop();
    removeKeybord();
    if (string == userPosition?.city) {
      CallPositionApi = userPosition;
      CallApi();
    } else {
      CallPositionApi = await LocationService().getCoordsFromCity(string);
      CallApi();
    }
  }

  removeKeybord() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  //Add city
  onAddCity(String string) async {
    final transaction = Sentry.startTransaction('Add City', 'app.action');

    try {
      final span = transaction.startChild('database.write');
      span.setData('city', string);
      DataService().addCity(string).then((onSuccess) => updateCities());
      span.finish();

      transaction.finish(status: const SpanStatus.ok());
    } catch (error, stackTrace) {
      transaction.finish(status: const SpanStatus.internalError());
      Sentry.captureException(error, stackTrace: stackTrace);
      Sentry.captureMessage("Error occurred while adding city: $error");
    } finally {
      Sentry.captureMessage("City added: $string");
      removeKeybord();
    }
  }

  //remouve city
  remouveCity(String string) async {
    DataService().remouveCity(string).then((onSuccess) => updateCities());
  }

  //Update city
  updateCities() async {
    cities = await DataService().getCities();
    setState(() {});
  }
}
