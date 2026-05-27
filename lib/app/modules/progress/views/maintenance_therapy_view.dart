import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../therapy/controllers/therapy_controller.dart';
import '../../therapy/views/therapy_video.dart';

class MaintenanceTherapyView extends StatelessWidget {
  const MaintenanceTherapyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TherapyController());
    final exercises = controller.allExercises;

    const mainGreen = Color(0xFF306A5A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Maintenance Exercises'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.play_circle_fill, color: mainGreen),
              title: Text('Exercise ${index + 1}'),
              subtitle: Text(ex['desc'] ?? ''),
              onTap: () {
                controller.selectedDay.value = 1;
                controller.currentVideoIndex.value = index;
                Get.to(() => const TherapyVideo());
              },
            ),
          );
        },
      ),
    );
  }
}