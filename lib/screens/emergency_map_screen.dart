import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EmergencyMapScreen extends StatelessWidget {
  const EmergencyMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Map (Free)"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: LatLng(27.7056, 85.3159), // Kathmandu center
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
                point: LatLng(27.7056, 85.3159),
                child: const Icon(
                  Icons.local_police,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(27.6738, 85.3256),
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
                points: [
                  LatLng(27.7056, 85.3159),
                  LatLng(27.6738, 85.3256),
                ],
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