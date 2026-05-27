import 'dart:convert';

import 'package:bellspalsy_app/services/api_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProgressController extends GetxController {
  final int totalTask = 7;

  final RxList<int> progressScores = <int>[0, 0, 0, 0, 0, 0, 0].obs;
  final RxInt completedTask = 0.obs;
  final RxList<dynamic> sessions = <dynamic>[].obs;

  double get progressPercent {
    if (totalTask == 0) return 0;
    return completedTask.value / totalTask;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMonitoringHistory();
  }

  Future<void> fetchMonitoringHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/monitoring/history/1'),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final List data = body['data'] ?? [];

        sessions.assignAll(data);

        final List<int> tempScores = [];

        for (final item in data) {
          final int percentage =
              int.tryParse(item['percentage'].toString()) ?? 0;

          tempScores.add(percentage);
        }

        while (tempScores.length < totalTask) {
          tempScores.add(0);
        }

        progressScores.assignAll(tempScores.take(totalTask).toList());
        completedTask.value = data.length.clamp(0, totalTask);
      } else {
        progressScores.assignAll(List.filled(totalTask, 0));
        completedTask.value = 0;
      }
    } catch (e) {
      print('fetch monitoring error: $e');

      progressScores.assignAll(List.filled(totalTask, 0));
      completedTask.value = 0;
    }
  }

  final RxString programMode = 'monitoring'.obs;
// monitoring | maintenance

final RxBool finalPopupShown = false.obs;

List<int> get validScores =>
    progressScores.where((e) => e > 0).toList();

String analyzeFinalResult() {
  if (completedTask.value < 7 || validScores.isEmpty) {
    return 'in_progress';
  }

  final scores = validScores;

  final first = scores.first;
  final last = scores.last;

  final avg = scores.reduce((a, b) => a + b) / scores.length;
  final improvement = first - last;

  int unstableCount = 0;

  for (int i = 1; i < scores.length; i++) {
    final diff = (scores[i] - scores[i - 1]).abs();

    if (diff >= 30) {
      unstableCount++;
    }
  }

  if (last <= 20 && avg <= 35 && improvement >= 0 && unstableCount <= 3) {
    return 'improved';
  }

  return 'worse';
}

void activateMaintenanceMode() {
  programMode.value = 'maintenance';
}

void resetMonitoringProgram() {
  progressScores.assignAll(List.filled(totalTask, 0));
  completedTask.value = 0;
  sessions.clear();
  finalPopupShown.value = false;
  programMode.value = 'monitoring';
}

Future<void> resetMonitoringProgramFromBackend() async {
  try {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/api/monitoring/reset/1'),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        body['success'] == true) {

      progressScores.assignAll(
        List.filled(totalTask, 0),
      );

      completedTask.value = 0;

      sessions.clear();

      finalPopupShown.value = false;

      programMode.value = 'monitoring';

      progressScores.refresh();
      sessions.refresh();

      await fetchMonitoringHistory();
    }
  } catch (e) {
    print('reset monitoring error: $e');
  }
}

}