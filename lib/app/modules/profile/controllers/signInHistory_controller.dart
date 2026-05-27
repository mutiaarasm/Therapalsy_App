import 'package:get/get.dart';
import 'package:bellspalsy_app/services/api_service.dart';

class SignInHistoryController extends GetxController {

  final ApiService api = ApiService();

  final isLoading = true.obs;

  final histories = <dynamic>[].obs;

  final error = ''.obs;

  @override
  void onInit() {

    super.onInit();

    loadHistory();

  }

  Future<void> loadHistory() async {

    try {

      isLoading.value = true;

      final data = await api.getLoginHistory();

      histories.assignAll(data);

    } catch (e) {

      error.value = e.toString();

    } finally {

      isLoading.value = false;

    }

  }

}