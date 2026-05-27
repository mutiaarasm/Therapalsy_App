import 'package:get/get.dart';

import '../controllers/privacy_police_controller.dart';

class PrivacyPoliceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacyPoliceController>(
      () => PrivacyPoliceController(),
    );
  }
}
