import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'admin_products_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import '../login_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;
    final AuthController authController = Get.find();

    final List<Widget> screens = [
      const AdminDashboardScreen(),
      const AdminProductsScreen(),
      const AdminOrdersScreen(),
    ];

    // For web, use a simpler layout without sidebar - just show the content
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: const Color(0xFF1e40af), // Professional blue
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authController.logout();
                Get.offAll(() => const LoginScreen());
              },
            ),
          ],
        ),
        body: Obx(() => screens[currentIndex.value]),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: currentIndex.value,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1e40af),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Orders',
              ),
            ],
            onTap: (index) => currentIndex.value = index,
          ),
        ),
      );
    }

    // Keep mobile layout for mobile platforms
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.logout();
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
      ),
      body: Obx(() => screens[currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: currentIndex.value,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
          ],
          onTap: (index) => currentIndex.value = index,
        ),
      ),
    );
  }
}
