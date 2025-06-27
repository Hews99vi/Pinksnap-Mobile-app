import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinksmapmobile/utils/theme.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PinkSnapApp());
}

class PinkSnapApp extends StatelessWidget {
  const PinkSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PinkSnap',
      theme: AppTheme.lightTheme,
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
