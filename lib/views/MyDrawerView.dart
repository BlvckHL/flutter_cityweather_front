import 'package:flutter/material.dart';
import 'package:flutter_cityweather_front/models/AppUser.dart';
import 'package:flutter_cityweather_front/models/MyGeoposition.dart';

class MyDrawer extends StatelessWidget {
  final GeoPosition? myPosition;
  final List<String> cities;
  final Function(String) onTap;
  final Function(String) onDelete;
  final AppUser? currentUser;
  final VoidCallback? onLogout;

  const MyDrawer({
    super.key,
    required this.myPosition,
    required this.cities,
    required this.onTap,
    required this.onDelete,
    this.currentUser,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = (myPosition == null)
        ? cities.length + 1
        : cities.length + 2;
    // Ajouter un item pour "aucune ville" si la liste est vide
    final hasNoCities = cities.isEmpty && myPosition == null;
    final finalItemCount = hasNoCities ? 2 : itemCount;
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: ((context, index) {
                if (index == 0) {
                  return header(context);
                }
                if (hasNoCities && index == 1) {
                  return const ListTile(
                    title: Text("Aucune ville ajoutée"),
                    subtitle: Text(
                      "Recherchez une ville pour l'ajouter à vos favoris",
                    ),
                    leading: Icon(Icons.info_outline),
                  );
                }
                if (index == 1 && myPosition != null) {
                  return tappable(myPosition!.city, false);
                }
                if (myPosition == null) {
                  return tappable(cities[index - 1], true);
                }
                return tappable(cities[index - 2], true);
              }),
              separatorBuilder: ((context, index) => const Divider()),
              itemCount: finalItemCount,
            ),
          ),
          const Divider(height: 1),
          if (onLogout != null)
            SafeArea(
              top: false,
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Se déconnecter'),
                onTap: onLogout,
              ),
            ),
        ],
      ),
    );
  }

  DrawerHeader header(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            currentUser?.displayName ?? "Mes villes",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (currentUser?.email != null)
            Text(currentUser!.email, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  ListTile tappable(String string, bool canDelete) {
    return ListTile(
      title: Text(string),
      onTap: (() => onTap(string)),
      trailing: (canDelete)
          ? IconButton(
              onPressed: (() => onDelete(string)),
              icon: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
