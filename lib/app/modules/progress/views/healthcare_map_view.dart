import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HealthcareMapView extends StatelessWidget {
  final dynamic place;
  final double userLat;
  final double userLng;

  const HealthcareMapView({
  super.key,
  required this.place,
  required this.userLat,
  required this.userLng,
});

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(place['latitude']?.toString() ?? '') ??
    double.tryParse(place['lat']?.toString() ?? '') ??
    -6.2;
    final lng = double.tryParse(place['longitude']?.toString() ?? '') ??
    double.tryParse(place['lng']?.toString() ?? '') ??
    106.8;

    final hospitalPoint = LatLng(lat, lng);

    final userPoint = LatLng(
      userLat,
      userLng,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(place['name'] ?? 'Map Location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
          (userLat + lat) / 2,
          (userLng + lng) / 2,
        ),
          initialZoom: 13,
        ),
        children: [
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  userPoint,
                  hospitalPoint,
                ],
                strokeWidth: 4,
                color: Colors.red,
              ),
            ],
          ),
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.bellspalsy_app',
          ),
         MarkerLayer(
            markers: [

              // USER
              Marker(
                point: userPoint,
                width: 70,
                height: 70,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 45,
                ),
              ),

              // HOSPITAL
              Marker(
                point: hospitalPoint,
                width: 70,
                height: 70,
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                  size: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}