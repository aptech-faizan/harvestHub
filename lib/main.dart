import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_theme.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/data/services/fcm_service.dart';
import 'package:harvest_hub/app/modules/customer/cart/controllers/cart_controller.dart';
import 'package:harvest_hub/app/modules/customer/follow/controllers/follow_controller.dart';
import 'package:harvest_hub/app/modules/customer/wishlist/controllers/wishlist_controller.dart';
import 'package:harvest_hub/app/modules/shared/chat/controllers/chat_inbox_controller.dart';
import 'package:harvest_hub/app/routes/app_pages.dart';
import 'package:harvest_hub/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Firebase initialize karna
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Global permanent controllers inject karna
  Get.put(AuthService(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(WishlistController(), permanent: true);
  Get.put(FollowController(), permanent: true);
  // One inbox controller backs every "chat with farmer" entry point.
  Get.put(ChatInboxController(), permanent: true);

  // FCM only registers this device's token and shows foreground banners;
  // every notification is sent from Cloud Functions.
  await Get.putAsync<FcmService>(() => FcmService().init(), permanent: true);

  runApp(const HarvestHubApp());
}

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HarvestHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
    );
  }
}
