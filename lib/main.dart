import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/modules/customer/cart/controllers/cart_controller.dart';
import 'app/modules/customer/wishlist/controllers/wishlist_controller.dart';
import 'app/modules/role_select/role_select_view.dart';
import 'dev_menu.dart';

// App ka main entry point jahan Firebase aur permanent controllers initialize hote hain
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize karna
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Global permanent controllers inject karna
  Get.put(CartController(), permanent: true);
  Get.put(WishlistController(), permanent: true);

  runApp(const MyApp());
}

// HarvestHub application root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HarvestHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      // TODO: splash screen baad mein
      home: const RoleSelectView(),
    );
  }
}