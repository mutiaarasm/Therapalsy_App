import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../therapy/controllers/therapy_controller.dart';

class MaintenanceController extends GetxController {
  final RxInt currentVideoIndex = 0.obs;

  final YoutubeExplode yt = YoutubeExplode();

  late TherapyController therapyController;

  @override
  void onInit() {
    super.onInit();

    therapyController = Get.isRegistered<TherapyController>()
    ? Get.find<TherapyController>()
    : Get.put(TherapyController());
  }

  /// Semua video bebas diakses
  List<Map<String, String>> get allExercises =>
      therapyController.allExercises;

  /// Video yang sedang dipilih
  Map<String, String> get currentExercise =>
      allExercises[currentVideoIndex.value];

  /// Pilih video
  void selectVideo(int index) {
    currentVideoIndex.value = index;
  }

  /// Next video
  void nextVideo() {
    if (currentVideoIndex.value < allExercises.length - 1) {
      currentVideoIndex.value++;
    }
  }

  /// Previous video
  void previousVideo() {
    if (currentVideoIndex.value > 0) {
      currentVideoIndex.value--;
    }
  }

  bool get hasNext =>
      currentVideoIndex.value < allExercises.length - 1;

  bool get hasPrevious =>
      currentVideoIndex.value > 0;

  /// Durasi total semua video maintenance
  Future<String> getTotalDuration() async {
    try {
      int totalSeconds = 0;

      for (final ex in allExercises) {
        final video = await yt.videos.get(ex['yt_id']!);
        totalSeconds += video.duration?.inSeconds ?? 0;
      }

      final minutes = totalSeconds ~/ 60;
      return '$minutes min';
    } catch (e) {
      return '--';
    }
  }

  /// Durasi satu video
  Future<String> getVideoDuration(String ytId) async {
    try {
      final video = await yt.videos.get(ytId);

      final duration = video.duration;

      if (duration == null) return '--';

      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;

      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--';
    }
  }

  /// Reset pilihan
  void resetSelection() {
    currentVideoIndex.value = 0;
  }
}