import 'package:bellspalsy_app/app/modules/progress/controllers/progress_controller.dart';
import 'package:bellspalsy_app/app/modules/progress/views/progress_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/maintenance_controller.dart';
import 'maintenance_video.dart';

class MaintenanceTherapyView extends StatelessWidget {
  const MaintenanceTherapyView({super.key});

  static const Color mainGreen = Color(0xFF306A5A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MaintenanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: CustomScrollView(
        slivers: [

          /// HEADER
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: mainGreen,
            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  80,
                  24,
                  24,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: const [

                    Text(
                      "Maintenance\nTherapy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Continue exercising regularly to maintain facial muscle strength.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// INFO CARD
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                  )
                ],
              ),

              child: Row(
                children: [

                  Container(
                    width: 70,
                    height: 70,

                    decoration: BoxDecoration(
                      color:
                          mainGreen.withOpacity(.12),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.favorite,
                      size: 34,
                      color: mainGreen,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "9 Exercises Available",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "You can freely choose any exercise anytime.",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          /// VIDEO LIST
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            sliver: SliverList(
              delegate:
                  SliverChildBuilderDelegate(
                (context, index) {

                  final ex =
                      controller.allExercises[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),

                    child: Material(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(22),

                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(
                                22),

                        onTap: () {

                          controller
                              .selectVideo(
                                  index);

                          Get.to(
                            () =>
                                const MaintenanceVideo(),
                          );
                        },

                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                                  18),

                          child: Row(
                            children: [

                              Container(
                                width: 60,
                                height: 60,

                                decoration:
                                    BoxDecoration(
                                  color: mainGreen
                                      .withOpacity(
                                          .1),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              16),
                                ),

                                child:
                                    const Icon(
                                  Icons
                                      .play_circle_fill,
                                  color:
                                      mainGreen,
                                  size: 34,
                                ),
                              ),

                              const SizedBox(
                                  width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(
                                      ex['title']!,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        fontSize:
                                            16,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            4),

                                    Text(
                                      ex['desc']!,
                                      maxLines:
                                          2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount:
                    controller.allExercises.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  final progressController =
                      Get.find<ProgressController>();

                  await progressController
                      .resetProgram();

                  Get.offAll(
                    () => const ProgressView(),
                  );
                },
                child: const Text(
                  'Start New Monitoring Program',
                ),
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}