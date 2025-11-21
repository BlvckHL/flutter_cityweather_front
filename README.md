# CityWeather - Application Mobile Flutter

Application mobile développée en Flutter permettant de consulter la météo de différentes villes avec géolocalisation et gestion de favoris.

## 📱 Fonctionnalités

### Authentification
- Page de connexion avec email/mot de passe
- Validation des champs de saisie
- Redirection automatique après connexion

### Météo
- **Météo actuelle** : Affichage des conditions météorologiques en temps réel
- **Prévisions** : Consultation des prévisions météorologiques
- **Géolocalisation** : Météo basée sur votre position GPS actuelle
- **Recherche de villes** : Interface de recherche intuitive

### Gestion des villes
- **Favoris** : Sauvegarde de vos villes préférées
- **Menu latéral** : Accès rapide à vos villes sauvegardées
- **Suppression** : Gestion des villes favorites
- **Position GPS** : Affichage automatique de votre ville actuelle

### Navigation
- **Intégration cartes** : Ouverture dans l'application de cartes native
- **Interface responsive** : Design adapté à tous les écrans
- **Navigation intuitive** : FloatingActionButton pour actions rapides

## 🏗️ Architecture

```
lib/
├── models/
│   └── MyGeoposition.dart          # Modèle de géoposition
├── services/
│   ├── ApiResponse.dart            # Modèle de réponse API
│   ├── ApiService.dart             # Service API météo
│   ├── DataService.dart            # Stockage local des données
│   ├── LocationService.dart        # Service de géolocalisation
│   └── MapLauncherService.dart     # Service cartes
└── views/
    ├── LoginView.dart              # Page de connexion
    ├── HomeView.dart               # Page principale
    ├── MyDrawerView.dart           # Menu latéral
    ├── CitySearch.dart             # Recherche de villes
    └── WeatherForecastView.dart    # Affichage météo
```

## 🚀 Installation

### Prérequis
- Flutter SDK (version 3.0+)
- Dart SDK
- Android Studio / VS Code
- Émulateur Android/iOS ou appareil physique

### Configuration

1. **Cloner le projet**
```bash
git clone <url-du-repo>
cd flutter_cityweather_front
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration des permissions**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`)
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

   **iOS** (`ios/Runner/Info.plist`)
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Cette app utilise la localisation pour afficher la météo locale</string>
   ```

4. **Lancer l'application**
```bash
flutter run
```

## 📦 Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  sentry_flutter: ^7.0.0      # Monitoring et logs
  geolocator: ^9.0.0          # Géolocalisation
  map_launcher: ^2.0.0        # Intégration cartes
  http: ^0.13.0               # Requêtes HTTP
  shared_preferences: ^2.0.0  # Stockage local
```

## 🎯 Utilisation

### Première connexion
1. Saisissez votre email et mot de passe
2. Cliquez sur "Se connecter"
3. L'app vous redirige vers l'écran principal

### Consulter la météo
1. **GPS** : Appuyez sur l'icône 📍 pour votre position
2. **Recherche** : Utilisez 🔍 ou le bouton ➕ pour chercher une ville
3. **Favoris** : Ouvrez le menu latéral pour accéder à vos villes sauvegardées

### Gérer les favoris
1. Recherchez une ville
2. Cliquez sur "Ajouter" dans la notification
3. La ville apparaît dans le menu latéral
4. Utilisez l'icône 🗑️ pour supprimer

## 🔧 Services

### ApiService
Gestion des appels API météo avec gestion d'erreurs intégrée.

### LocationService
- Récupération GPS
- Géocodage inverse (coordonnées → ville)
- Géocodage (ville → coordonnées)

### DataService
Persistance locale des villes favorites avec SharedPreferences.

### MapLauncherService
Ouverture dans les applications de cartes natives (Google Maps, Apple Maps).

## 🐛 Debugging

L'application utilise Sentry pour le monitoring :
- Logs automatiques des actions utilisateur
- Capture des exceptions
- Suivi des performances

## 📱 Captures d'écran

- **Login** : Interface de connexion sécurisée
- **Home** : Météo avec position GPS et favoris
- **Drawer** : Menu latéral avec villes sauvegardées
- **Search** : Recherche de villes en temps réel

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est développé dans le cadre d'un projet académique Ynov.
