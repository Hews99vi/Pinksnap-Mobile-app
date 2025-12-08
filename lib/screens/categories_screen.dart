import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/responsive.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../models/product.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _hoveredIndex;
  final ProductController productController = Get.find<ProductController>();
  final CategoryController categoryController = Get.find<CategoryController>();

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

  // Dynamic style helper - generates colorful gradient for any category
  Map<String, dynamic> _styleForCategory(String name, String key) {
    final styles = getCategoryStyles();
    if (styles.containsKey(name)) return styles[name]!;

    // ✅ Dynamic fallback palette (no more gray tiles)
    const palettes = [
      [Color(0xFFFF6B9D), Color(0xFFFEC1CC)], // pink
      [Color(0xFF9C27B0), Color(0xFFCE93D8)], // purple
      [Color(0xFF2196F3), Color(0xFF90CAF9)], // blue
      [Color(0xFFFF9800), Color(0xFFFFCC80)], // orange
      [Color(0xFF4CAF50), Color(0xFFA5D6A7)], // green
      [Color(0xFF00BCD4), Color(0xFF80DEEA)], // cyan
      [Color(0xFFFFC107), Color(0xFFFFECB3)], // amber
      [Color(0xFF3F51B5), Color(0xFF9FA8DA)], // indigo
      [Color(0xFFE91E63), Color(0xFFF48FB1)], // pink variant
      [Color(0xFF673AB7), Color(0xFFB39DDB)], // deep purple
      [Color(0xFF009688), Color(0xFF80CBC4)], // teal
      [Color(0xFF8BC34A), Color(0xFFC5E1A5)], // light green
    ];

    final index = key.hashCode.abs() % palettes.length;
    final gradient = palettes[index];

    return {
      'icon': _getIconForCategory(name, key),
      'gradient': gradient,
    };
  }

  // Dynamic icon helper based on category name/key
  IconData _getIconForCategory(String name, String key) {
    final nameLower = name.toLowerCase();
    final keyUpper = key.toUpperCase();

    // Check common patterns
    if (nameLower.contains('dress') || nameLower.contains('frock') || keyUpper.contains('DRESS') || keyUpper.contains('FROCK')) {
      return Icons.checkroom_rounded;
    }
    if (nameLower.contains('top') || nameLower.contains('shirt') || keyUpper.contains('TOP') || keyUpper.contains('SHIRT')) {
      return Icons.shopping_bag_rounded;
    }
    if (nameLower.contains('pant') || nameLower.contains('jean') || keyUpper.contains('PANT') || keyUpper.contains('JEAN')) {
      return Icons.dry_cleaning_rounded;
    }
    if (nameLower.contains('skirt') || keyUpper.contains('SKIRT')) {
      return Icons.checkroom_outlined;
    }
    if (nameLower.contains('shoe') || nameLower.contains('boot') || keyUpper.contains('SHOE') || keyUpper.contains('BOOT')) {
      return Icons.settings_accessibility_rounded;
    }
    if (nameLower.contains('bag') || keyUpper.contains('BAG')) {
      return Icons.work_rounded;
    }
    if (nameLower.contains('hat') || nameLower.contains('cap') || keyUpper.contains('HAT')) {
      return Icons.emergency_rounded;
    }
    if (nameLower.contains('access') || nameLower.contains('jewel') || keyUpper.contains('ACCESS')) {
      return Icons.diamond_rounded;
    }
    if (nameLower.contains('coat') || nameLower.contains('jacket') || nameLower.contains('hoodie') || keyUpper.contains('COAT') || keyUpper.contains('HOODIE')) {
      return Icons.ac_unit_rounded;
    }
    if (nameLower.contains('sweater') || keyUpper.contains('SWEATER')) {
      return Icons.checkroom;
    }
    
    return Icons.category_rounded; // default fallback
  }

  // Define category icons and gradients
  Map<String, Map<String, dynamic>> getCategoryStyles() {
    return {
      'Dresses': {
        'icon': Icons.checkroom_rounded,
        'gradient': [const Color(0xFFFF6B9D), const Color(0xFFFEC1CC)], // Pink
      },
      'Tops': {
        'icon': Icons.shopping_bag_rounded,
        'gradient': [const Color(0xFF9C27B0), const Color(0xFFCE93D8)], // Purple
      },
      'Pants': {
        'icon': Icons.dry_cleaning_rounded,
        'gradient': [const Color(0xFF607D8B), const Color(0xFFB0BEC5)], // Blue-grey
      },
      'Skirts': {
        'icon': Icons.checkroom_outlined,
        'gradient': [const Color(0xFFFF9800), const Color(0xFFFFCC80)], // Orange
      },
      'Accessories': {
        'icon': Icons.diamond_rounded,
        'gradient': [const Color(0xFF795548), const Color(0xFFBCAAA4)], // Brown
      },
      'Shoes': {
        'icon': Icons.settings_accessibility_rounded,
        'gradient': [const Color(0xFFE91E63), const Color(0xFFF48FB1)], // Pink
      },
      'Bags': {
        'icon': Icons.work_rounded,
        'gradient': [const Color(0xFF673AB7), const Color(0xFFB39DDB)], // Deep Purple
      },
      'Jewelry': {
        'icon': Icons.tungsten_rounded,
        'gradient': [const Color(0xFFFFEB3B), const Color(0xFFFFF9C4)], // Yellow
      },
      'Outerwear': {
        'icon': Icons.ac_unit_rounded,
        'gradient': [const Color(0xFF2196F3), const Color(0xFF90CAF9)], // Blue
      },
      'Activewear': {
        'icon': Icons.fitness_center_rounded,
        'gradient': [const Color(0xFF4CAF50), const Color(0xFFA5D6A7)], // Green
      },
      'Lingerie': {
        'icon': Icons.favorite_rounded,
        'gradient': [const Color(0xFFFF5722), const Color(0xFFFFAB91)], // Deep Orange
      },
      'Bottoms': {
        'icon': Icons.checkroom_rounded,
        'gradient': [const Color(0xFF3F51B5), const Color(0xFF9FA8DA)], // Indigo
      },
      'Ankle boot': {
        'icon': Icons.settings_accessibility_rounded,
        'gradient': [const Color(0xFF8BC34A), const Color(0xFFC5E1A5)], // Light Green
      },
      'Bag': {
        'icon': Icons.work_rounded,
        'gradient': [const Color(0xFFFF9C27), const Color(0xFFFFCC80)], // Amber
      },
      // Default style for unknown categories
      'default': {
        'icon': Icons.category_rounded,
        'gradient': [const Color(0xFF9E9E9E), const Color(0xFFE0E0E0)],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
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
          child: Obx(() {
            // ✅ CRITICAL: Access both reactive sources so Obx rebuilds when either changes
            final visibleCategories = categoryController.visibleShopCategories;
            final allProducts = productController.productsRx.toList(); // ✅ Access RxList to trigger reactivity
            
            debugPrint('🔄 Building categories screen: ${visibleCategories.length} categories, ${allProducts.length} products');
            
            // 📊 Debug: Show product distribution by category key
            final keyDistribution = <String, int>{};
            for (final product in allProducts) {
              keyDistribution[product.categoryKey] = (keyDistribution[product.categoryKey] ?? 0) + 1;
            }
            final sortedKeys = keyDistribution.keys.toList()..sort();
            debugPrint('📊 Product distribution: ${sortedKeys.map((k) => '$k=${keyDistribution[k]}').join(', ')}');
            
            if (visibleCategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No categories available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Categories are currently hidden by admin',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Create category data with actual product counts
            // ✅ Compute counts reactively using the loaded products
            final categories = visibleCategories.map((category) {
              final categoryName = category.name;
              
              // ✅ Normalize category key using SAME logic as products (handles HOODIES→HOODIE, etc.)
              final normalizedKey = Product.normalizeCategoryKey(
                category.key.trim().isNotEmpty ? category.key : category.name
              );
              
              // ✅ Count products by normalized key (both sides use same normalization)
              final productCount = allProducts
                  .where((p) => p.categoryKey == normalizedKey)
                  .length;
              
              // ✅ Get style with dynamic colorful fallback (no gray tiles)
              final style = _styleForCategory(categoryName, normalizedKey);
              
              // 🧩 Debug: Verify count calculation with normalization
              debugPrint('🧩 Tile "$categoryName" -> rawKey="${category.key}" normalized="$normalizedKey" count=$productCount');
              
              return {
                'name': categoryName,
                'key': normalizedKey,  // ✅ Store normalized key for navigation
                'icon': style['icon'],
                'gradient': style['gradient'],
                'count': productCount,
              };
            }).toList();

            return AnimatedBuilder(
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
                    childAspectRatio: Responsive.isDesktop(context) ? 1.2 : 1.15,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final animation = Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          (index * 0.1).clamp(0.0, 0.5),
                          ((index + 1) * 0.1 + 0.4).clamp(0.0, 1.0),
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
            );
          }),
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
            final name = category['name'] as String;
            final key = category['key'] as String;
            final count = category['count'] as int;
            
            // 📦 Debug: Trace navigation parameters
            debugPrint('📦 Opening category: name="$name", key="$key", expectedCount=$count');
            
            // Navigate to category products screen with categoryKey
            Get.to(() => CategoryProductsScreen(
              categoryName: name,
              categoryKey: key,  // ✅ Pass key for filtering
            ));
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
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
                          size: Responsive.isDesktop(context) ? 32 : 28,
                          color: gradient.first,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 16 : 14,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${category['count']} items',
                        style: TextStyle(
                          fontSize: 11,
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
