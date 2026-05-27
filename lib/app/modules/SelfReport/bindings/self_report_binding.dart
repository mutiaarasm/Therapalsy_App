import 'package:get/get.dart';

import '../controllers/self_report_controller.dart';

class SelfReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfReportController>(
      () => SelfReportController(),
    );
  }
}
