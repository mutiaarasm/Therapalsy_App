import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controllers/maintenance_controller.dart';

class MaintenanceVideo extends StatefulWidget {
  const MaintenanceVideo({super.key});

  @override
  State<MaintenanceVideo> createState() =>
      _MaintenanceVideoState();
}

class _MaintenanceVideoState
    extends State<MaintenanceVideo> {

  static const Color mainGreen =
      Color(0xFF306A5A);

  final controller =
      Get.find<MaintenanceController>();

  late YoutubePlayerController
      ytController;

  @override
  void initState() {
    super.initState();

    final exercise =
        controller.currentExercise;

    ytController = YoutubePlayerController(
      initialVideoId:
          exercise['yt_id']!,
      flags:
          const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );
  }

  @override
  void dispose() {
    ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final ex =
        controller.currentExercise;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [

          Padding(
            padding:
                const EdgeInsets.all(20),

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),

              child: YoutubePlayer(
                controller:
                    ytController,
                showVideoProgressIndicator:
                    true,
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,

              decoration:
                  const BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(
                  top:
                      Radius.circular(32),
                ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(24),

                child: Column(
                  children: [

                    Text(
                      ex['title']!,
                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w700,
                        color: mainGreen,
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    Text(
                      ex['desc']!,
                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width:
                          double.infinity,

                      height: 52,

                      child:
                          ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              mainGreen,
                        ),

                        child:
                            const Text(
                          "BACK TO EXERCISES",
                          style:
                              TextStyle(
                            color: Colors
                                .white,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}