import 'package:bellspalsy_app/app/modules/SelfReport/views/self_report_view.dart';
import 'package:bellspalsy_app/app/modules/detection/views/detection_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/therapy_controller.dart';
import 'package:lottie/lottie.dart';

class TherapyVideo extends StatefulWidget {
  const TherapyVideo({super.key});

  @override
  State<TherapyVideo> createState() => _TherapyVideoState();
}

class _TherapyVideoState extends State<TherapyVideo> {
  static const Color mainGreen = Color(0xFF306A5A);
  static const Color mainPink = Color(0xFFFF7B7B);

  final controller = Get.find<TherapyController>();

  late List<Map<String, String>> exercises;
  late YoutubePlayerController _ytController;

  int _index = 0;

  @override
  void initState() {
    super.initState();

    /// ambil 5 video sesuai day
    exercises = controller.getExercisesByDay(controller.selectedDay.value);
    if (exercises.isEmpty) {
  return;
}

    /// init youtube player
    _ytController = YoutubePlayerController(
      initialVideoId: exercises.isNotEmpty
          ? exercises[_index]['yt_id']!
          : 'chzl_w2AwxI',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  bool get _hasNext => _index < exercises.length - 1;
  bool get _hasPrev => _index > 0;

  void _next() {
    if (_hasNext) {
      setState(() {
        _index++;
        _ytController.load(exercises[_index]['yt_id']!);
      });
    } else {
      _showSessionCompletedDialog();
    }
  }

  void _prev() {
    if (_hasPrev) {
      setState(() {
        _index--;
        _ytController.load(exercises[_index]['yt_id']!);
      });
    }
  }

  void _showSessionCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               SizedBox(
                  width: 140,
                  height: 140,
                  child: Lottie.asset(
                    'assets/lottie/checklist.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "SESSION COMPLETED!",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "Progress: ${controller.selectedDay.value}/7 days",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetectionView(
                            mode: DetectionMode.monitoring,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = exercises[_index];

    return Scaffold(
      backgroundColor: const Color(0xFFAFAFAF),
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text(
                    'LATIHAN ${_index + 1} DARI ${exercises.length}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 YOUTUBE PLAYER (INI YANG FIX EMBED)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: YoutubePlayer(
                  controller: _ytController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: mainGreen,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BOTTOM CONTENT
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Latihan ${_index + 1}',
                        style: const TextStyle(
                          color: mainPink,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ex['desc'] ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                        
                        textAlign: TextAlign.center,
                      ),
                      

                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FAF7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: mainGreen.withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.tips_and_updates_rounded,
                              color: mainGreen,
                              size: 28,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tips Latihan",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Lakukan gerakan secara perlahan di depan cermin. Jangan memaksakan otot wajah jika terasa tidak nyaman.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                       const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _hasNext ? 'BERIKUTNYA' : 'SELESAI',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_hasPrev)
                        TextButton(
                          onPressed: _prev,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black38,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                          child: const Text('SEBELUMNYA'),
                        ),
                    ],
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