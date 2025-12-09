import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/admin_design_constants.dart';
import '../../widgets/stat_card_widget.dart';
import 'admin_orders_screen.dart';
import 'category_management_screen.dart';
import 'manage_categories_visibility_screen.dart';
import 'add_product_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final OrderController orderController = Get.put(OrderController());
    final AuthController authController = Get.find();

    // Use different layout for web
    if (kIsWeb) {
      return _buildWebDashboard(
        context,
        productController,
        orderController,
        authController,
      );
    }

    // Keep existing mobile layout
    return _buildMobileDashboard(
      context,
      productController,
      orderController,
      authController,
    );
  }

  /// Professional Web Dashboard Layout
  Widget _buildWebDashboard(
    BuildContext context,
    ProductController productController,
    OrderController orderController,
    AuthController authController,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= AdminDesignConstants.breakpointWide;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDesignConstants.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(authController),

          const SizedBox(height: AdminDesignConstants.spacing32),

          // Stats Cards Grid
          _buildStatsGrid(
            productController,
            orderController,
            isWideScreen,
          ),

          const SizedBox(height: AdminDesignConstants.spacing40),

          // Quick Actions Section
          _buildQuickActionsWeb(),

          const SizedBox(height: AdminDesignConstants.spacing40),

          // Recent Activity / Analytics Placeholder
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${authController.currentUser?.name ?? 'Admin'}!',
          style: AdminDesignConstants.headlineLarge.copyWith(
            fontSize: 32,
            fontWeight: AdminDesignConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: AdminDesignConstants.spacing8),
        Text(
          'Here\'s what\'s happening with your store today.',
          style: AdminDesignConstants.bodyLarge.copyWith(
            color: AdminDesignConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    ProductController productController,
    OrderController orderController,
    bool isWideScreen,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isWideScreen ? 4 : 2;
        final childAspectRatio = isWideScreen ? 1.5 : 1.3;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AdminDesignConstants.spacing24,
          mainAxisSpacing: AdminDesignConstants.spacing24,
          childAspectRatio: childAspectRatio,
          children: [
            // Total Products
            Obx(() => StatCardWidget(
              title: 'Total Products',
              value: '${productController.products.length}',
              icon: Icons.inventory_2_rounded,
              color: AdminDesignConstants.primaryBlue,
              subtitle: 'In your catalog',
              trendPercentage: 12.5,
              isPositiveTrend: true,
            )),

            // Categories
            Obx(() => StatCardWidget(
              title: 'Categories',
              value: '${productController.categories.length}',
              icon: Icons.category_rounded,
              color: AdminDesignConstants.accentGreen,
              subtitle: 'Active categories',
              trendPercentage: 3.2,
              isPositiveTrend: true,
            )),

            // Total Orders
            Obx(() => StatCardWidget(
              title: 'Total Orders',
              value: '${orderController.totalOrders}',
              icon: Icons.shopping_bag_rounded,
              color: AdminDesignConstants.warningAmber,
              subtitle: 'All time',
              trendPercentage: 8.7,
              isPositiveTrend: true,
              onTap: () => Get.to(() => const AdminOrdersScreen()),
            )),

            // Revenue
            Obx(() => StatCardWidget(
              title: 'Revenue',
              value: '\$${orderController.totalRevenue.toStringAsFixed(0)}',
              icon: Icons.attach_money_rounded,
              color: const Color(0xFF8b5cf6), // Purple
              subtitle: 'Total earnings',
              trendPercentage: 15.3,
              isPositiveTrend: true,
            )),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AdminDesignConstants.headlineMedium.copyWith(
            fontWeight: AdminDesignConstants.fontWeightBold,
          ),
        ),
        const SizedBox(height: AdminDesignConstants.spacing16),
        Wrap(
          spacing: AdminDesignConstants.spacing16,
          runSpacing: AdminDesignConstants.spacing16,
          children: [
            _buildActionButton(
              label: 'View Orders',
              icon: Icons.list_alt_rounded,
              color: AdminDesignConstants.primaryBlue,
              onTap: () => Get.to(() => const AdminOrdersScreen()),
            ),
            _buildActionButton(
              label: 'Manage Categories',
              icon: Icons.category_rounded,
              color: AdminDesignConstants.accentGreen,
              onTap: () => Get.to(() => const CategoryManagementScreen()),
            ),
            _buildActionButton(
              label: 'Category Visibility',
              icon: Icons.visibility_rounded,
              color: const Color(0xFF8b5cf6),
              onTap: () => Get.to(() => const ManageCategoriesVisibilityScreen()),
            ),
            _buildActionButton(
              label: 'Add New Product',
              icon: Icons.add_circle_rounded,
              color: AdminDesignConstants.infoBlue,
              onTap: () => Get.to(() => const AddProductScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _ActionButton(
      label: label,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(AdminDesignConstants.spacing24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AdminDesignConstants.borderRadiusLarge,
        boxShadow: AdminDesignConstants.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AdminDesignConstants.headlineSmall.copyWith(
                  fontWeight: AdminDesignConstants.fontWeightBold,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: AdminDesignConstants.iconSizeSmall,
                  color: AdminDesignConstants.primaryBlue,
                ),
                label: Text(
                  'View All',
                  style: AdminDesignConstants.bodyMedium.copyWith(
                    color: AdminDesignConstants.primaryBlue,
                    fontWeight: AdminDesignConstants.fontWeightMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminDesignConstants.spacing16),
          _buildActivityItem(
            'New order received',
            'Order #1234 has been placed',
            Icons.shopping_bag_rounded,
            AdminDesignConstants.accentGreen,
            '2 min ago',
          ),
          _buildActivityItem(
            'Product updated',
            'Summer Dress has been updated',
            Icons.inventory_2_rounded,
            AdminDesignConstants.infoBlue,
            '15 min ago',
          ),
          _buildActivityItem(
            'Category added',
            'New category "Accessories" created',
            Icons.category_rounded,
            const Color(0xFF8b5cf6),
            '1 hour ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AdminDesignConstants.spacing12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignConstants.spacing8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AdminDesignConstants.borderRadiusSmall,
            ),
            child: Icon(
              icon,
              size: AdminDesignConstants.iconSizeMedium,
              color: color,
            ),
          ),
          const SizedBox(width: AdminDesignConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AdminDesignConstants.bodyMedium.copyWith(
                    fontWeight: AdminDesignConstants.fontWeightMedium,
                  ),
                ),
                const SizedBox(height: AdminDesignConstants.spacing4),
                Text(
                  subtitle,
                  style: AdminDesignConstants.bodySmall.copyWith(
                    color: AdminDesignConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AdminDesignConstants.bodySmall.copyWith(
              color: AdminDesignConstants.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Existing Mobile Dashboard Layout (unchanged)
  Widget _buildMobileDashboard(
    BuildContext context,
    ProductController productController,
    OrderController orderController,
    AuthController authController,
  ) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome, ${authController.currentUser?.name ?? 'Admin'}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Stats cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Total Products Card
                Obx(
                  () => _buildStatCard(
                    context,
                    title: 'Total Products',
                    value: '${productController.products.length}',
                    icon: Icons.inventory,
                    color: Colors.blue,
                  ),
                ),

                // Categories Card
                Obx(
                  () => _buildStatCard(
                    context,
                    title: 'Categories',
                    value: '${productController.categories.length}',
                    icon: Icons.category,
                    color: Colors.green,
                  ),
                ),

                // Orders Card
                Obx(
                  () => _buildStatCard(
                    context,
                    title: 'Total Orders',
                    value: '${orderController.totalOrders}',
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                  ),
                ),

                // Revenue Card
                Obx(
                  () => _buildStatCard(
                    context,
                    title: 'Revenue',
                    value: '\$${orderController.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.to(() => const AdminOrdersScreen());
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View Orders'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const CategoryManagementScreen());
                  },
                  icon: const Icon(Icons.category),
                  label: const Text('Manage Categories'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const ManageCategoriesVisibilityScreen());
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Manage Category Visibility'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action Button Widget with Hover State
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AdminDesignConstants.borderRadiusMedium,
        child: AnimatedContainer(
          duration: AdminDesignConstants.transitionFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDesignConstants.spacing24,
            vertical: AdminDesignConstants.spacing16,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? widget.color : widget.color.withValues(alpha: 0.1),
            borderRadius: AdminDesignConstants.borderRadiusMedium,
            border: Border.all(
              color: widget.color,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: AdminDesignConstants.iconSizeMedium,
                color: _isHovered ? Colors.white : widget.color,
              ),
              const SizedBox(width: AdminDesignConstants.spacing12),
              Text(
                widget.label,
                style: AdminDesignConstants.bodyMedium.copyWith(
                  color: _isHovered ? Colors.white : widget.color,
                  fontWeight: AdminDesignConstants.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
