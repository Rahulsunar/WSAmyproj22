class Node {
  final String id;
  final double latitude;
  final double longitude;

  Node({required this.id, required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Node &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Node(id: $id, lat: $latitude, lng: $longitude)';
  }
}
