import 'dart:ui';
import 'package:bellspalsy_app/app/modules/detection/views/detection_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntroDetectionView extends StatelessWidget {
  const IntroDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    const mainGreen = Color(0xFF316B5C);

    return Scaffold(
      body: Stack(
        children: [
          // ===== Background gradient =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF28584C),
                  Color(0xFF3E7B6A),
                  Color(0xFF92A79F),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ===== Decorative blobs =====
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(
              color: Colors.white.withOpacity(0.13),
              size: 220,
            ),
          ),
          Positioned(
            top: 160,
            left: -50,
            child: _Blob(
              color: Colors.white.withOpacity(0.06),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: _Blob(
              color: Colors.white.withOpacity(0.10),
              size: 260,
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final contentMaxWidth = maxWidth > 520 ? 520.0 : maxWidth;
                final horizontal = maxWidth < 360 ? 16.0 : 20.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // ===== Top bar =====
                          _TopBar(
                            title: "Detection",
                            onBack: Get.back,
                          ),

                          const SizedBox(height: 18),

                          // ===== Hero icon =====
                          Center(
                            child: Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.face_6_outlined,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ===== Title + subtitle =====
                          const Text(
                            "Prepare for Detection",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ikuti panduan singkat ini agar hasil deteksi wajah lebih akurat dan konsisten.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.84),
                              fontSize: 13.8,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ===== Main card =====
                          _GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  _WarningHeader(),
                                  SizedBox(height: 16),
                                  _TipTile(
                                    icon: Icons.lightbulb_outline,
                                    title: "Cahaya cukup",
                                    desc:
                                        "Pastikan berada di tempat terang agar wajah terlihat jelas saat diproses.",
                                  ),
                                  SizedBox(height: 10),
                                  _TipTile(
                                    icon: Icons.face_6_outlined,
                                    title: "Posisi wajah lurus",
                                    desc:
                                        "Hadap kamera secara tegak, jangan terlalu miring atau terlalu jauh dari frame.",
                                  ),
                                  SizedBox(height: 10),
                                  _TipTile(
                                    icon: Icons.swipe_outlined,
                                    title: "Ikuti instruksi gerakan",
                                    desc:
                                        "Aplikasi akan meminta beberapa gerakan wajah untuk membantu penilaian.",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ===== Privacy note =====
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.white.withOpacity(0.92),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Kamera hanya digunakan untuk proses deteksi dan tidak disimpan.",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.88),
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w600,
                                      height: 1.28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ===== Primary button =====
                          Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4B9B86),
                                  Color(0xFF2F695A),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  Get.to(() => const DetectionView()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text(
                                "Start Detection",
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ===== Secondary button =====
                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Get.bottomSheet(
                                  const _HowItWorksSheet(),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.35),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text(
                                "How it works",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================
// Components
// =====================

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              fontSize: 16.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.28),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 25,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(0.15),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _WarningHeader extends StatelessWidget {
  const _WarningHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8686).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Checklist for accurate detection",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.8,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _TipTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.84),
                    fontSize: 12.6,
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// =====================
// Bottom Sheet: How it works
// =====================

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();

  @override
  Widget build(BuildContext context) {
    const mainGreen = Color(0xFF316B5C);

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "How detection works",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kamu akan diminta melakukan beberapa gerakan wajah. Sistem akan mengecek kesimetrisan dan menghasilkan skor yang bisa digunakan untuk memantau perkembangan.",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.60),
                    height: 1.28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _SheetStep(
                  no: "1",
                  title: "Posisikan wajah",
                  desc:
                      "Pastikan wajah berada di tengah frame dan pencahayaan cukup terang.",
                  color: mainGreen,
                ),
                const SizedBox(height: 10),
                _SheetStep(
                  no: "2",
                  title: "Ikuti instruksi gerakan",
                  desc:
                      "Contohnya seperti senyum, angkat alis, atau tutup mata sesuai panduan.",
                  color: mainGreen,
                ),
                const SizedBox(height: 10),
                _SheetStep(
                  no: "3",
                  title: "Lihat hasil deteksi",
                  desc:
                      "Hasil bisa dipakai untuk melihat kondisi wajah dan membandingkan progress terapi.",
                  color: mainGreen,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetStep extends StatelessWidget {
  final String no;
  final String title;
  final String desc;
  final Color color;

  const _SheetStep({
    required this.no,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                no,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.60),
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}