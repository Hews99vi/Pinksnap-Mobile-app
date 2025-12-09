import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../config/admin_design_constants.dart';
import '../../controllers/auth_controller.dart';
import '../login_screen.dart';

/// Professional Web Layout for Admin Panel
/// Features: Sidebar navigation, professional header, responsive design
class AdminWebLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminWebLayout({
    super.key,
    required this.child,
    this.currentRoute = 'dashboard',
  });

  @override
  State<AdminWebLayout> createState() => _AdminWebLayoutState();
}

class _AdminWebLayoutState extends State<AdminWebLayout> {
  final RxBool _isSidebarExpanded = true.obs;
  String _hoveredItem = '';

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // Return child directly for mobile
      return widget.child;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= AdminDesignConstants.breakpointDesktop;
    final isTablet = screenWidth >= AdminDesignConstants.breakpointMobile &&
        screenWidth < AdminDesignConstants.breakpointDesktop;

    // Auto-collapse sidebar on tablet
    if (isTablet && _isSidebarExpanded.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isSidebarExpanded.value = false;
      });
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(isDesktop),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Professional Header
                _buildHeader(),

                // Page Content
                Expanded(
                  child: Container(
                    color: AdminDesignConstants.backgroundOffWhite,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Professional Sidebar
  Widget _buildSidebar(bool isDesktop) {
    return Obx(() {
      final isExpanded = _isSidebarExpanded.value;
      final sidebarWidth = isExpanded
          ? AdminDesignConstants.sidebarWidthExpanded
          : AdminDesignConstants.sidebarWidthCollapsed;

      return AnimatedContainer(
        duration: AdminDesignConstants.transitionMedium,
        curve: AdminDesignConstants.transitionCurve,
        width: sidebarWidth,
        decoration: BoxDecoration(
          color: AdminDesignConstants.sidebarDark,
          boxShadow: AdminDesignConstants.shadowMedium,
        ),
        child: Column(
          children: [
            // Logo / Brand Area
            _buildSidebarHeader(isExpanded),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AdminDesignConstants.spacing8,
                ),
                children: [
                  _buildNavSection(
                    'Main',
                    [
                      _NavItem(
                        icon: Icons.dashboard_rounded,
                        label: 'Dashboard',
                        route: 'dashboard',
                        subitems: [
                          _NavSubItem(label: 'Overview', route: 'dashboard'),
                          _NavSubItem(label: 'Analytics', route: 'analytics'),
                        ],
                      ),
                    ],
                    isExpanded,
                  ),
                  _buildNavSection(
                    'Management',
                    [
                      _NavItem(
                        icon: Icons.inventory_2_rounded,
                        label: 'Products',
                        route: 'products',
                        subitems: [
                          _NavSubItem(label: 'All Products', route: 'products'),
                          _NavSubItem(label: 'Categories', route: 'categories'),
                          _NavSubItem(label: 'Manage Stock', route: 'stock'),
                        ],
                      ),
                      _NavItem(
                        icon: Icons.shopping_bag_rounded,
                        label: 'Orders',
                        route: 'orders',
                        subitems: [
                          _NavSubItem(label: 'All Orders', route: 'orders'),
                          _NavSubItem(label: 'Pending', route: 'orders_pending'),
                          _NavSubItem(label: 'Completed', route: 'orders_completed'),
                        ],
                      ),
                      _NavItem(
                        icon: Icons.people_rounded,
                        label: 'Users',
                        route: 'users',
                        subitems: [
                          _NavSubItem(label: 'Manage Users', route: 'users'),
                          _NavSubItem(label: 'Roles', route: 'roles'),
                        ],
                      ),
                    ],
                    isExpanded,
                  ),
                  _buildNavSection(
                    'System',
                    [
                      _NavItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        route: 'settings',
                        subitems: [
                          _NavSubItem(label: 'General', route: 'settings'),
                          _NavSubItem(label: 'Payments', route: 'payments'),
                          _NavSubItem(label: 'Notifications', route: 'notifications'),
                        ],
                      ),
                    ],
                    isExpanded,
                  ),
                ],
              ),
            ),

            // Logout Button
            _buildLogoutButton(isExpanded),

            // Toggle Sidebar Button
            if (isDesktop) _buildSidebarToggle(isExpanded),
          ],
        ),
      );
    });
  }

  Widget _buildSidebarHeader(bool isExpanded) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignConstants.spacing16,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AdminDesignConstants.gray700,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AdminDesignConstants.primaryBlue,
              borderRadius: AdminDesignConstants.borderRadiusMedium,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AdminDesignConstants.spacing12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Panel',
                    style: AdminDesignConstants.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: AdminDesignConstants.fontWeightBold,
                    ),
                  ),
                  Text(
                    'PinkSnap',
                    style: AdminDesignConstants.bodySmall.copyWith(
                      color: AdminDesignConstants.gray400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavSection(
    String title,
    List<_NavItem> items,
    bool isExpanded,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignConstants.spacing16,
              vertical: AdminDesignConstants.spacing8,
            ),
            child: Text(
              title.toUpperCase(),
              style: AdminDesignConstants.labelSmall.copyWith(
                color: AdminDesignConstants.gray500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ...items.map((item) => _buildNavItem(item, isExpanded)),
        const SizedBox(height: AdminDesignConstants.spacing8),
      ],
    );
  }

  Widget _buildNavItem(_NavItem item, bool isExpanded) {
    final isActive = widget.currentRoute == item.route;
    final isHovered = _hoveredItem == item.route;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = item.route),
      onExit: (_) => setState(() => _hoveredItem = ''),
      child: Column(
        children: [
          InkWell(
            onTap: () => _navigateTo(item.route),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AdminDesignConstants.spacing8,
                vertical: AdminDesignConstants.spacing4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AdminDesignConstants.spacing12,
                vertical: AdminDesignConstants.spacing12,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AdminDesignConstants.sidebarActive
                    : isHovered
                        ? AdminDesignConstants.sidebarHover
                        : Colors.transparent,
                borderRadius: AdminDesignConstants.borderRadiusMedium,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: AdminDesignConstants.iconSizeMedium,
                    color: isActive || isHovered
                        ? Colors.white
                        : AdminDesignConstants.gray400,
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: AdminDesignConstants.spacing12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AdminDesignConstants.bodyMedium.copyWith(
                          color: isActive || isHovered
                              ? Colors.white
                              : AdminDesignConstants.gray300,
                          fontWeight: isActive
                              ? AdminDesignConstants.fontWeightMedium
                              : AdminDesignConstants.fontWeightRegular,
                        ),
                      ),
                    ),
                    if (item.subitems.isNotEmpty)
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: AdminDesignConstants.iconSizeSmall,
                        color: AdminDesignConstants.gray400,
                      ),
                  ],
                ],
              ),
            ),
          ),
          // Subitems (if expanded and active)
          if (isExpanded && isActive && item.subitems.isNotEmpty)
            ...item.subitems.map((subitem) => _buildSubNavItem(subitem)),
        ],
      ),
    );
  }

  Widget _buildSubNavItem(_NavSubItem subitem) {
    final isActive = widget.currentRoute == subitem.route;

    return InkWell(
      onTap: () => _navigateTo(subitem.route),
      child: Container(
        margin: const EdgeInsets.only(
          left: AdminDesignConstants.spacing48,
          right: AdminDesignConstants.spacing8,
          top: AdminDesignConstants.spacing4,
          bottom: AdminDesignConstants.spacing4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AdminDesignConstants.spacing12,
          vertical: AdminDesignConstants.spacing8,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isActive
                  ? AdminDesignConstants.accentGreen
                  : AdminDesignConstants.gray700,
              width: 2,
            ),
          ),
        ),
        child: Text(
          subitem.label,
          style: AdminDesignConstants.bodySmall.copyWith(
            color: isActive
                ? AdminDesignConstants.accentGreen
                : AdminDesignConstants.gray400,
            fontWeight: isActive
                ? AdminDesignConstants.fontWeightMedium
                : AdminDesignConstants.fontWeightRegular,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isExpanded) {
    final authController = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.all(AdminDesignConstants.spacing12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AdminDesignConstants.gray700,
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () async {
          await authController.logout();
          Get.offAll(() => const LoginScreen());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminDesignConstants.spacing12,
            vertical: AdminDesignConstants.spacing12,
          ),
          decoration: BoxDecoration(
            color: AdminDesignConstants.dangerRed.withValues(alpha: 0.1),
            borderRadius: AdminDesignConstants.borderRadiusMedium,
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: AdminDesignConstants.iconSizeMedium,
                color: AdminDesignConstants.dangerRed,
              ),
              if (isExpanded) ...[
                const SizedBox(width: AdminDesignConstants.spacing12),
                Expanded(
                  child: Text(
                    'Logout',
                    style: AdminDesignConstants.bodyMedium.copyWith(
                      color: AdminDesignConstants.dangerRed,
                      fontWeight: AdminDesignConstants.fontWeightMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarToggle(bool isExpanded) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignConstants.spacing8),
      child: IconButton(
        onPressed: () => _isSidebarExpanded.value = !isExpanded,
        icon: Icon(
          isExpanded
              ? Icons.keyboard_arrow_left_rounded
              : Icons.keyboard_arrow_right_rounded,
          color: AdminDesignConstants.gray400,
        ),
        tooltip: isExpanded ? 'Collapse Sidebar' : 'Expand Sidebar',
      ),
    );
  }

  /// Build Professional Header
  Widget _buildHeader() {
    final authController = Get.find<AuthController>();

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AdminDesignConstants.shadowSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignConstants.spacing24,
      ),
      child: Row(
        children: [
          // Page Title
          Expanded(
            child: Text(
              _getPageTitle(),
              style: AdminDesignConstants.headlineSmall.copyWith(
                color: AdminDesignConstants.textPrimary,
              ),
            ),
          ),

          // Search Bar (placeholder)
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: AdminDesignConstants.gray100,
              borderRadius: AdminDesignConstants.borderRadiusMedium,
            ),
            child: Row(
              children: [
                const SizedBox(width: AdminDesignConstants.spacing12),
                Icon(
                  Icons.search_rounded,
                  size: AdminDesignConstants.iconSizeMedium,
                  color: AdminDesignConstants.gray500,
                ),
                const SizedBox(width: AdminDesignConstants.spacing8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: AdminDesignConstants.bodyMedium.copyWith(
                        color: AdminDesignConstants.gray400,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AdminDesignConstants.spacing24),

          // Notifications Icon
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_rounded,
                  size: AdminDesignConstants.iconSizeLarge,
                  color: AdminDesignConstants.gray600,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AdminDesignConstants.dangerRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Notifications',
          ),

          const SizedBox(width: AdminDesignConstants.spacing12),

          // User Profile
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminDesignConstants.spacing12,
              vertical: AdminDesignConstants.spacing8,
            ),
            decoration: BoxDecoration(
              color: AdminDesignConstants.gray100,
              borderRadius: AdminDesignConstants.borderRadiusMedium,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AdminDesignConstants.primaryBlue,
                  child: Text(
                    (authController.currentUser?.name ?? 'A')[0].toUpperCase(),
                    style: AdminDesignConstants.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: AdminDesignConstants.fontWeightBold,
                    ),
                  ),
                ),
                const SizedBox(width: AdminDesignConstants.spacing8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      authController.currentUser?.name ?? 'Admin',
                      style: AdminDesignConstants.labelMedium.copyWith(
                        color: AdminDesignConstants.textPrimary,
                      ),
                    ),
                    Text(
                      'Administrator',
                      style: AdminDesignConstants.bodySmall.copyWith(
                        color: AdminDesignConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (widget.currentRoute) {
      case 'dashboard':
        return 'Dashboard Overview';
      case 'products':
        return 'Products Management';
      case 'orders':
        return 'Orders Management';
      case 'categories':
        return 'Category Management';
      case 'users':
        return 'User Management';
      case 'settings':
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  void _navigateTo(String route) {
    // Navigation logic will be handled by parent
    // For now, just print for demonstration
    debugPrint('Navigate to: $route');
  }
}

// Helper classes for navigation items
class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final List<_NavSubItem> subitems;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.subitems = const [],
  });
}

class _NavSubItem {
  final String label;
  final String route;

  _NavSubItem({
    required this.label,
    required this.route,
  });
}
