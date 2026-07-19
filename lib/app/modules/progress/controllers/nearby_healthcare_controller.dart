import 'dart:convert';

import 'package:bellspalsy_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NearbyHealthcareController extends GetxController {
  final isLoading = false.obs;
  final places = <dynamic>[].obs;

  final hospitalLat = 0.0.obs;
  final hospitalLng = 0.0.obs;

  final userLat = 0.0.obs;
  final userLng = 0.0.obs;
  @override
  void onInit() {
    super.onInit();
    loadNearbyHospitals();
  }

  Future<void> loadNearbyHospitals() async {
    try {
      isLoading.value = true;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Get.snackbar('Location Disabled', 'Please enable your GPS location.');
        places.clear();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Denied', 'Location permission is required.');
        places.clear();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLat.value = position.latitude;
      userLng.value = position.longitude;

      final url = ApiService.uri('/api/nearby-healthcare', {
        'lat': userLat.value,
        'lng': userLng.value,
      });

      print('NEARBY HOSPITAL URL: $url');

      final response = await http.get(url);
      final body = jsonDecode(response.body);

      print('NEARBY HOSPITAL RESPONSE: ${response.body}');

      if (response.statusCode == 200 && body['success'] == true) {
        places.assignAll(body['data']);
      } else {
        places.clear();
      }
    } catch (e) {
      print('nearby healthcare error: $e');
      places.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
