import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Kaaba Coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS is turned off. Please turn on Location/GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied in settings.');
    }

    // Attempt last known position first for quick response
    try {
      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        return lastPos;
      }
    } catch (_) {}

    // Fallback to high accuracy position lookup
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  Future<String> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String? city = place.locality;
        if (city == null || city.isEmpty) {
          city = place.subAdministrativeArea;
        }
        if (city == null || city.isEmpty) {
          city = place.administrativeArea;
        }
        if (city == null || city.isEmpty) {
          city = place.subLocality;
        }

        final country = place.country;
        if (city != null && city.isNotEmpty) {
          if (country != null && country.isNotEmpty) {
            return '$city, $country';
          }
          return city;
        }
      }
    } catch (_) {
      // Reverse geocoding failed or offline
    }
    return 'Your Location';
  }

  // Great-circle bearing formula for Qibla
  double calculateQiblaBearing(double latitude, double longitude) {
    // Convert degrees to radians
    double lat1 = latitude * (math.pi / 180.0);
    double lon1 = longitude * (math.pi / 180.0);
    double lat2 = kaabaLatitude * (math.pi / 180.0);
    double lon2 = kaabaLongitude * (math.pi / 180.0);

    double dLon = lon2 - lon1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);

    // Convert radians to degrees
    bearing = bearing * (180.0 / math.pi);

    // Normalize to 0-360
    bearing = (bearing + 360) % 360;
    return bearing;
  }
}
