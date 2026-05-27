import 'package:bellspalsy_app/app/modules/dashboard/views/dashboard_view.dart';
import 'package:bellspalsy_app/app/modules/detection/views/intro_detection_view.dart';
import 'package:bellspalsy_app/app/modules/profile/views/profile_view.dart';
import 'package:bellspalsy_app/app/modules/progress/views/progress_view.dart';
import 'package:bellspalsy_app/app/modules/therapy/views/therapy_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TherapyView extends StatelessWidget {
  const TherapyView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF306A5A);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          // Background hijau atas
          Container(
            height: screenHeight * 0.37,
            width: double.infinity,
            color: mainGreen,
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar custom
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'THERAPY',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Colors.white,
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

                const SizedBox(height: 20),

                // Gambar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/terapi.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 320,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Deskripsi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Try the therapy for 7 days, and take a picture of your face after doing the therapy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: mainGreen,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Tombol Start Exercise (dummy)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                     onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TherapyList(day: 1),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'START EXERCISE',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _TherapyBottomNav(mainGreen: mainGreen),
    );
  }
}

// Bottom Navigation Bar (dummy / view-only)
class _TherapyBottomNav extends StatelessWidget {
  final Color mainGreen;
  const _TherapyBottomNav({required this.mainGreen});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: mainGreen,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
       switch (index) {
          case 0:
            Get.to(() => const DashboardView());
            break;
          case 1:
            Get.to(() => const IntroDetectionView());
            break;
          case 2:
            Get.to(() => const ProgressView());
            break;
          case 3:
            Get.to(() => const ProfileView());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.crop_free), label: 'Detection'),
        BottomNavigationBarItem(
            icon: Icon(Icons.show_chart), label: 'Progress'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
