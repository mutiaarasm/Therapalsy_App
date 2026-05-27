import 'package:get/get.dart';

import '../controllers/great_job_controller.dart';

class GreatJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GreatJobController>(
      () => GreatJobController(),
    );
  }
}
