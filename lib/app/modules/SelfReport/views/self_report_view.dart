import 'package:bellspalsy_app/app/modules/GreatJob/views/great_job_view.dart';
import 'package:flutter/material.dart';

class SelfReportView extends StatefulWidget {
  const SelfReportView({super.key});

  @override
  State<SelfReportView> createState() => _SelfReportViewState();
}

class _SelfReportViewState extends State<SelfReportView> {
  static const Color mainGreen = Color(0xFF306A5A);
  static const Color softPink = Color(0xFFFFE7E7);

  // 0 berarti belum pilih
  int q1 = 0, q2 = 0, q3 = 0, q4 = 0;

  bool get allAnswered => q1 > 0 && q2 > 0 && q3 > 0 && q4 > 0;

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 28, color: Colors.black54),
          ),
          const Spacer(),
          const Text(
            'SELF REPORT',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              letterSpacing: 1.6,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _ratingRow(int value, ValueChanged<int> onPick) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final int n = i + 1;
        final bool selected = value == n;

        return GestureDetector(
          onTap: () => setState(() => onPick(n)),
          child: Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? mainGreen : Colors.black26,
                    width: 2,
                  ),
                  color: selected ? mainGreen : Colors.transparent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$n',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _questionCard({
    required String question,
    required int value,
    required ValueChanged<int> onPick,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: softPink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Color(0xFF2A3A3D),
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          _ratingRow(value, onPick),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0DADA), // background pinkish seperti mockup
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _questionCard(
                              question:
                                  'Apakah Anda bisa menutup mata sepenuhnya tanpa celah?',
                              value: q1,
                              onPick: (v) => q1 = v,
                            ),
                            _questionCard(
                              question:
                                  'Apakah sudut mulut bisa terangkat saat tersenyum?',
                              value: q2,
                              onPick: (v) => q2 = v,
                            ),
                            _questionCard(
                              question:
                                  'Apakah pipi terasa lebih lentur saat meniup pipi?',
                              value: q3,
                              onPick: (v) => q3 = v,
                            ),
                            _questionCard(
                              question:
                                  'Apakah Anda merasakan peningkatan kontrol otot wajah dibanding kemarin?',
                              value: q4,
                              onPick: (v) => q4 = v,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: allAnswered
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GreatJobView(day: 1),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: mainGreen.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'FINISH',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
