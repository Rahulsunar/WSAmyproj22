import 'dart:collection';
import '../models/node.dart';
import '../models/edge.dart';

class GraphService {
  List<Node> nodes;
  List<Edge> edges;

  GraphService({required this.nodes, required this.edges});

  Map<Node, double> dijkstra(Node start) {
    Map<Node, double> distances = {};
    Map<Node, Node?> previous = {};
    Set<Node> visited = {};
    PriorityQueue<Node> queue = PriorityQueue<Node>(
            (a, b) => (distances[a] ?? double.infinity).compareTo(distances[b] ?? double.infinity));

    for (var node in nodes) {
      distances[node] = double.infinity;
      previous[node] = null;
    }

    distances[start] = 0;
    queue.add(start);

    while (queue.isNotEmpty) {
      Node current = queue.removeFirst();

      if (visited.contains(current)) continue;
      visited.add(current);

      var currentEdges = edges.where((e) => e.from == current);
      for (var edge in currentEdges) {
        Node neighbor = edge.to;
        double newDist = distances[current]! + edge.distance;
        if (newDist < distances[neighbor]!) {
          distances[neighbor] = newDist;
          previous[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }

    return distances;
  }
}
