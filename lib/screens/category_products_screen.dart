import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../widgets/product_card.dart';
import '../utils/responsive.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryKey;  // ✅ Add categoryKey parameter
  
  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.categoryKey,  // ✅ Required for proper filtering
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late final search_ctrl.SearchController searchController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController = Get.put(search_ctrl.SearchController(), tag: widget.categoryName);
    
    // Set the category filter when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a delay to ensure the controller is fully initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          // ✅ Use categoryKey for filtering (already normalized)
          debugPrint('📍 Setting category filter: key="${widget.categoryKey}", name="${widget.categoryName}"');
          searchController.updateCategory(widget.categoryKey);
          
          // 🔍 Verify filtered count matches tile count
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              final filteredCount = searchController.filteredProducts.length;
              debugPrint('🔍 Filtered products for "${widget.categoryName}": $filteredCount items');
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withValues(alpha: 0.1),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
        actions: [
          Obx(() {
            final products = searchController.filteredProducts;
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: Center(
                child: products.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${products.length} items',
                          style: TextStyle(
                            color: Colors.pink[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar for this category
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => searchController.updateSearchQuery(value),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.categoryName.toLowerCase()}...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.pink[400],
                      size: 24,
                    ),
                  ),
                  suffixIcon: Obx(() {
                    final query = searchController.searchQuery;
                    return query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              searchController.updateSearchQuery('');
                            },
                          )
                        : const SizedBox();
                  }),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),

            // Category Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)], // Light pink colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF8BBD9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.categoryName),
                      color: Colors.pink[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.categoryName} Collection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[800],
                          ),
                        ),
                        Obx(() {
                          final products = searchController.filteredProducts;
                          return Text(
                            'Discover ${products.length} amazing products',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.pink[600],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: Obx(() {
                final products = searchController.filteredProducts;
                
                if (products.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFFEEEEEE), const Color(0xFFF5F5F5)], // Light grey colors
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(widget.categoryName),
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No ${widget.categoryName} Found',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'re currently updating our ${widget.categoryName.toLowerCase()} collection.\nCheck back soon for new arrivals!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Responsive grid with max-width constraint
                final crossAxisCount = Responsive.value<int>(
                  context: context,
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                );
                
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.isDesktop(context) ? 1400.0 : double.infinity,
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(Responsive.isDesktop(context) ? 20 : 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.72, // Same as image search to avoid overflow
                        crossAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                        mainAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Get.to(() => ProductDetailsScreen(product: product));
                          },
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'dresses':
        return Icons.checkroom_rounded;
      case 'tops':
        return Icons.shopping_bag_rounded;
      case 'pants':
        return Icons.dry_cleaning_rounded;
      case 'skirts':
        return Icons.checkroom_outlined;
      case 'accessories':
        return Icons.diamond_rounded;
      case 'shoes':
        return Icons.settings_accessibility_rounded;
      case 'bags':
        return Icons.work_rounded;
      case 'jewelry':
        return Icons.tungsten_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Safely dispose the search controller
    try {
      Get.delete<search_ctrl.SearchController>(tag: widget.categoryName);
    } catch (e) {
      // Controller may already be disposed
      print('Controller already disposed: $e');
    }
    super.dispose();
  }
}