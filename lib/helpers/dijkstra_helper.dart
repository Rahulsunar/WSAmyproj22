import 'dart:collection';
import 'package:collection/collection.dart';

import 'dart:math';

class LocationNode {
  final String id;
  final String name;
  final double lat;
  final double lon;

  LocationNode({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });
}

class Graph {
  final Map<String, List<Map<String, dynamic>>> adjList = {};
  final Map<String, LocationNode> nodes = {};

  void addNode(LocationNode node) {
    nodes[node.id] = node;
    adjList[node.id] = [];
  }

  void addEdge(String from, String to, double weight) {
    adjList[from]?.add({'node': to, 'weight': weight});
  }

  double _haversine(LocationNode a, LocationNode b) {
    const R = 6371e3; // Earth radius in meters
    final dLat = _deg2rad(b.lat - a.lat);
    final dLon = _deg2rad(b.lon - a.lon);

    final lat1 = _deg2rad(a.lat);
    final lat2 = _deg2rad(b.lat);

    final aVal = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));

    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Build full weighted edges between all nodes
  void connectAll() {
    nodes.forEach((id1, node1) {
      nodes.forEach((id2, node2) {
        if (id1 != id2) {
          double dist = _haversine(node1, node2);
          addEdge(id1, id2, dist);
        }
      });
    });
  }

  List<String> dijkstra(String startId) {
    final dist = <String, double>{};
    final prev = <String, String?>{};
    final visited = <String>{};
    final queue = PriorityQueue<MapEntry<String, double>>( (a, b) => a.value.compareTo(b.value));

    nodes.forEach((id, _) {
      dist[id] = double.infinity;
      prev[id] = null;
    });
    dist[startId] = 0;
    queue.add(MapEntry(startId, 0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final u = current.key;
      if (visited.contains(u)) continue;
      visited.add(u);

      for (var neighbor in adjList[u]!) {
        final v = neighbor['node'];
        final weight = neighbor['weight'];
        final alt = dist[u]! + weight;
        if (alt < dist[v]!) {
          dist[v] = alt;
          prev[v] = u;
          queue.add(MapEntry(v, alt));
        }
      }
    }

    // Find the nearest target node
    String? nearest;
    double minDist = double.infinity;
    dist.forEach((id, d) {
      if (id != startId && d < minDist) {
        minDist = d;
        nearest = id;
      }
    });

    if (nearest == null) return [];

    // Build path from start to nearest
    final path = <String>[];
    for (var at = nearest; at != null; at = prev[at]) {
      path.insert(0, at);
    }
    path.insert(0, startId);
    return path;
  }
}
