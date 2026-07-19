import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final ApiService api = ApiService();

  final RxBool isLoading = false.obs;

  String email = '';
  String type = '';

  @override
  void onInit() {
    super.onInit();
    _readArguments();
  }

  @override
  void onReady() {
    super.onReady();

    // Cadangan apabila controller sempat dibuat sebelum route selesai dibuka.
    if (email.isEmpty || type.isEmpty) {
      _readArguments();
    }
  }

  void _readArguments() {
    final dynamic args = Get.arguments;

    if (args is Map) {
      email = (args['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      type = (args['type'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
    }

    debugPrint('===== OTP ARGUMENTS =====');
    debugPrint('arguments: $args');
    debugPrint('email: $email');
    debugPrint('type: $type');
  }

  String get pageTitle {
    switch (type) {
      case 'register':
        return 'Verifikasi Akun';
      case 'reset':
        return 'Reset Password';
      case 'edit':
        return 'Verifikasi Email';
      default:
        return 'Verifikasi OTP';
    }
  }

  String get pageDescription {
    switch (type) {
      case 'register':
        return 'Masukkan kode 4 digit yang dikirim ke email untuk mengaktifkan akun.';
      case 'reset':
        return 'Masukkan kode 4 digit yang dikirim ke email untuk melanjutkan reset password.';
      case 'edit':
        return 'Masukkan kode 4 digit yang dikirim ke email baru.';
      default:
        return 'Masukkan kode OTP yang dikirim ke email.';
    }
  }

  Future<void> verifyOtp(String input) async {
    if (isLoading.value) {
      return;
    }

    final String otp = input
        .replaceAll(RegExp(r'[^0-9]'), '')
        .trim();

    if (email.isEmpty) {
      Get.snackbar(
        'OTP gagal',
        'Email tidak ditemukan. Silakan ulangi proses sebelumnya.',
      );
      return;
    }

    if (!{'register', 'reset', 'edit'}.contains(type)) {
      Get.snackbar(
        'OTP gagal',
        'Jenis verifikasi OTP tidak valid.',
      );
      return;
    }

    if (otp.length != 4) {
      Get.snackbar(
        'OTP gagal',
        'Kode OTP harus terdiri dari 4 angka.',
      );
      return;
    }

    try {
      isLoading.value = true;

      debugPrint('===== VERIFY OTP =====');
      debugPrint('email: $email');
      debugPrint('type: $type');

      if (type == 'reset') {
        await api.verifyResetOtp(
          email: email,
          otp: otp,
        );
      } else {
        // Dipakai untuk register dan edit email.
        await api.verifyOtp(
          email: email,
          otp: otp,
        );
      }

      if (type == 'register') {
        Get.offAllNamed(Routes.LOGIN);

        Get.snackbar(
          'Berhasil',
          'Akun berhasil diverifikasi. Silakan login.',
        );
        return;
      }

      if (type == 'reset') {
        Get.offNamed(
          Routes.AUTH_RESET_PASSWORD,
          arguments: {
            'email': email,
          },
        );
        return;
      }

      Get.back(
        result: {
          'verified': true,
          'email': email,
        },
      );

      Get.snackbar(
        'Berhasil',
        'Email berhasil diverifikasi.',
      );
    } catch (error) {
      debugPrint('VERIFY OTP ERROR: $error');

      Get.snackbar(
        'OTP gagal',
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
