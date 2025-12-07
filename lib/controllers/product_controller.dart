import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../services/firebase_db_service.dart';
import '../services/image_search_service.dart';
import 'auth_controller.dart';
import 'category_controller.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final RxList<Product> _products = <Product>[].obs;
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  final RxList<String> _wishlistIds = <String>[].obs;
  final RxList<String> _categories = <String>[].obs;
  final RxBool _isLoading = false.obs;

  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<String> get wishlistIds => _wishlistIds;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading.value;

  List<Product> get wishlistProducts {
    final products = _products
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
    debugPrint(
        'Getting wishlist products: ${products.length} products found for wishlist IDs: $_wishlistIds');
    return products;
  }

  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(
      0.0, (sum, item) => sum + (item.price * item.quantity));

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
    _initializeUserData();
  }

  void _initializeUserData() {
    final authController = Get.find<AuthController>();

    if (authController.currentUser != null) {
      loadUserCart();
      loadUserWishlist();
    }

    ever(authController.currentUserRx, (User? user) {
      debugPrint('Auth state changed - User: ${user?.email ?? 'None'}');
      if (user != null) {
        debugPrint('Loading user data for: ${user.email}');
        loadUserCart();
        loadUserWishlist();
      } else {
        debugPrint('User signed out - clearing cart and wishlist');
        _cartItems.clear();
        _wishlistIds.clear();
      }
    });
  }

  // ==== PRODUCTS ====

  Future<void> loadProducts() async {
    try {
      _isLoading.value = true;
      List<Product> loadedProducts =
          await FirebaseDbService.getAllProducts();
      _products.assignAll(loadedProducts);

      _debugCategoryDistribution();

      debugPrint('🔥 ProductController instance = $hashCode');
      debugPrint('🔥 Products loaded = ${_products.length}');

      // ✅ Rebuild image search index after products load
      if (Get.isRegistered<ImageSearchService>()) {
        Get.find<ImageSearchService>().rebuildIndex();
        debugPrint('✅ ImageSearchService index rebuilt after products load');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      _isLoading.value = false;
    }
  }

  void _debugCategoryDistribution() {
    // TEMPORARY DEBUG - showing categoryKey counts only
    debugPrint("=== CATEGORYKEY COUNTS ===");
    final keyCount = <String, int>{};
    for (final p in _products) {
      final k = p.categoryKey.trim().toUpperCase();
      keyCount[k] = (keyCount[k] ?? 0) + 1;
    }
    keyCount.forEach((k,c) => debugPrint("  $k: $c"));
    debugPrint("==========================");
  }

  Future<void> loadCategories() async {
    try {
      // Delegate to CategoryController for category management
      final categoryController = Get.find<CategoryController>();
      await categoryController.loadCategories();
      // Update local categories list for backward compatibility
      _categories.assignAll(categoryController.categoryNames);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      _isLoading.value = true;

      String productId =
          await FirebaseDbService.addProduct(product);

      // ✅ include categoryKey in the local copy
      Product newProduct = Product(
        id: productId,
        name: product.name,
        description: product.description,
        price: product.price,
        images: product.images,
        category: product.category,
        categoryKey: product.categoryKey, // ✅ NEW
        sizes: product.sizes,
        colors: product.colors,
        stock: product.stock,
        rating: product.rating,
        reviewCount: product.reviewCount,
      );

      _products.add(newProduct);

      try {
        if (Get.isRegistered<CategoryController>()) {
          Get.find<CategoryController>().loadCategories();
        }
      } catch (e) {
        debugPrint('Category controller not found, skipping refresh');
      }

      Get.snackbar('Success', 'Product added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      Get.snackbar('Error', 'Failed to add product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading.value = true;

      await FirebaseDbService.updateProduct(product);

      final index =
          _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }

      Get.snackbar('Success', 'Product updated successfully!');
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      Get.snackbar('Error', 'Failed to update product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading.value = true;

      await FirebaseDbService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);

      Get.snackbar('Success', 'Product deleted successfully!');
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      Get.snackbar('Error', 'Failed to delete product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // ==== CART & WISHLIST ====

  Future<void> loadUserCart() async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.currentUser;
      
      if (user == null) {
        _cartItems.clear();
        return;
      }

      List<CartItem> cartItems = await FirebaseDbService.getUserCart(user.id);
      _cartItems.assignAll(cartItems);
      debugPrint('Loaded ${cartItems.length} cart items for user ${user.email}');
    } catch (e) {
      debugPrint('Error loading user cart: $e');
    }
  }

  Future<void> loadUserWishlist() async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.currentUser;
      
      if (user == null) {
        _wishlistIds.clear();
        return;
      }

      List<String> wishlistIds = await FirebaseDbService.getUserWishlist(user.id);
      _wishlistIds.assignAll(wishlistIds);
      debugPrint('Loaded ${wishlistIds.length} wishlist items for user ${user.email}');
    } catch (e) {
      debugPrint('Error loading user wishlist: $e');
    }
  }

  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.currentUser;
      
      if (user == null) {
        Get.snackbar('Error', 'Please sign in to use wishlist');
        return;
      }

      if (_wishlistIds.contains(productId)) {
        // Remove from wishlist
        _wishlistIds.remove(productId);
        await FirebaseDbService.removeFromWishlist(user.id, productId);
        Get.snackbar('Removed', 'Item removed from wishlist',
            backgroundColor: Colors.grey[800],
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      } else {
        // Add to wishlist
        _wishlistIds.add(productId);
        await FirebaseDbService.addToWishlist(user.id, productId);
        Get.snackbar('Added', 'Item added to wishlist',
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }

  // ==== UTILITY METHODS ====

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// NOW STRICT: treat input as categoryKey
  List<Product> getProductsByCategory(String categoryKey) {
    final key = categoryKey.trim().toUpperCase();
    return _products
        .where((product) =>
            product.categoryKey.trim().toUpperCase() == key)
        .toList();
  }

  List<Product> getWishlistProducts() {
    return _products
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
  }
}
