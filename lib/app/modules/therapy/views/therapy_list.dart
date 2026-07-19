import 'package:bellspalsy_app/app/modules/dashboard/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/therapy_controller.dart';
import 'therapy_video.dart';
import 'package:lottie/lottie.dart';

class TherapyList extends StatelessWidget {
  final int day;
  const TherapyList({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TherapyController());
    controller.selectedDay.value = day;

    final exercises = controller.getExercisesByDay(day);

    const Color mainGreen = Color(0xFF306A5A);
    const Color softGreen = Color(0xFFEAF6F1);
    const Color bgColor = Color(0xFFF7FAF9);

    final dayTitle = _dayTitle(day);
    final daySubtitle = _daySubtitle(day);
    final dayQuote = _dayQuote(day);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.offAll(
                          () => const DashboardView(),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'THERAPY DAY $day',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.black,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: controller.getTotalDuration(exercises),
                      builder: (context, snapshot) {
                        return _TherapyHeaderCard(
                          day: day,
                          dayTitle: dayTitle,
                          daySubtitle: daySubtitle,
                          dayQuote: dayQuote,
                          exerciseCount: exercises.length,
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Today’s Exercises',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: softGreen,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${exercises.length} steps',
                            style: const TextStyle(
                              color: mainGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Complete the exercises slowly and comfortably.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (exercises.isEmpty)
                      _EmptyExerciseCard(day: day)
                    else
                      Column(
                        children: List.generate(exercises.length, (index) {
                          final ex = exercises[index];

                          return _ExerciseCard(
                            index: index,
                            title: 'Exercise ${index + 1}',
                            desc: ex['desc'] ?? '',
                            youtubeId: ex['yt_id'] ?? '',
                          );
                        }),
                      ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: exercises.isEmpty
                            ? null
                            : () {
                                controller.currentVideoIndex.value = 0;
                                Get.to(() => const TherapyVideo());
                              },
                        icon: const Icon(Icons.play_arrow_rounded, size: 30),
                        label: const Text(
                          'START EXERCISES',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 8,
                          shadowColor: mainGreen.withOpacity(0.28),
                        ),
                      ),
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

  String _dayTitle(int day) {
    switch (day) {
      case 1:
        return 'Start Gently';
      case 2:
        return 'Build Control';
      case 3:
        return 'Improve Symmetry';
      case 4:
        return 'Strengthen Movement';
      case 5:
        return 'Relax & Repeat';
      case 6:
        return 'Refine Expression';
      case 7:
        return 'Final Recovery Check';
      default:
        return 'Daily Recovery';
    }
  }

  String _daySubtitle(int day) {
    switch (day) {
      case 1:
        return 'Begin with slow and light facial movements.';
      case 2:
        return 'Focus on controlled muscle activation.';
      case 3:
        return 'Train both sides of your face evenly.';
      case 4:
        return 'Keep your movements stable and consistent.';
      case 5:
        return 'Relax your face and avoid forcing the muscles.';
      case 6:
        return 'Pay attention to details in each expression.';
      case 7:
        return 'Complete your weekly therapy program.';
      default:
        return 'Continue your facial therapy routine.';
    }
  }

  String _dayQuote(int day) {
    switch (day) {
      case 1:
        return 'Small steps matter.';
      case 2:
        return 'Control comes with practice.';
      case 3:
        return 'Balance your facial movement.';
      case 4:
        return 'Consistency builds recovery.';
      case 5:
        return 'Relaxation is part of healing.';
      case 6:
        return 'Progress is built daily.';
      case 7:
        return 'Finish strong today.';
      default:
        return 'Keep going.';
    }
  }
}

class _TherapyHeaderCard extends StatelessWidget {
  final int day;
  final String dayTitle;
  final String daySubtitle;
  final String dayQuote;
  final int exerciseCount;

  const _TherapyHeaderCard({
    required this.day,
    required this.dayTitle,
    required this.daySubtitle,
    required this.dayQuote,
    required this.exerciseCount,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF306A5A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 14, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                'assets/lottie/wellness.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 132),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAY $day',
                  style: TextStyle(
                    color: mainGreen.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  dayTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  daySubtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.58),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$exerciseCount guided exercises',
                    style: const TextStyle(
                      color: mainGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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

class _HeroInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon,color: const Color(0xFFF4FBF8), size: 17),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int index;
  final String title;
  final String desc;
  final String youtubeId;
  
  const _ExerciseCard({
    required this.index,
    required this.title,
    required this.desc,
    required this.youtubeId,
    
  });

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF306A5A);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://img.youtube.com/vi/$youtubeId/0.jpg',
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 76,
                      height: 76,
                      color: const Color(0xFFEAF6F1),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: mainGreen,
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: mainGreen,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Step ${index + 1}',
                    style: const TextStyle(
                      color: mainGreen,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _EmptyExerciseCard extends StatelessWidget {
  final int day;

  const _EmptyExerciseCard({
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
        color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Text(
        'No exercises available for Day $day.',
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}