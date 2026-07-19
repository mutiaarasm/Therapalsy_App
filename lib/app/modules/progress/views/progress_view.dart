import 'package:bellspalsy_app/app/modules/dashboard/views/dashboard_view.dart';
import 'package:bellspalsy_app/app/modules/detection/views/intro_detection_view.dart';
import 'package:bellspalsy_app/app/modules/profile/views/profile_view.dart';
import 'package:bellspalsy_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:bellspalsy_app/app/modules/progress/views/maintenance_therapy_view.dart';
import 'package:bellspalsy_app/app/modules/progress/views/nearby_healthcare_view.dart';
import 'package:bellspalsy_app/app/modules/therapy/views/therapy_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
Widget build(BuildContext context) {
  const Color mainGreen = Color(0xFF306A5A);
  const Color greyCircle = Color(0xFFE0E0E0);

  final ProgressController controller =
    Get.isRegistered<ProgressController>()
        ? Get.find<ProgressController>()
        : Get.put(ProgressController());

  return Obx(() {
  final isMaintenance = controller.programMode.value == 'maintenance';
  return Scaffold(
    backgroundColor: Colors.white,
    // HANYA tampilkan AppBar jika BUKAN mode maintenance
    appBar: isMaintenance 
        ? null 
        : PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Get.offAll(() => const DashboardView()),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'PROGRESS',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                      ),
                    ),
                    const Opacity(opacity: 0, child: Icon(Icons.arrow_back_ios_new_rounded)),
                  ],
                ),
              ),
            ),
          ),
    body: isMaintenance
        ? const MaintenanceTherapyView()
        : Obx(() {
      final totalTask = controller.totalTask;
      final completedTask = controller.completedTask.value;
      final progressPercent = controller.progressPercent;
      final progressDays = controller.progressScores.isEmpty
    ? List<int>.filled(controller.totalTask, 0)
    : controller.progressScores;
    
    
    final finalResult = controller.analyzeFinalResult();
    if (controller.programMode.value ==
    'maintenance') {
  return const MaintenanceTherapyView();
}

if (completedTask >= 7 && !controller.finalPopupShown.value && controller.programMode.value == 'monitoring') {
  controller.finalPopupShown.value = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.dialog(
      _FinalResultDialog(
        lottiePath: finalResult == 'improved'
            ? 'assets/lottie/alert_good.json'
            : 'assets/lottie/alert_bad.json',
        title: finalResult == 'improved'
            ? 'Great Progress!'
            : 'Further Monitoring Needed',
        message: finalResult == 'improved'
            ? 'Persentase simetri wajah menunjukkan hasil yang baik. Lanjutkan dengan latihan pemeliharaan.'
            : 'Persentase simetri wajah belum menunjukkan hasil yang cukup baik atau cenderung menurun. Ulangi program atau konsultasikan dengan tenaga kesehatan.',
        primaryText: finalResult == 'improved'
            ? 'Continue to Maintenance'
            : 'Repeat Program',
        color: finalResult == 'improved' ? mainGreen : const Color(0xFFDC2626),
        onPrimaryTap: () async {
          Get.back();

          if (finalResult == 'improved') {
            controller.activateMaintenanceMode();
            return;
          }

          final success = await controller.resetProgram();

          if (success) {
            Get.offAll(
              () => const TherapyList(day: 1),
            );
          }
        },
      ),
      barrierDismissible: true,
    );
  });
}


// Kalau belum, tampilkan progress chart
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
                'Persentase Simetri Wajah',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: _AsymmetryInfoCard(),
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

           if (controller.completedTask.value >= 7) ...[
              _FinalMonitoringCard(
                mainGreen: mainGreen,
                finalResult: controller.analyzeFinalResult(),
              ),
              const SizedBox(height: 16),
              if (controller.analyzeFinalResult() == 'needs_repeat') ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF306A5A),
                        const Color(0xFF3D8B75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF306A5A).withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Get.to(() => NearbyHealthcareView());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.local_hospital_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Find Nearby Healthcare',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ],

            const SizedBox(height: 24),
          ],
        );
      }),
      bottomNavigationBar: _ProgressBottomNav(mainGreen: mainGreen
      ),
    );
    });
  }
}


class _AsymmetryInfoCard extends StatelessWidget {
  const _AsymmetryInfoCard();

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF306A5A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mainGreen.withOpacity(0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: mainGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: mainGreen,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cara membaca grafik',
                  style: TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Setiap batang menunjukkan persentase simetri wajah pada satu sesi. '
                  'Semakin tinggi nilai dan semakin tinggi batangnya, semakin seimbang '
                  'gerakan sisi kiri dan kanan wajah yang terukur.',
                  style: TextStyle(
                    fontSize: 12.8,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: mainGreen,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Nilai meningkat = perkembangan membaik',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: mainGreen,
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
    );
  }
}

class _FinalResultDialog extends StatelessWidget {
  final String lottiePath;
  final String title;
  final String message;
  final String primaryText;
  final Color color;
  final VoidCallback onPrimaryTap;

  const _FinalResultDialog({
    required this.lottiePath,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.color,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ),

            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset(
                lottiePath,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black.withOpacity(0.62),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onPrimaryTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  primaryText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
Future<void> openNearbyHospitals() async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps/search/hospital+neurologist+near+me',
  );

  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    Get.snackbar(
      'Unable to open Maps',
      'Please check your device connection.',
    );
  }
}

class _FinalMonitoringCard extends StatelessWidget {
  final Color mainGreen;
  final String finalResult; // 'improved' atau 'needs_repeat'
  
  const _FinalMonitoringCard({
    required this.mainGreen,
    required this.finalResult,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBetter = finalResult == 'improved';

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
                  ? 'Persentase simetri wajah menunjukkan hasil yang baik. Kamu dapat melanjutkan ke latihan pemeliharaan.'
                  : 'Persentase simetri belum meningkat secara konsisten atau masih menurun. Ulangi program atau konsultasikan dengan tenaga kesehatan.',
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
               onPressed: () async {
                  if (isBetter) {
                    Get.to(
                      () => const MaintenanceTherapyView(),
                    );
                    return;
                  }

                  final controller = Get.find<ProgressController>();

                  final success = await controller.resetProgram();

                  if (success) {
                    Get.offAll(
                      () => const TherapyList(day: 1),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBetter ? mainGreen : const Color(0xFFDC2626),
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