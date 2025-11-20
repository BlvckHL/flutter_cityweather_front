

import 'package:flutter/material.dart';
import 'package:tp_flutter_cityweather/models/MyGeoposition.dart';
import 'package:tp_flutter_cityweather/services/LocationService.dart';

class CitySearchDialog extends StatefulWidget {
  final Function(GeoPosition) onCitySelected;

  const CitySearchDialog({Key? key, required this.onCitySelected}) : super(key: key);

  @override
  _CitySearchDialogState createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<CitySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<GeoPosition> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rechercher une ville'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nom de la ville',
                hintText: 'Ex: Paris, Londres, New York...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _searchCities(value);
                } else {
                  setState(() {
                    _searchResults = [];
                    _errorMessage = '';
                  });
                }
              },
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              )
            else if (_searchResults.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final city = _searchResults[index];
                    return ListTile(
                      leading: Icon(Icons.location_city),
                      title: Text(city.city),
                      subtitle: Text(
                        'Lat: ${city.latitude.toStringAsFixed(4)}, '
                        'Lon: ${city.longitude.toStringAsFixed(4)}'
                      ),
                      onTap: () => widget.onCitySelected(city),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
      ],
    );
  }

  void _searchCities(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await LocationService().searchCities(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'Aucune ville trouvée';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la recherche: $e';
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Version page complète pour navigation
class CitySearchPage extends StatefulWidget {
  final Function(GeoPosition) onCitySelected;

  const CitySearchPage({Key? key, required this.onCitySelected}) : super(key: key);

  @override
  _CitySearchPageState createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<GeoPosition> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechercher une ville'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nom de la ville',
                hintText: 'Ex: Paris, Londres, New York...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _searchCities(value);
                } else {
                  setState(() {
                    _searchResults = [];
                    _errorMessage = '';
                  });
                }
              },
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage, style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchCities(_searchController.text),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.length >= 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune ville trouvée', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tapez le nom d\'une ville pour commencer la recherche',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.location_city),
            ),
            title: Text(city.city, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Latitude: ${city.latitude.toStringAsFixed(4)}\n'
              'Longitude: ${city.longitude.toStringAsFixed(4)}'
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              widget.onCitySelected(city);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _searchCities(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await LocationService().searchCities(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la recherche: $e';
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}