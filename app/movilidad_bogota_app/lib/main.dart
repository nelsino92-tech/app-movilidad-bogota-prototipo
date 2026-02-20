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

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  bool _mostrarTransporte = true;
  bool _mostrarReportes = true;

  // Control para el campo de descripción del formulario.
  final TextEditingController _descripcionController = TextEditingController();

  // Tipo de evento seleccionado en el formulario.
  String _tipoSeleccionado = 'Accidente';

  // Lista de reportes viales (inicialmente con algunos de ejemplo).
  final List<Map<String, dynamic>> _reportesViales = [
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

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

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
                'Nota: los puntos son datos de ejemplo basados en la '
                'estructura de GTFS y reportes viales definida en el modelo de datos.',
              ),
            ),
          ],
        ),
      ),
      body: FlutterMap(
            options: MapOptions(
      initialCenter: _bogotaCenter,
      initialZoom: 12.5,
      onTap: (tapPosition, point) {
        // Cuando el usuario toca el mapa, guardamos la ubicación.
        setState(() {
          _ubicacionSeleccionada = point;
        });

        // Mensaje corto para avisar la posición seleccionada.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ubicación seleccionada: '
              '${point.latitude.toStringAsFixed(5)}, '
              '${point.longitude.toStringAsFixed(5)}',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    ),
        children: [
          // Capa 0: mapa base (OpenStreetMap).
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.nelsino.movilidad_bogota_prototipo',
          ),
              // Marcador de la ubicación seleccionada tocando el mapa.
    if (_ubicacionSeleccionada != null)
      MarkerLayer(
        markers: [
          Marker(
            point: _ubicacionSeleccionada!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.green,
              size: 36,
            ),
          ),
        ],
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

          // Capa 3: reportes viales de usuarios (incluye los nuevos que se creen).
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

      // Botón flotante para crear nuevo reporte.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioNuevoReporte,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo reporte'),
      ),
    );
  }

  /// Abre un formulario simple para crear un nuevo reporte vial.
  /// Por ahora la ubicación se toma como el centro del mapa (_bogotaCenter).
  void _abrirFormularioNuevoReporte() {
      // Si el usuario tocó el mapa, usamos ese punto; si no, el centro de Bogotá.
  final LatLng posicion = _ubicacionSeleccionada ?? _bogotaCenter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear reporte vial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Tipo de evento.
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de evento',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Accidente',
                    child: Text('Accidente'),
                  ),
                  DropdownMenuItem(
                    value: 'Obra',
                    child: Text('Obra'),
                  ),
                  DropdownMenuItem(
                    value: 'Congestión',
                    child: Text('Congestión'),
                  ),
                  DropdownMenuItem(
                    value: 'Otro',
                    child: Text('Otro'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoSeleccionado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Descripción.
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: '¿Qué está pasando en la vía?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Ubicación informativa.
              Text(
  'Ubicación del reporte: '
  '${posicion.latitude.toStringAsFixed(5)}, '
  '${posicion.longitude.toStringAsFixed(5)}'
  '${_ubicacionSeleccionada == null ? ' (centro de Bogotá por defecto)' : ''}',
  style: const TextStyle(fontSize: 12, color: Colors.grey),
),
              const SizedBox(height: 16),

              // Botón Guardar.
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_descripcionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Por favor, escribe una descripción.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _reportesViales.add({
                        'id': 'R${_reportesViales.length + 1}',
                        'tipo': _tipoSeleccionado,
                        'descripcion':
                            _descripcionController.text.trim(),
                        'lat': posicion.latitude,
                        'lng': posicion.longitude,
                      });
                      _descripcionController.clear();
                    });

                    Navigator.of(sheetContext).pop();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar reporte'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
  // Última ubicación seleccionada tocando el mapa.
  LatLng? _ubicacionSeleccionada;