import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Movilidad Bogotá',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapHomePage(),
    );
  }
}

/// Coordenadas aproximadas de Bogotá (centro del mapa).
const LatLng _bogotaCenter = LatLng(4.65, -74.1);

/// Ejemplo de “paradas GTFS” (capa de transporte).
const List<Map<String, dynamic>> _paradasGtfs = [
  {
    'id': 'P1',
    'nombre': 'Estación Calle 26',
    'lat': 4.6490,
    'lng': -74.0865,
  },
  {
    'id': 'P2',
    'nombre': 'Estación Calle 72',
    'lat': 4.6615,
    'lng': -74.0620,
  },
  {
    'id': 'P3',
    'nombre': 'Portal Norte',
    'lat': 4.7633,
    'lng': -74.0340,
  },
];

/// Ejemplo de “reportes viales” (capa de eventos de usuario).
const List<Map<String, dynamic>> _reportesViales = [
  {
    'id': 'R1',
    'tipo': 'Accidente',
    'descripcion': 'Choque leve sentido norte-sur',
    'lat': 4.6515,
    'lng': -74.0930,
  },
  {
    'id': 'R2',
    'tipo': 'Obra',
    'descripcion': 'Obras en la calzada, un carril cerrado',
    'lat': 4.6420,
    'lng': -74.0750,
  },
  {
    'id': 'R3',
    'tipo': 'Congestión',
    'descripcion': 'Alta congestión en hora pico',
    'lat': 4.6670,
    'lng': -74.1200,
  },
];

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  bool _mostrarTransporte = true;
  bool _mostrarReportes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de movilidad – prototipo'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Capas del mapa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Capa transporte público (GTFS)'),
              subtitle: const Text('Rutas/paradas de ejemplo'),
              value: _mostrarTransporte,
              onChanged: (value) {
                setState(() {
                  _mostrarTransporte = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Capa reportes viales'),
              subtitle: const Text('Eventos reportados por usuarios'),
              value: _mostrarReportes,
              onChanged: (value) {
                setState(() {
                  _mostrarReportes = value;
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nota: los puntos son un subconjunto de datos de ejemplo, '
                'basados en la estructura de GTFS y reportes viales '
                'definida en el modelo de datos.',
              ),
            ),
          ],
        ),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _bogotaCenter,
          initialZoom: 12.5,
        ),
        children: [
          // Capa 0: mapa base (OpenStreetMap).
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.nelsino.movilidad_bogota_prototipo',
          ),

          // Capa 2: transporte público (paradas GTFS).
          if (_mostrarTransporte)
            MarkerLayer(
              markers: _paradasGtfs.map((parada) {
                return Marker(
                  point: LatLng(
                    parada['lat'] as double,
                    parada['lng'] as double,
                  ),
                  width: 40,
                  height: 40,
                  child: Tooltip(
                    message:
                        'Parada: ${parada['nombre']} (id: ${parada['id']})',
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                );
              }).toList(),
            ),

          // Capa 3: reportes viales de usuarios.
          if (_mostrarReportes)
            MarkerLayer(
              markers: _reportesViales.map((reporte) {
                Color color;
                switch (reporte['tipo'] as String) {
                  case 'Accidente':
                    color = Colors.red;
                    break;
                  case 'Obra':
                    color = Colors.orange;
                    break;
                  case 'Congestión':
                    color = Colors.amber;
                    break;
                  default:
                    color = Colors.deepPurple;
                }

                return Marker(
                  point: LatLng(
                    reporte['lat'] as double,
                    reporte['lng'] as double,
                  ),
                  width: 40,
                  height: 40,
                  child: Tooltip(
                    message:
                        '${reporte['tipo']}: ${reporte['descripcion']}',
                    child: Icon(
                      Icons.warning,
                      color: color,
                      size: 30,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}