import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TherapyController extends GetxController {
  var currentVideoIndex = 0.obs;

  final List<Map<String, String>> allExercises = [
    {'title': 'Latihan 1', 'desc': 'Ikuti gerakan video perlahan.', 'yt_id': 'chzl_w2AwxI'},
    {'title': 'Latihan 2', 'desc': 'Fokus pada otot wajah.', 'yt_id': 'abR1NSb_cTI'},
    {'title': 'Latihan 3', 'desc': 'Ulangi gerakan 10 kali.', 'yt_id': 'lFRoiq6_X-o'},
    {'title': 'Latihan 4', 'desc': 'Rilekskan otot wajah.', 'yt_id': 'bJA8s_41ip0'},
    {'title': 'Latihan 5', 'desc': 'Gunakan cermin saat latihan.', 'yt_id': '1LDmHrCrq2k'},
    {'title': 'Latihan 6', 'desc': 'Jangan terlalu memaksakan.', 'yt_id': '58C2cmmj018'},
    {'title': 'Latihan 7', 'desc': 'Lakukan pemijatan ringan.', 'yt_id': 'air_AhKfXQE'},
    {'title': 'Latihan 8', 'desc': 'Tarik nafas dalam-dalam.', 'yt_id': 'x4n_wiAj8vw'},
    {'title': 'Latihan 9', 'desc': 'Fokus area mata.', 'yt_id': '46-R-BXBEl8'},
    {'title': 'Latihan 10', 'desc': 'Fokus area bibir.', 'yt_id': '18MLYfPNbe4'},
    {'title': 'Latihan 11', 'desc': 'Gerakan simetris.', 'yt_id': 'zOT-BXHqU2w'},
    {'title': 'Latihan 12', 'desc': 'Konsisten adalah kunci.', 'yt_id': 'ZDvFxesPNIE'},
    {'title': 'Latihan 13', 'desc': 'Angkat alis perlahan.', 'yt_id': 'L79yH7Pz7so'},
    {'title': 'Latihan 14', 'desc': 'Kerutkan hidung.', 'yt_id': 'F9OnPzjGB-8'},
    {'title': 'Latihan 15', 'desc': 'Latihan meniup/bersiul.', 'yt_id': '_YdB_qHi55I'},
    {'title': 'Latihan 16', 'desc': 'Tahan posisi 5 detik.', 'yt_id': 'jPIa64aHZuQ'},
    {'title': 'Latihan 17', 'desc': 'Gerakan rahang.', 'yt_id': 'f07NDq6L_5M'},
    {'title': 'Latihan 18', 'desc': 'Tutup mata rapat.', 'yt_id': 'WA2DCpqOivA'},
    {'title': 'Latihan 19', 'desc': 'Buka mulut lebar.', 'yt_id': 'UaQ5kSL44GM'},
    {'title': 'Latihan 20', 'desc': 'Bantu otot dengan jari.', 'yt_id': 'KqwLXb40lmw'},
    {'title': 'Latihan 21', 'desc': 'Ucapkan huruf vokal.', 'yt_id': '8X_n7N-Ipxw'},
    {'title': 'Latihan 22', 'desc': 'Kembangkan pipi.', 'yt_id': '12Up8-dCRLM'},
    {'title': 'Latihan 23', 'desc': 'Pijat rahang bawah.', 'yt_id': 'T77KsOt-b7I'},
    {'title': 'Latihan 24', 'desc': 'Relaksasi otot leher.', 'yt_id': 'AgfkbzEYwwo'},
    {'title': 'Latihan 25', 'desc': 'Penutup sesi latihan.', 'yt_id': 'kuI7mkWPMq4'},
  ];

  var selectedDay = 1.obs;

  /// 🔥 Ambil 5 video per hari
  List<Map<String, String>> getExercisesByDay(int day) {
  return allExercises.take(5).toList();
}

final YoutubeExplode yt = YoutubeExplode();

Future<String> getTotalDuration(
  List<Map<String, String>> exercises,
) async {
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

}