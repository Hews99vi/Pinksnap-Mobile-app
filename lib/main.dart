import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:pinksmapmobile/utils/theme.dart';
import 'screens/login_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/image_search_controller.dart';
import 'services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Stripe
  StripeService().init();
  
  // Initialize controllers
  Get.put(AuthController());
  Get.put(ProductController());
  Get.put(CartController());
  Get.put(OrderController());
  Get.put(ImageSearchController());
  
  runApp(const PinkSnapApp());
}

class PinkSnapApp extends StatelessWidget {
  const PinkSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PinkSnap',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
