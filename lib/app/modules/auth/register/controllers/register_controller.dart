import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final ApiService api = ApiService();

  final RxBool isLoading = false.obs;

  Future<void> register({
  required String name,
  required String email,
  required String password,
}) async {
  if (isLoading.value) return;

  final normalizedEmail =
      email.trim().toLowerCase();

  try {
    isLoading.value = true;

    await api.register(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );

    // HARUS ke halaman OTP.
    Get.offNamed(
      Routes.OTP,
      arguments: {
        'email': normalizedEmail,
        'type': 'register',
      },
    );

    Get.snackbar(
      'Berhasil',
      'Kode OTP sudah dikirim ke email.',
    );
  } catch (e) {
    Get.snackbar(
      'Register gagal',
      e.toString(),
    );
  } finally {
    isLoading.value = false;
  }
}
}
