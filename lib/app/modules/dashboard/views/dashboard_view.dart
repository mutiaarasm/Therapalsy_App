import 'package:bellspalsy_app/app/modules/article/models/article_model.dart';
import 'package:bellspalsy_app/app/modules/article/views/article_detail_view.dart';
import 'package:bellspalsy_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:bellspalsy_app/app/modules/detection/views/intro_detection_view.dart';
import 'package:bellspalsy_app/app/modules/profile/views/profile_view.dart';
import 'package:bellspalsy_app/app/modules/progress/views/progress_view.dart';
import 'package:bellspalsy_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final Color mainGreen = const Color(0xFF316B5C);
  final Color softBg = const Color(0xFFF7F9F8);

  late final PageController _pageController;
  late ProgressController progressC;
  late DashboardController dashC;
  late ApiService apiService;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
      dashC = Get.put(DashboardController());
     apiService = ApiService();
    _pageController = PageController(viewportFraction: 0.90);
    _pageController.addListener(() {
      final p = _pageController.page?.round() ?? 0;
      if (p != _currentPage) setState(() => _currentPage = p);
    });
    progressC = Get.put(ProgressController());
    progressC.fetchMonitoringHistory(); 
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    // --- CTA cards ---
    final cards = <_DashboardCardData>[
      _DashboardCardData(
        accent: const Color(0xFFEFF6F4),
        image: 'assets/images/terapi.png',
        title: "Start Monitoring",
        desc: "Ikuti 7 sesi terapi terjadwal dan pantau perkembangan wajahmu.",
        tag: "5 minutes",
        buttonText: "OPEN PROGRESS",
        onPressed: () => Get.to(() => const ProgressView()),
      ),
      _DashboardCardData(
        accent: const Color(0xFFFFF3E9),
        image: 'assets/images/deteksi.png',
        title: "Detect My Face",
        desc: "Scan cepat untuk cek kondisi wajahmu hari ini.",
        tag: "Fast scan",
        buttonText: "START DETECTION",
        onPressed: () => Get.to(() => const IntroDetectionView()),
      ),
    ];

    return Scaffold(
      backgroundColor: softBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            _HeaderHero(mainGreen: mainGreen, controller: dashC),

            const SizedBox(height: 14),

            // Carousel
            SizedBox(
              height: 230,
              child: PageView.builder(
                itemCount: cards.length,
                controller: _pageController,
                itemBuilder: (context, index) {
                  final data = cards[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 18 : 10,
                      right: index == cards.length - 1 ? 18 : 10,
                    ),
                    child: _ModernCtaCard(
                      data: data,
                      mainGreen: mainGreen,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Center(
              child: _PageDots(
                count: cards.length,
                currentIndex: _currentPage,
                activeColor: mainGreen,
              ),
            ),

            const SizedBox(height: 22),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                 
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.crop_free,
                      title: "Detection",
                      subtitle: "Scan",
                      color: mainGreen,
                      onTap: () => Get.to(() => const IntroDetectionView()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.show_chart,
                      title: "Progress",
                      subtitle: "Grafik",
                      color: mainGreen,
                      onTap: () => Get.to(() => const ProgressView()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Artikel / Edukasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _SectionTitle(
                title: "Tentang Bell’s Palsy",
                subtitle: "Edukasi singkat sebelum mulai terapi",
                color: mainGreen,
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FutureBuilder<List<Article>>(
                future: apiService.getArticles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("Gagal memuat edukasi")),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("Belum ada artikel")),
                    );
                  }

                  final articles = snapshot.data!;

                  return Column(
                    children: articles.map((art) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ArticleCard(
                          mainGreen: mainGreen,
                          image: art.imageUrl, // dari backend
                          title: art.title,
                          excerpt: art.content,
                          onTap: () {
                            Get.to(() => ArticleDetailView(article: art));
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Charts inside modern card
            // Progress Insight
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 18),
  child: _SectionTitle(
    title: "Insight",
    subtitle: "Ringkasan progress terapi 7 hari",
    color: mainGreen,
  ),
),
const SizedBox(height: 12),

Obx(() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: ProgressInsightCard(
      values: progressC.progressScores.toList(),
      completedDays: progressC.completedTask.value,
      mainGreen: mainGreen,
    ),
  );
}),


            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _DashboardBottomNav(mainGreen: mainGreen),
    );
  }
}

// =====================
// Header Hero
// =====================
class _HeaderHero extends StatelessWidget {
  final Color mainGreen;
  final DashboardController controller;

  const _HeaderHero({
    required this.mainGreen,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainGreen, mainGreen.withOpacity(0.80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Obx(() {
        final username = controller.name.value.trim();
        final title = username.isEmpty ? "Welcome to Therapalsy" : "Hi, $username 👋";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Mulai recovery journey kamu, pelan-pelan tapi konsisten 🤍",
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.25,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// =====================
// Section Title
// =====================
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================
// CTA Card Model + Widget
// =====================
class _DashboardCardData {
  final Color accent;
  final String image;
  final String title;
  final String desc;
  final String tag;
  final String buttonText;
  final VoidCallback onPressed;

  _DashboardCardData({
    required this.accent,
    required this.image,
    required this.title,
    required this.desc,
    required this.tag,
    required this.buttonText,
    required this.onPressed,
  });
}

class _ModernCtaCard extends StatelessWidget {
  final _DashboardCardData data;
  final Color mainGreen;

  const _ModernCtaCard({
    required this.data,
    required this.mainGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -10,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: data.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                // Left: Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TagChip(text: data.tag, color: mainGreen),
                      const SizedBox(height: 10),
                      Text(
                          data.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.15,
                          ),
                        ),
                      const SizedBox(height: 8),
                     Text(
                          data.desc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.8,
                            height: 1.25,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: data.onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            data.buttonText,
                            style: const TextStyle(
                              fontSize: 13.8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right: Image
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: data.accent.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      data.image,
                      fit: BoxFit.contain,
                    ),
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

class _TagChip extends StatelessWidget {
  final String text;
  final Color color;

  const _TagChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =====================
// Quick Action
// =====================
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// Article Card
// =====================
class _ArticleCard extends StatelessWidget {
  final Color mainGreen;
  final String image;
  final String title;
  final String excerpt;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.mainGreen,
    required this.image,
    required this.title,
    required this.excerpt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: Container(
                width: 96,
                height: 96,
                color: mainGreen.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: mainGreen,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      excerpt,
                      style: const TextStyle(
                        fontSize: 12.3,
                        height: 1.25,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Baca selengkapnya",
                          style: TextStyle(
                            color: mainGreen,
                            fontSize: 12.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: mainGreen, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
class _PageDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;

  const _PageDots({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// =====================
// Bottom Nav
// =====================
class _DashboardBottomNav extends StatelessWidget {
  final Color mainGreen;
  final int currentIndex;

  const _DashboardBottomNav({
    required this.mainGreen,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: mainGreen,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
             Get.offAll(() => const DashboardView());
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
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.crop_free),
            label: 'Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
class ProgressInsightCard extends StatelessWidget {
  List<int> get safeValues => values.isEmpty
    ? List<int>.filled(7, 0)
    : values;
  final List<int> values; // 7 hari
  final int completedDays; // contoh 3
  final Color mainGreen;

   ProgressInsightCard({
    super.key,
    required this.values,
    required this.completedDays,
    required this.mainGreen,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (completedDays.clamp(0, 7)) / 7;

    final spots = <FlSpot>[];
    for (int i = 0; i < safeValues.length; i++) {
  spots.add(FlSpot(i.toDouble() + 1, safeValues[i].toDouble()));
}

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "7-Day Progress Face",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: mainGreen,
            ),
          ),
          const SizedBox(height: 14),

          // ===== LINE CHART =====
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 7,
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black.withOpacity(0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 20,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.black45),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "Day ${value.toInt()}",
                          style: const TextStyle(fontSize: 10, color: Colors.black45),
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue, // biru seperti yang kamu mau
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.6,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== PROGRESS BAR + TEXT =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress: $completedDays / 7 hari",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: mainGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              color: mainGreen,
            ),
          ),

          const SizedBox(height: 10),
          Text(
            completedDays >= 7
                ? "Program selesai 🎉 Kamu bisa lihat evaluasi akhir."
                : "Yuk lanjutkan terapi supaya progress makin stabil.",
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
