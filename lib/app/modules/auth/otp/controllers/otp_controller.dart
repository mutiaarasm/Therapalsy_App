import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {

  final ApiService api = ApiService();

  var isLoading = false.obs;

  late String email;

  @override
  void onInit() {
    super.onInit();

    email = Get.arguments;
  }

  Future<void> verifyOtp(String otp) async {

    try {

      isLoading.value = true;

      await api.verifyOtp(
        email: email,
        otp: otp,
      );

      isLoading.value = false;

      Get.snackbar(
        "Berhasil",
        "Email sudah terverifikasi",
      );

      Get.offAllNamed(Routes.LOGIN);

    } catch (e) {

      isLoading.value = false;

      Get.snackbar(
        "OTP salah",
        e.toString(),
      );

    }

  }

}