import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinksmapmobile/utils/theme.dart';
import 'screens/login_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  Get.put(AuthController());
  Get.put(ProductController());
  
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
