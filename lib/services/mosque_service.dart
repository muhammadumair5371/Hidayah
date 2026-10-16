import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/mosque_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueService {
  Future<List<MosqueModel>> loadMosques(double userLat, double userLon) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/mosques.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      List<MosqueModel> mosques = jsonList.map((json) => MosqueModel.fromJson(json)).toList();

      // Calculate distances using Haversine formula
      for (var mosque in mosques) {
        double distanceInMeters = Geolocator.distanceBetween(
          userLat,
          userLon,
          mosque.latitude,
          mosque.longitude,
        );
        mosque.distanceKm = distanceInMeters / 1000.0;
      }

      // Sort by nearest first
      mosques.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
      return mosques;
    } catch (e) {
      throw Exception('Failed to load mosques: $e');
    }
  }

  Future<void> openMap(double lat, double lon, String mosqueName) async {
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    final geoUrl = Uri.parse('geo:$lat,$lon?q=${Uri.encodeComponent(mosqueName)}');

    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
    } else if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch maps.');
    }
  }

  Future<void> openLiveNearbyMosquesMap(double userLat, double userLon) async {
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/mosques/@$userLat,$userLon,15z');
    final geoUrl = Uri.parse('geo:$userLat,$userLon?q=mosques');

    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
    } else if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch maps.');
    }
  }
}
