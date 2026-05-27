import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xFF306A5A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFD2E7DF), // hijau tosca muda
                ],
              ),
            ),
          ),
          // Gambar proporsional, center, tidak terpotong
          Positioned(
          top: 280, // atur ke atas (semakin kecil semakin ke atas, semakin besar semakin ke bawah)
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            ),
          ),
          // Overlay gradient agar teks & tombol tetap jelas
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.92),
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.38),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          // Teks dua baris di pojok kiri atas
          Positioned(
            top: 110,
            left: 34,
            right: 24,
            child: Text(
              'Start Your Therapy\nJourney With Us!',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w100,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
          // Tombol di bawah
          // Tombol di bawah (tanpa background putih)
          Positioned(
            left: 28,
            right: 28,
            bottom: 42,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.REGISTER),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      foregroundColor: Colors.white,
                      elevation: 12,
                      shadowColor: mainGreen.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.LOGIN),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: mainGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
