import 'package:get/get.dart';

import '../controllers/therapy_controller.dart';

class TherapyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TherapyController>(
      () => TherapyController(),
    );
  }
}
