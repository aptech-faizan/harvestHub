import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_pages.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import 'package:harvest_hub/firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthService(), permanent: true);
  runApp(const HarvestHubApp());
}

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HarvestHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      // Temporary start page. Later, point this at your splash / role-select screen
      // and send the "Admin" choice to Routes.adminLogin.
      initialRoute: Routes.adminLogin,
      getPages: AppPages.pages,
    );
  }
}
