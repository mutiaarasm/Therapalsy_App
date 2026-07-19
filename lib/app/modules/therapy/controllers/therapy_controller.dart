import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TherapyController extends GetxController {
  var currentVideoIndex = 0.obs;

  final YoutubeExplode yt = YoutubeExplode();

  // Semua video valid dengan fokus
  final List<Map<String, String>> allExercises = [
    {'title': 'Mulut dan pipi', 'desc': 'Ikuti gerakan di depan cermin.', 'yt_id': 'chzl_w2AwxI'},
    {'title': 'Bibir mencucu', 'desc': 'Fokus pada bibir.', 'yt_id': 'lFRoiq6_X-o'},
    {'title': 'Meniup', 'desc': 'Latihan meniup perlahan.', 'yt_id': 'S8WA0ArwyHo'},
    {'title': 'Merentangkan bibir', 'desc': 'Latihan mulut dan pipi.', 'yt_id': '46-R-BXBEl8'},
    {'title': 'Memejamkan Mata', 'desc': 'Fokus otot mata.', 'yt_id': 'Deqbv16u--U'},
    {'title': 'Mengerutkan alis', 'desc': 'Latihan alis.', 'yt_id': 'ZDvFxesPNIE'},
    {'title': 'Memejamkan mata + merentangkan bibir', 'desc': 'Gabungan gerakan mata dan bibir.', 'yt_id': 'f07NDq6L_5M'},
    {'title': 'Berkedip', 'desc': 'Latihan mata ringan.', 'yt_id': 'KqwLXb40lmw'},
    {'title': 'Senyum + memejamkan mata', 'desc': 'Ekspresi wajah penuh.', 'yt_id': '8X_n7N-Ipxw'},
  ];

  var selectedDay = 1.obs;

  /// Ambil 5 video per hari dengan rotasi
  List<Map<String, String>> getExercisesByDay(int day) {
    // Video wajib (mata, mulut, hidung, alis)
    final wajibIds = [
      'chzl_w2AwxI', // Mulut dan pipi
      '46-R-BXBEl8', // Merentangkan bibir
      'Deqbv16u--U', // Memejamkan mata
      'ZDvFxesPNIE', // Mengerutkan alis
    ];

    final wajib = allExercises.where((e) => wajibIds.contains(e['yt_id'])).toList();

    // Video tambahan dari sisa
    final tambahan = allExercises.where((e) => !wajibIds.contains(e['yt_id'])).toList();

    // Ambil 1 video tambahan per hari, rotasi
    final tambahanPerHari = tambahan[(day - 1) % tambahan.length];

    return [...wajib, tambahanPerHari];
  }

  /// Hitung durasi total video (opsional)
  Future<String> getTotalDuration(List<Map<String, String>> exercises) async {
    try {
      int totalSeconds = 0;
      for (final ex in exercises) {
        final video = await yt.videos.get(ex['yt_id']!);
        totalSeconds += video.duration?.inSeconds ?? 0;
      }
      final minutes = totalSeconds ~/ 60;
      return '$minutes min';
    } catch (e) {
      return '--';
    }
  }

  /// Fungsi token video saat repeat, jika ada yang harus diulang 8 kali
  Future<List<Map<String, String>>> repeatVideo(List<Map<String, String>> exercises, String ytId, int repeatCount) async {
    final repeated = <Map<String, String>>[];
    for (var ex in exercises) {
      repeated.add(ex);
      if (ex['yt_id'] == ytId) {
        for (int i = 1; i < repeatCount; i++) {
          repeated.add(ex);
        }
      }
    }
    return repeated;
  }
}