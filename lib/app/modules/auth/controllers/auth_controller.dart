import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final RxInt userId = 0.obs; // menyimpan ID user login
  final RxString token = ''.obs; // menyimpan JWT token

  void setUser(int id, String jwtToken) {
    userId.value = id;
    token.value = jwtToken;
  }

  bool get isLoggedIn => token.value.isNotEmpty;
}