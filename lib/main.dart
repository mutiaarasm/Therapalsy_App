import 'package:bellspalsy_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiService(), permanent: true); 
   Get.put(AuthController(), permanent: true);
   await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Bellspalsy App',
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
