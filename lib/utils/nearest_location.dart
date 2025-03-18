import 'haversine.dart';
import 'emergency_locations.dart';

Map<String, dynamic> getNearestEmergency(double userLat, double userLon) {
  Map<String, dynamic>? nearest;
  double minDistance = double.infinity;

  for (var location in emergencyLocations) {
    double distance = Haversine.calculateDistance(userLat, userLon, location['lat'], location['lon']);
    if (distance < minDistance) {
      minDistance = distance;
      nearest = location;
    }
  }

  return {'name': nearest!['name'], 'distance': minDistance};
}
