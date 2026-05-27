import 'package:bellspalsy_app/app/modules/dashboard/views/dashboard_view.dart';
import 'package:bellspalsy_app/app/modules/detection/views/detection_history_view.dart';
import 'package:bellspalsy_app/app/modules/detection/views/intro_detection_view.dart';
import 'package:bellspalsy_app/app/modules/profile/views/profile_view.dart';
import 'package:bellspalsy_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:bellspalsy_app/app/modules/progress/views/maintenance_therapy_view.dart';
import 'package:bellspalsy_app/app/modules/therapy/views/therapy_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF306A5A);
    const Color greyCircle = Color(0xFFE0E0E0);

    final controller = Get.put(ProgressController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 0, right: 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87),
                  onPressed: () {
                    Get.offAll(() => const DashboardView());
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'PROGRESS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const Opacity(
                  opacity: 0,
                  child: Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
     body: Obx(() {
      final totalTask = controller.totalTask;
      final completedTask = controller.completedTask.value;
      final progressPercent = controller.progressPercent;
      final progressDays = controller.progressScores.isEmpty
    ? List<int>.filled(controller.totalTask, 0)
    : controller.progressScores;
    
    final programMode = controller.programMode.value;
    final finalResult = controller.analyzeFinalResult();

    if (completedTask >= 7 &&
        !controller.finalPopupShown.value &&
        programMode == 'monitoring') {
      controller.finalPopupShown.value = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (finalResult == 'improved') {
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Congratulations! 🎉'),
              content: const Text(
                'Your monitoring result shows improvement. You can now continue with maintenance exercises.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    controller.activateMaintenanceMode();
                    controller.programMode.refresh();
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        } else if (finalResult == 'worse') {
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Further Monitoring Needed'),
              content: const Text(
                'Your progress still shows instability. It is recommended to repeat the therapy program from Day 1 and consult a medical professional if symptoms worsen.',
              ),
              actions: [
                TextButton(
                  onPressed: () async{
                    Get.back();
                    await controller.resetMonitoringProgramFromBackend();
                  },
                  child: const Text('Repeat Program'),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        }
      });
    }
    if (programMode == 'maintenance') {
      return const MaintenanceTherapyView();
      }
          return ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monitoring Program',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '$completedTask of $totalTask sessions completed.',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13.2,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progressPercent,
                                    minHeight: 10,
                                    backgroundColor: const Color(0xFFEEEEEE),
                                    valueColor:
                                        const AlwaysStoppedAnimation(mainGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: mainGreen, width: 2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${(progressPercent * 100).round()}%',
                                    style: const TextStyle(
                                      color: mainGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                "Progress your face after exercise",
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(progressDays.length, (i) {
                    final int val = progressDays[i];
                    final double barHeight = (val / 100) * 110;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: barHeight == 0 ? 2 : barHeight,
                          decoration: BoxDecoration(
                            color: val > 0 ? mainGreen : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$val%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sesi\n${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 66,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: totalTask,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, i) {
                  final isDone = i < completedTask;
                  final isActive = i == completedTask && completedTask < totalTask;
                 
                  Color circleColor;
                  Color textColor;

                  if (isActive) {
                    circleColor = mainGreen;
                    textColor = Colors.white;
                  } else if (isDone) {
                    circleColor = mainGreen.withOpacity(0.5);
                    textColor = Colors.white;
                  } else {
                    circleColor = greyCircle;
                    textColor = Colors.black38;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: GestureDetector(
                      onTap: isActive
                          ? () {
                              Get.to(
                                () => TherapyList(day: i + 1),
                              );
                            }
                          : null,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            if (completedTask >= 7) ...[
              _FinalMonitoringCard(
                scores: progressDays,
                mainGreen: mainGreen,
              ),
              const SizedBox(height: 24),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                "Detection History",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: mainGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Check your detection history in here!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 170,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => const DetectionHistoryView());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: mainGreen,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View History",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 7),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      }),
      bottomNavigationBar: _ProgressBottomNav(mainGreen: mainGreen),
    );
  }
}



class _ProgressBottomNav extends StatelessWidget {
  final Color mainGreen;
  const _ProgressBottomNav({required this.mainGreen});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: mainGreen,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      onTap: (index) {
        switch (index) {
          case 0:
            Get.to(() => const DashboardView());
            break;
          case 1:
            Get.to(() => const IntroDetectionView());
            break;
          case 2:
            break;
          case 3:
            Get.to(() => const ProfileView());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.crop_free), label: 'Detection'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

class _FinalMonitoringCard extends StatelessWidget {
  final List<int> scores;
  final Color mainGreen;

  const _FinalMonitoringCard({
    required this.scores,
    required this.mainGreen,
  });

  @override
  Widget build(BuildContext context) {
    final firstScore = scores.firstWhere((e) => e > 0, orElse: () => 0);
    final lastScore = scores.isNotEmpty ? scores.last : 0;

    final bool isBetter = lastScore <= firstScore || lastScore <= 20;
    final bool isNormal = lastScore <= 20;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isBetter ? const Color(0xFFEFFAF5) : const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isBetter
                ? mainGreen.withOpacity(0.25)
                : const Color(0xFFDC2626).withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isBetter
                  ? Icons.celebration_rounded
                  : Icons.health_and_safety_rounded,
              color: isBetter ? mainGreen : const Color(0xFFDC2626),
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              isBetter
                  ? 'Congratulations!'
                  : 'Further Monitoring Recommended',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBetter
                  ? 'Your face exercise progress looks better. You can continue with maintenance exercises anytime.'
                  : 'Your monitoring result still needs attention. Consider continuing therapy and consulting a medical professional if symptoms persist or worsen.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isBetter || isNormal) {
                     Get.to(() => const MaintenanceTherapyView());
                  } else {
                    // ulang dari day 1
                    Get.to(() => TherapyList(day: 1));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isBetter ? mainGreen : const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isBetter
                      ? 'Open Maintenance Exercises'
                      : 'Repeat Therapy Program',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}