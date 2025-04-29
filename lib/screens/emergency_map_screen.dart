import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyMapScreen extends StatefulWidget {
  const EmergencyMapScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyMapScreen> createState() => _EmergencyMapScreenState();
}

class _EmergencyMapScreenState extends State<EmergencyMapScreen> {
  LatLng? userLocation;
  final LatLng emergencyLocation = LatLng(27.6738, 85.3256); // Patan Hospital
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
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
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Map (Free)"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: userLocation!,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.women_safety_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: userLocation!,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: emergencyLocation,
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [userLocation!, emergencyLocation],
                strokeWidth: 4.0,
                color: Colors.pink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
