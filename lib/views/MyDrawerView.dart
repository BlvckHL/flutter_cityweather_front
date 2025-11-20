import 'package:flutter/material.dart';
import 'package:tp_flutter_cityweather/models/MyGeoposition.dart';

class MyDrawer extends StatelessWidget {

  GeoPosition ? myPosition;
  List <String> cities;
  Function(String) onTap;
  Function(String) onDelete;

  MyDrawer ({required this.myPosition, required this.cities, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final itemCount = (myPosition == null) ? cities.length + 1 : cities.length + 2;
    return Drawer(
      child: ListView.separated(
          itemBuilder: ((context, index) {
            if (index == 0) return header(context);
            if (index == 1 && myPosition != null) return tappable(myPosition!.city, false);
            if (myPosition == null) return tappable(cities[index - 1], true);
            return tappable(cities[index - 2], true);
          }),
          separatorBuilder: ((context, index) => const Divider()),
          itemCount: itemCount),
    );
  }

  DrawerHeader header(BuildContext context) {
    return DrawerHeader(child: Column(
      children: [
        Icon(Icons.location_on_outlined, size: 32, color: Theme.of(context).primaryColor,),
        const Text("Mes villes"),
      ],
    ));
  }

  ListTile tappable(String string, bool CanDelete) {
    return ListTile(
      title: Text(string),
      onTap: (() => onTap(string)),
      trailing: (CanDelete) ? IconButton(onPressed: (() => onDelete(string)),
          icon: const Icon(Icons.delete)): null,
    );
  }

}