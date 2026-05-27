import 'package:get/get.dart';
import 'package:bellspalsy_app/services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService api = ApiService();

  final name = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      isLoading.value = true;
      final me = await api.me(); // ambil dari backend
      name.value = (me['name'] ?? '').toString();
    } catch (_) {
      // kalau gagal (misal token kosong), biarin aja fallback
      name.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}