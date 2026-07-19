import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:get/get.dart';

class AuthResetPasswordController extends GetxController {
  final ApiService api = ApiService();

  String email = '';

  final RxString newPassword = ''.obs;
  final RxString confirmPassword = ''.obs;

  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final dynamic args = Get.arguments;

    if (args is Map) {
      email = (args['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
    }

    print('RESET EMAIL => $email');
  }

  Future<void> resetPassword() async {
    if (isLoading.value) {
      return;
    }

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak ditemukan dari proses OTP.',
      );
      return;
    }

    if (newPassword.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong.',
      );
      return;
    }

    if (newPassword.value.length < 8) {
      Get.snackbar(
        'Error',
        'Password minimal 8 karakter.',
      );
      return;
    }

    if (newPassword.value !=
        confirmPassword.value) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak sama.',
      );
      return;
    }

    try {
      isLoading.value = true;

      await api.resetPassword(
        email: email,
        password: newPassword.value,
      );

      Get.offAllNamed(Routes.LOGIN);

      Get.snackbar(
        'Berhasil',
        'Password berhasil diubah. Silakan login.',
      );
    } catch (error) {
      Get.snackbar(
        'Reset password gagal',
        error
            .toString()
            .replaceFirst('Exception:', '')
            .trim(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
