import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../services/graph_service.dart';
import '../services/distance_utils.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyPathScreen extends StatefulWidget {
  const EmergencyPathScreen({Key? key}) : super(key: key);

  @override
  _EmergencyPathScreenState createState() => _EmergencyPathScreenState();
}

class _EmergencyPathScreenState extends State<EmergencyPathScreen> {
  List<Node> emergencyLocations = []; // Replace with real-time places
  List<Edge> edges = [];

  Position? currentPosition;
  Node? currentNode;

  @override
  void initState() {
    super.initState();
    loadEmergencyData();
  }

  void loadEmergencyData() async {
    currentPosition = await Geolocator.getCurrentPosition();
    currentNode = Node(
      id: 'user',
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
    );

    // Dummy emergency locations
    emergencyLocations = [
      Node(id: 'Police', latitude: 27.7100, longitude: 85.3240),
      Node(id: 'Hospital', latitude: 27.7120, longitude: 85.3250),
      Node(id: 'Pharmacy', latitude: 27.7130, longitude: 85.3220),
    ];

    // Create edges between user and each location
    for (var location in emergencyLocations) {
      double dist = calculateDistance(
        currentNode!.latitude, currentNode!.longitude,
        location.latitude, location.longitude,
      );
      edges.add(Edge(from: currentNode!, to: location, distance: dist));
    }

    final graphService = GraphService(nodes: [currentNode!, ...emergencyLocations], edges: edges);
    var distances = graphService.dijkstra(currentNode!);

    // Sort based on distance
    var sortedLocations = emergencyLocations.toList()
      ..sort((a, b) => distances[a]!.compareTo(distances[b]!));

    // You can now show this in UI
    print("Nearest: ${sortedLocations.first.id}");

    setState(() {
      emergencyLocations = sortedLocations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearest Emergency Help')),
      body: ListView.builder(
        itemCount: emergencyLocations.length,
        itemBuilder: (context, index) {
          var location = emergencyLocations[index];
          return ListTile(
            title: Text(location.id),
            subtitle: Text('${location.latitude}, ${location.longitude}'),
          );
        },
      ),
    );
  }
}
