import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // Reload wishlist data when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ProductController productController = Get.find<ProductController>();
      debugPrint('WishlistScreen: initState - forcing reload of wishlist data');
      await productController.loadUserWishlist();
      debugPrint('WishlistScreen: initState - wishlist reload completed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    
    // Immediate debug output
    debugPrint('WishlistScreen build - Current wishlist IDs: ${productController.wishlistIds}');
    debugPrint('WishlistScreen build - Products loaded: ${productController.products.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              final ProductController productController = Get.find<ProductController>();
              productController.debugWishlistState();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final ProductController productController = Get.find<ProductController>();
              debugPrint('Manual refresh triggered');
              await productController.loadUserWishlist();
              debugPrint('Manual refresh completed');
            },
          ),
        ],
      ),
      body: Obx(() {
        List<Product> wishlistProducts = productController.wishlistProducts;
        
        // Debug logging
        debugPrint('Wishlist screen - wishlist IDs: ${productController.wishlistIds}');
        debugPrint('Wishlist screen - all products count: ${productController.products.length}');
        debugPrint('Wishlist screen - wishlist products count: ${wishlistProducts.length}');
        
        if (wishlistProducts.isEmpty) {
          return _buildEmptyWishlist(context);
        }
        
        return _buildWishlistGrid(context, wishlistProducts, productController);
      }),
    );
  }
  
  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.pink[200],
          ),
          const SizedBox(height: 16),
          Text(
            'Your Wishlist is Empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love by tapping the heart icon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to main screen's home tab
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWishlistGrid(BuildContext context, List<Product> products, ProductController productController) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85, // Increased further to 0.85 for more height
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildWishlistItem(context, products[index], productController);
        },
      ),
    );
  }
  
  Widget _buildWishlistItem(BuildContext context, Product product, ProductController productController) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsScreen(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Remove Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      color: Colors.grey[100],
                    ),
                    child: product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: product.images.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                  ),
                  // Remove from wishlist button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        productController.toggleWishlist(product.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13, // Reduced from 14 to 13
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    if (product.rating > 0) ...[
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 12), // Reduced from 14 to 12
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11, // Reduced from 12 to 11
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2), // Reduced from 4 to 2
                    ],
                    const Spacer(),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // Reduced from 16 to 15
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
