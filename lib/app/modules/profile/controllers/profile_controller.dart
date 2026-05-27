import 'package:get/get.dart';
import 'package:bellspalsy_app/services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService api = ApiService();

  final isLoading = true.obs;
  final name = ''.obs;
  final email = ''.obs;
  final error = ''.obs;
  final avatarUrl = ''.obs;


  @override
  void onInit() {
    super.onInit();
    loadMe();
  }

  Future<void> loadMe() async {
    try {
      isLoading.value = true;
      error.value = '';

      final data = await api.me();
      name.value = (data['name'] ?? '').toString();
      email.value = (data['email'] ?? '').toString();
      avatarUrl.value = (data['avatar_url'] ?? '').toString();

    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
