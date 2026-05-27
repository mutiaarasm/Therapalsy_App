import 'package:bellspalsy_app/app/modules/detection/views/detection_view.dart';
import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetectionResultView extends StatelessWidget {
  const DetectionResultView({super.key});

  Color _statusColor(int totalScore) {
    if (totalScore == 0) return const Color(0xFF22C55E);
    if (totalScore <= 2) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _statusIcon(int totalScore) {
    if (totalScore == 0) return Icons.check_circle_rounded;
    if (totalScore <= 2) return Icons.info_rounded;
    return Icons.warning_amber_rounded;
  }

  String _areaStatus(String area, List<dynamic> abnormalAreas) {
    final isAbnormal = abnormalAreas
        .map((e) => e.toString().toLowerCase())
        .contains(area.toLowerCase());

    return isAbnormal ? 'Perlu diperhatikan' : 'Baik';
  }

  Color _areaColor(String value) {
    if (value.toLowerCase().contains('baik')) {
      return const Color(0xFF22C55E);
    }
    return const Color(0xFFEF4444);
  }

  

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        Map<String, dynamic>.from(Get.arguments ?? {});

    final int totalScore = args['total_skor'] ?? 0;
    final String mode = (args['mode'] ?? 'quick').toString();
    final bool isMonitoring = mode == 'monitoring';
    
    final String classification =
        (args['classification'] ?? 'Normal').toString();

    final List<dynamic> abnormalAreas = args['abnormal_areas'] ?? [];

    final Map<String, dynamic> feedback =
        Map<String, dynamic>.from(args['feedback'] ?? {});

    final String feedbackTitle =
        (feedback['title'] ?? classification).toString();

    final String recommendation =
        (feedback['recommendation'] ?? '').toString();


    final Map<String, dynamic> scores =
        Map<String, dynamic>.from(args['scores'] ?? {});

    const mainGreen = Color(0xFF316B5C);
    final statusColor = _statusColor(totalScore);

    final eyebrowStatus = _areaStatus('Alis', abnormalAreas);
    final eyeStatus = _areaStatus('Mata', abnormalAreas);
    final mouthStatus = _areaStatus('Mulut', abnormalAreas);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
        title: const Text('Hasil Deteksi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MainResultCard(
                icon: _statusIcon(totalScore),
                statusColor: statusColor,
                title: feedbackTitle,
                classification: classification,
                recommendation: recommendation.isEmpty
                    ? 'Hasil ini bukan diagnosis medis akhir. Gunakan sebagai deteksi awal dan pantau secara berkala.'
                    : recommendation,
                totalScore: totalScore,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ringkasan bagian wajah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _FriendlyResultTile(
                icon: Icons.face_retouching_natural,
                title: 'Area alis',
                value: eyebrowStatus,
                valueColor: _areaColor(eyebrowStatus),
              ),
              _FriendlyResultTile(
                icon: Icons.remove_red_eye_outlined,
                title: 'Area mata',
                value: eyeStatus,
                valueColor: _areaColor(eyeStatus),
              ),
              _FriendlyResultTile(
                icon: Icons.mood_outlined,
                title: 'Area mulut',
                value: mouthStatus,
                valueColor: _areaColor(mouthStatus),
              ),
              const SizedBox(height: 18),
              _UserNoteCard(totalScore: totalScore, abnormalAreas: abnormalAreas),
              const SizedBox(height: 18),
             if (scores.isNotEmpty)
              _DetailAnalysisTile(
                scores: scores,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6F4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Catatan: hasil ini merupakan deteksi dini berbasis fitur geometris wajah dan bukan pengganti diagnosis dokter.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (isMonitoring) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // nanti di sini simpan skor ke progress
                      Get.offAllNamed('/progress');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Simpan ke Progress'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                   onPressed: () {
                      Get.off(
                        () => const DetectionView(
                          mode: DetectionMode.monitoring,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: mainGreen,
                      side: const BorderSide(color: mainGreen),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Retake Detection'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.off(
                        () => const DetectionView(
                          mode: DetectionMode.quick,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: totalScore > 2 ? Colors.redAccent : mainGreen,
                      side: BorderSide(
                        color: totalScore > 2 ? Colors.redAccent : mainGreen,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Retake Detection'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: totalScore > 2
                          ? const Color(0xFFDC2626)
                          : mainGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      totalScore == 0
                          ? 'Back'
                          : totalScore <= 2
                              ? 'Start Therapy Now'
                              : 'Start Your Therapy Session',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MainResultCard extends StatelessWidget {
  final IconData icon;
  final Color statusColor;
  final String title;
  final String classification;
  final String recommendation;
  final int totalScore;

  const _MainResultCard({
    required this.icon,
    required this.statusColor,
    required this.title,
    required this.classification,
    required this.recommendation,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 54, color: statusColor),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            classification,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: statusColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recommendation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: Colors.black.withOpacity(0.65),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Total skor: $totalScore / 5',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserNoteCard extends StatelessWidget {
  final int totalScore;
  final List<dynamic> abnormalAreas;

  const _UserNoteCard({
    required this.totalScore,
    required this.abnormalAreas,
  });

  @override
  Widget build(BuildContext context) {
    String text;

    if (totalScore == 0) {
      text = 'Tidak ada area wajah yang melewati batas asimetri. Tetap lakukan pemantauan berkala jika diperlukan.';
    } else if (abnormalAreas.isEmpty) {
      text = 'Terdapat perubahan ringan pada gerakan wajah. Kamu bisa mengulang deteksi dengan pencahayaan yang baik.';
    } else {
      final areas = abnormalAreas.join(', ');
      text = 'Area yang perlu diperhatikan: $areas. Kamu bisa memantau area tersebut melalui sesi monitoring dan terapi.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF316B5C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.8,
                height: 1.45,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailAnalysisTile extends StatelessWidget {
  final Map<String, dynamic> scores;

  const _DetailAnalysisTile({
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.white,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: const Icon(
            Icons.analytics_outlined,
            color: Color(0xFF316B5C),
          ),
          title: const Text(
            'Lihat Detail Analisis',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: const Text('Detail skor dari setiap gerakan wajah'),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skor per gerakan',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            _ScoreTile(title: 'Diam', score: scores['diam']),
            _ScoreTile(title: 'Angkat Alis', score: scores['angkat_alis']),
            _ScoreTile(title: 'Tutup Mata', score: scores['tutup_mata']),
            _ScoreTile(title: 'Senyum', score: scores['senyum']),
            _ScoreTile(title: 'Mencucu', score: scores['mencucu']),
          ],
        ),
      ),
    );
  }
}

class _FriendlyResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color valueColor;

  const _FriendlyResultTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF316B5C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String title;
  final dynamic score;

  const _ScoreTile({
    required this.title,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final int value = int.tryParse(score.toString()) ?? 0;
    final color = value == 1 ? const Color(0xFFEF4444) : const Color(0xFF22C55E);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value == 1 ? 'Asimetri' : 'Simetri',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
