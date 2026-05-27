import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {

  final ApiService api = ApiService();

  var isLoading = false.obs;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {

    try {

      isLoading.value = true;

      await api.register(
        name: name,
        email: email,
        password: password,
      );

      isLoading.value = false;

      Get.snackbar(
        "Berhasil",
        "Kode OTP sudah dikirim ke email",
      );

      /// kirim email ke halaman OTP
      Get.toNamed(
        Routes.OTP,
        arguments: email,
      );

    } catch (e) {

      isLoading.value = false;

      Get.snackbar(
        "Register gagal",
        e.toString(),
      );

    }

  }

}