import 'package:bellspalsy_app/app/modules/progress/views/progress_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class GreatJobView extends StatelessWidget {
  final int day;
  const GreatJobView({super.key, this.day = 1});


  static const Color mainGreen = Color(0xFF306A5A);

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: mainGreen,
    body: SafeArea(
      child: Stack(
        children: [
          // "Next ->" top right (dummy)
          Positioned(
            top: 14,
            right: 16,
            child: GestureDetector(
              onTap: () {
                 Get.offAll(() => const ProgressView());
              },
              child: const Text(
                'Next →',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // content
          Column(
            children: [
              const SizedBox(height: 110),

              const Text(
                'Great job!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'You have successfully completed Day $day of\nyour facial therapy.\nKeep going, your progress matters!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(),

              // Illustration area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.12),
                    child: Image.asset(
                      'assets/images/great_job.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.white70,
                            size: 80,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ],
      ),
    ),
  );
}

}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);
    const stripeH = 34.0;
    double y = 0;
    bool on = true;
    while (y < size.height) {
      if (on) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, stripeH), paint);
      }
      on = !on;
      y += stripeH;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
