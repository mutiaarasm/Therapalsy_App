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
            top: 280, 
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/welcome.png',
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          
          // Overlay gradient agar teks tetap jelas
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
          
          // Teks dua baris di kiri atas
          Positioned(
            top: 110,
            left: 34,
            right: 24,
            child: const Text(
              'Start Your Therapy\nJourney With Us!',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w100,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),

          // BUTTON GET STARTED DI POJOK KANAN ATAS (Tanpa layer/kotakan hijau)
          Positioned(
            top: 50, // Menyesuaikan area safe zone atas ponsel
            right: 20,
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.REGISTER),
              style: TextButton.styleFrom(
                foregroundColor: mainGreen, // Warna teks & icon utama
                backgroundColor: Colors.transparent, // Menghilangkan background/layer kotak
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}