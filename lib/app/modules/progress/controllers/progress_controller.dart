import 'dart:convert';

import 'package:bellspalsy_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ProgressController extends GetxController {
  final int totalTask = 7;

  final RxList<int> progressScores = <int>[0, 0, 0, 0, 0, 0, 0].obs;

  final RxInt completedTask = 0.obs;
  final RxList<dynamic> sessions = <dynamic>[].obs;
  final box = GetStorage();

  final RxString programMode = 'monitoring'.obs;
  final RxBool finalPopupShown = false.obs;

  double get progressPercent {
    if (totalTask == 0) return 0;
    return completedTask.value / totalTask;
  }

  List<int> get validScores => progressScores.where((e) => e > 0).toList();

  @override
  void onInit() {
    super.onInit();

    programMode.value = box.read('program_mode') ?? 'monitoring';

    fetchMonitoringHistory();
  }

  int _parsePercentage(dynamic value) {
    if (value == null) {
      return 0;
    }

    final double? parsedValue = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

    if (parsedValue == null) {
      return 0;
    }

    return parsedValue.round().clamp(0, 100).toInt();
  }

  Future<void> fetchMonitoringHistory() async {
    try {
      final token = AuthController.to.token.value;

      if (token.isEmpty) return;

      final url = ApiService.uri('/api/monitoring/history');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('===== MONITORING RESPONSE =====');
      print(response.body);

      if (response.statusCode != 200) {
        throw Exception('Server error status: ${response.statusCode}');
      }

      if (response.headers['content-type']?.contains('text/html') ?? false) {
        throw Exception('Server mengirim HTML, kemungkinan error di backend.');
      }

      final body = jsonDecode(response.body);

      if (body['success'] != true) {
        throw Exception('Failed to fetch monitoring history');
      }

      final List data = body['data'] ?? [];

      sessions.assignAll(data.take(totalTask).toList());

      final List<int> tempScores = [];

      for (final item in data.take(totalTask)) {
        final int totalScore =
            int.tryParse(
              (item['total_skor'] ?? item['total_score'] ?? 0).toString(),
            ) ??
            0;

        final int percentage = _parsePercentage(item['percentage']);

        // Konsep grafik:
        // skor 0 = tidak ada asimetri bermakna = 100% simetri.
        // Jika ada asimetri, gunakan percentage dari backend.
        final int graphScore = totalScore == 0 ? 100 : percentage;

        tempScores.add(graphScore);
      }

      while (tempScores.length < totalTask) {
        tempScores.add(0);
      }

      progressScores.assignAll(tempScores.take(totalTask).toList());

      completedTask.value = data.length.clamp(0, totalTask).toInt();

      print('===== PROGRESS SCORES =====');
      print(progressScores);
    } catch (e) {
      print('fetch monitoring error: $e');

      progressScores.assignAll(List.filled(totalTask, 0));

      completedTask.value = 0;
      sessions.clear();
      programMode.value = 'monitoring';
    }
  }

  String analyzeFinalResult() {
    if (completedTask.value < totalTask || validScores.isEmpty) {
      return 'in_progress';
    }

    final scores = validScores;

    if (scores.length < 2) {
      return 'needs_repeat';
    }

    final lastTwo = scores.sublist(scores.length - 2);

    // Nilai simetri tinggi pada dua sesi terakhir.
    if (lastTwo.every((p) => p >= 80)) {
      return 'improved';
    }

    final avg = scores.reduce((a, b) => a + b) / scores.length;

    int unstableCount = 0;

    for (int i = 1; i < scores.length; i++) {
      if ((scores[i] - scores[i - 1]).abs() >= 30) {
        unstableCount++;
      }
    }

    // Positif berarti nilai simetri meningkat.
    final improvement = scores.last - scores.first;

    if (scores.last >= 80 &&
        avg >= 65 &&
        improvement >= 0 &&
        unstableCount <= 3) {
      return 'improved';
    }

    return 'needs_repeat';
  }

  bool get showMaintenanceMode =>
      completedTask.value >= totalTask && analyzeFinalResult() == 'improved';

  void activateMaintenanceMode() {
    programMode.value = 'maintenance';

    box.write('program_mode', 'maintenance');
  }

  Future<bool> resetProgram() async {
    try {
      final token = AuthController.to.token.value;

      if (token.isEmpty) {
        Get.snackbar('Reset Failed', 'Authentication token is unavailable.');

        return false;
      }

      final url = ApiService.uri('/api/monitoring/reset');

      print('===== REQUEST RESET MONITORING =====');
      print('URL: $url');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode != 200) {
        Get.snackbar(
          'Reset Failed',
          'Server returned status ${response.statusCode}.',
        );

        return false;
      }

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body['success'] != true) {
        Get.snackbar(
          'Reset Failed',
          body['message'] ?? 'Monitoring program could not be reset.',
        );

        return false;
      }

      await box.remove('program_mode');

      programMode.value = 'monitoring';
      completedTask.value = 0;

      progressScores.assignAll(List<int>.filled(totalTask, 0));

      sessions.clear();
      finalPopupShown.value = false;

      return true;
    } catch (e) {
      print('reset monitoring error: $e');

      Get.snackbar(
        'Reset Failed',
        'An error occurred while resetting the program.',
      );

      return false;
    }
  }
}
