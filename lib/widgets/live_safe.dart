import 'package:flutter/material.dart';
import 'package:women_safety_app/utils/location_service.dart';
import 'package:women_safety_app/utils/nearest_location.dart';

class LiveSafe extends StatefulWidget {
  @override
  _LiveSafeState createState() => _LiveSafeState();
}

class _LiveSafeState extends State<LiveSafe> {
  String nearestLocation = "Fetching...";
  double distance = 0.0;

  void fetchNearestLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final nearest = getNearestEmergency(position.latitude, position.longitude);
      setState(() {
        nearestLocation = nearest['name'];
        distance = nearest['distance'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNearestLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Nearest Emergency Location: $nearestLocation"),
        Text("Distance: ${distance.toStringAsFixed(2)} km"),
        ElevatedButton(
          onPressed: fetchNearestLocation,
          child: Text("Refresh Location"),
        ),
      ],
    );
  }
}
