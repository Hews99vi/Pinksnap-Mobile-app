import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Dresses',
        'icon': Icons.checkroom_rounded,
        'gradient': [const Color(0xFFFF6B9D), const Color(0xFFFEC1CC)],
        'count': 156,
      },
      {
        'name': 'Tops',
        'icon': Icons.shopping_bag_rounded,
        'gradient': [const Color(0xFF9C27B0), const Color(0xFFCE93D8)],
        'count': 89,
      },
      {
        'name': 'Pants',
        'icon': Icons.dry_cleaning_rounded,
        'gradient': [const Color(0xFF2196F3), const Color(0xFF90CAF9)],
        'count': 64,
      },
      {
        'name': 'Skirts',
        'icon': Icons.checkroom_outlined,
        'gradient': [const Color(0xFFFF9800), const Color(0xFFFFCC80)],
        'count': 42,
      },
      {
        'name': 'Accessories',
        'icon': Icons.diamond_rounded,
        'gradient': [const Color(0xFF4CAF50), const Color(0xFFA5D6A7)],
        'count': 127,
      },
      {
        'name': 'Shoes',
        'icon': Icons.settings_accessibility_rounded,
        'gradient': [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
        'count': 73,
      },
      {
        'name': 'Bags',
        'icon': Icons.work_rounded,
        'gradient': [const Color(0xFF00BCD4), const Color(0xFF80DEEA)],
        'count': 51,
      },
      {
        'name': 'Jewelry',
        'icon': Icons.tungsten_rounded,
        'gradient': [const Color(0xFFFFEB3B), const Color(0xFFFFF59D)],
        'count': 98,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Shop by Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withValues(alpha: 0.1),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1400.0 : double.infinity,
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return GridView.builder(
                padding: EdgeInsets.all(Responsive.isDesktop(context) ? 24 : 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.value<int>(
                    context: context,
                    mobile: 2,
                    tablet: 3,
                    desktop: 4,
                  ),
                  crossAxisSpacing: Responsive.isDesktop(context) ? 24 : 16,
                  mainAxisSpacing: Responsive.isDesktop(context) ? 24 : 16,
                  childAspectRatio: Responsive.isDesktop(context) ? 1.15 : 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final animation = Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.1,
                        (index + 1) * 0.1 + 0.5,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                  );
                  
                  return Transform.scale(
                    scale: animation.value,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: _buildCategoryCard(context, category, index),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, int index) {
    final isHovered = _hoveredIndex == index;
    final gradient = category['gradient'] as List<Color>;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
      child: Card(
        elevation: isHovered ? 12 : 4,
        shadowColor: gradient.first.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to category products
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${category['name']}'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -10,
                  bottom: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          size: Responsive.isDesktop(context) ? 40 : 36,
                          color: gradient.first,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category['count']} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
