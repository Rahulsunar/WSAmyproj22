import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class EmergencyMapScreen extends StatefulWidget {
  const EmergencyMapScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyMapScreen> createState() => _EmergencyMapScreenState();
}

class _EmergencyMapScreenState extends State<EmergencyMapScreen> {
  LatLng? userLocation;
  LatLng? nearestEmergencyLocation;
  String nearestLocationName = '';
  double distanceInKm = 0;
  final MapController mapController = MapController();
  List<LatLng> routePoints = [];
  bool isLoadingRoute = false;

  final String orsApiKey =
      '5b3ce3597851110001cf62485686e3504d4e4803a41e35f836bf55a8';

  final List<Map<String, dynamic>> emergencyLocations = [
    {'name': 'Patan Hospital', 'latlng': LatLng(27.6738, 85.3256)},
    {'name': 'Police Station', 'latlng': LatLng(27.7077, 85.3155)},
    {'name': 'Bus Stop Ratnapark', 'latlng': LatLng(27.7075, 85.3121)},
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Map<String, dynamic> _findNearestLocation(LatLng user) {
    double minDistance = double.infinity;
    LatLng nearest = emergencyLocations[0]['latlng'];
    String name = emergencyLocations[0]['name'];

    for (var place in emergencyLocations) {
      final LatLng location = place['latlng'];
      final double distance = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        location.latitude,
        location.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
        name = place['name'];
      }
    }

    return {'latlng': nearest, 'name': name, 'distance': minDistance / 1000};
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Geolocator.getPositionStream().listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      final nearest = _findNearestLocation(newPosition);

      setState(() {
        userLocation = newPosition;
        nearestEmergencyLocation = nearest['latlng'];
        nearestLocationName = nearest['name'];
        distanceInKm = nearest['distance'];
      });

      _fetchRoute(newPosition, nearestEmergencyLocation!);
    });
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    setState(() => isLoadingRoute = true);

    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car/geojson');

    final body = jsonEncode({
      "coordinates": [
        [from.longitude, from.latitude],
        [to.longitude, to.latitude]
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': orsApiKey,
          'Content-Type': 'application/json'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final geometry = data['features'][0]['geometry']['coordinates'] as List;

        List<LatLng> points = geometry
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();

        setState(() {
          routePoints = points;
          isLoadingRoute = false;
        });

        print("ROUTE LOADED: \${points.length} points");
      } else {
        print(
            '❌ Failed to load route: \${response.statusCode} → \${response.body}');
        setState(() => isLoadingRoute = false);
      }
    } catch (e) {
      print('❌ Exception while fetching route: \$e');
      setState(() => isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Map (Free)"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        children: [
          userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: userLocation!,
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.women_safety_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 60.0,
                          height: 60.0,
                          point: userLocation!,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                        ),
                        if (nearestEmergencyLocation != null)
                          Marker(
                            width: 60.0,
                            height: 60.0,
                            point: nearestEmergencyLocation!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 6.0,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                  ],
                ),
          if (userLocation != null && nearestEmergencyLocation != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 $nearestLocationName',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distance: ${distanceInKm.toStringAsFixed(2)} km',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    if (isLoadingRoute)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Destination confirmed!")),
                          );
                        },
                        child: const Text(
                          "Confirm destination",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
