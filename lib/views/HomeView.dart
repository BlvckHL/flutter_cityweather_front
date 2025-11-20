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
import 'package:flutter_cityweather_front/views/WeatherForecastView.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeView> {
  GeoPosition? userPosition;
  GeoPosition? selectedPosition;
  ApiResponse? apiResponse;
  List<String> savedCities = [];
  bool isLoadingLocation = false;
  bool isLoadingForecast = false;

  @override
  void initState() {
    super.initState();
    getUserLocation();
    _refreshSavedCities();
  }

  Widget _buildForecastBody() {
    if (isLoadingForecast) {
      return const Center(child: CircularProgressIndicator());
    }
    if (selectedPosition == null) {
      return _EmptyState(
        icon: Icons.travel_explore,
        message:
            "Sélectionnez une ville ou utilisez votre position GPS pour démarrer.",
      );
    }
    if (apiResponse == null) {
      return _EmptyState(
        icon: Icons.cloud_off,
        message: "Aucune donnée météo pour le moment.",
      );
    }
    return WeatherForecastView(forecast: apiResponse!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedPosition?.city ?? "CityWeather"),
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
          if (selectedPosition != null)
            IconButton(icon: Icon(Icons.map), onPressed: () => _openInMaps()),
        ],
      ),
      drawer: MyDrawer(
        myPosition: userPosition,
        cities: savedCities,
        onTap: _onFavoriteSelected,
        onDelete: _removeCity,
      ),
      body: Column(
        children: [
          if (selectedPosition != null)
            _LocationHeader(
              position: selectedPosition!,
              onOpenMap: _openInMaps,
            ),
          Expanded(child: _buildForecastBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCitySearchDialog,
        tooltip: "Rechercher une ville",
        child: const Icon(Icons.add_location_alt),
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
      selectedPosition = position;
    });
    _loadForecast();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${position.city} sélectionnée"),
        action: SnackBarAction(
          label: "Ajouter",
          onPressed: () => onAddCity(position.city),
        ),
      ),
    );
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
          selectedPosition = loc;
        });
        Sentry.captureMessage("GPS location obtained: ${loc.city}");
        _loadForecast();
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
    if (selectedPosition != null) {
      try {
        await MapLauncherService.openMap(selectedPosition!);
      } catch (e) {
        if (!mounted) return;
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
          selectedPosition = loc;
        });
        Sentry.captureMessage(
          "User location obtained: ${loc.city}, Latitude: ${loc.latitude}, Longitude: ${loc.longitude}",
        );
        _loadForecast();
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

  _loadForecast() async {
    if (selectedPosition == null) return;
    setState(() {
      isLoadingForecast = true;
    });
    try {
      final result = await ApiService().fetchForecast(selectedPosition!);
      if (!mounted) return;
      setState(() {
        apiResponse = result;
      });
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la récupération de la météo."),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingForecast = false;
        });
      }
    }
  }

  //New city
  _onFavoriteSelected(String string) async {
    Navigator.of(context).pop();
    _dismissKeyboard();
    if (string == userPosition?.city && userPosition != null) {
      selectedPosition = userPosition;
      _loadForecast();
    } else {
      selectedPosition = await LocationService().getCoordsFromCity(string);
      if (selectedPosition != null) {
        _loadForecast();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible de trouver la ville $string")),
        );
      }
    }
  }

  _dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  //Add city
  onAddCity(String string) async {
    final transaction = Sentry.startTransaction('Add City', 'app.action');

    try {
      final span = transaction.startChild('database.write');
      span.setData('city', string);
      await DataService().addCity(string);
      span.finish();

      transaction.finish(status: const SpanStatus.ok());
      await _refreshSavedCities();
    } catch (error, stackTrace) {
      transaction.finish(status: const SpanStatus.internalError());
      Sentry.captureException(error, stackTrace: stackTrace);
      Sentry.captureMessage("Error occurred while adding city: $error");
    } finally {
      Sentry.captureMessage("City added: $string");
      _dismissKeyboard();
    }
  }

  //remouve city
  _removeCity(String string) async {
    await DataService().removeCity(string);
    await _refreshSavedCities();
  }

  //Update city
  _refreshSavedCities() async {
    savedCities = await DataService().getCities();
    setState(() {});
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  final GeoPosition position;
  final VoidCallback onOpenMap;

  const _LocationHeader({required this.position, required this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${position.city}\nLat: ${position.latitude.toStringAsFixed(4)}, "
              "Lon: ${position.longitude.toStringAsFixed(4)}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: onOpenMap,
            tooltip: "Ouvrir dans les cartes",
          ),
        ],
      ),
    );
  }
}
