import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../services/firebase_db_service.dart';
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
  
  // Make wishlist products reactive
  List<Product> get wishlistProducts {
    final products = _products.where((product) => _wishlistIds.contains(product.id)).toList();
    debugPrint('Getting wishlist products: ${products.length} products found for wishlist IDs: $_wishlistIds');
    return products;
  }
  
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadCategories();
    _initializeUserData();
  }
  
  void _initializeUserData() {
    final authController = Get.find<AuthController>();
    
    // Load data immediately if user is already logged in
    if (authController.currentUser != null) {
      loadUserCart();
      loadUserWishlist();
    }
    
    // Listen to auth state changes to load user-specific data
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
      List<Product> loadedProducts = await FirebaseDbService.getAllProducts();
      _products.assignAll(loadedProducts);
    } catch (e) {
      debugPrint('Error loading products: $e');
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> loadCategories() async {
    try {
      List<String> loadedCategories = await FirebaseDbService.getCategories();
      _categories.assignAll(loadedCategories);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }
  
  Future<bool> addProduct(Product product) async {
    try {
      _isLoading.value = true;
      
      String productId = await FirebaseDbService.addProduct(product);
      
      // Update local list with the new product ID
      Product newProduct = Product(
        id: productId,
        name: product.name,
        description: product.description,
        price: product.price,
        images: product.images,
        category: product.category,
        sizes: product.sizes,
        stock: product.stock,
        rating: product.rating,
        reviewCount: product.reviewCount,
      );
      
      _products.add(newProduct);
      
      // Refresh categories if a category controller exists
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
      
      final index = _products.indexWhere((p) => p.id == product.id);
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
  
  // ==== CART ====
  
  Future<void> loadUserCart() async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;
    
    try {
      List<CartItem> cartItems = await FirebaseDbService.getUserCart(
        authController.currentUser!.id,
      );
      
      // Fix for default "Classic White Blouse" appearing in all new user carts
      // Check if there's only one item and it's the Classic White Blouse
      if (cartItems.length == 1 && 
          cartItems[0].productName == 'Classic White Blouse' &&
          cartItems[0].price == 45.99) {
        debugPrint('Detected default item in cart for new user. Clearing default item.');
        // Clear the cart in Firebase
        await FirebaseDbService.clearUserCart(authController.currentUser!.id);
        // Clear local cart items
        _cartItems.clear();
      } else {
        // Proceed normally with the loaded cart
        _cartItems.assignAll(cartItems);
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
  
  Future<void> addToCart(Product product, String size, int quantity) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) {
      Get.snackbar('Error', 'Please login to add items to cart');
      return;
    }
    
    try {
      // Check if item already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.productId == product.id && item.size == size,
      );
      
      if (existingItemIndex != -1) {
        // Update quantity
        _cartItems[existingItemIndex] = CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          size: size,
          quantity: _cartItems[existingItemIndex].quantity + quantity,
          productImage: product.images.isNotEmpty ? product.images.first : '',
        );
      } else {
        // Add new item
        _cartItems.add(CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          size: size,
          quantity: quantity,
          productImage: product.images.isNotEmpty ? product.images.first : '',
        ));
      }
      
      await FirebaseDbService.updateUserCart(
        authController.currentUser!.id,
        _cartItems,
      );
      
      Get.snackbar('Success', 'Item added to cart');
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      Get.snackbar('Error', 'Failed to add item to cart');
    }
  }
  
  Future<void> removeFromCart(CartItem item) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;
    
    try {
      _cartItems.removeWhere(
        (cartItem) => cartItem.productId == item.productId && cartItem.size == item.size,
      );
      
      await FirebaseDbService.updateUserCart(
        authController.currentUser!.id,
        _cartItems,
      );
      
      Get.snackbar('Success', 'Item removed from cart');
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      Get.snackbar('Error', 'Failed to remove item from cart');
    }
  }
  
  Future<void> clearCart() async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;
    
    try {
      await FirebaseDbService.clearUserCart(authController.currentUser!.id);
      _cartItems.clear();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
  
  // ==== WISHLIST ====
  
  Future<void> loadUserWishlist() async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) {
      debugPrint('No user logged in, cannot load wishlist');
      _wishlistIds.clear(); // Ensure wishlist is cleared when no user
      return;
    }
    
    try {
      debugPrint('Loading wishlist for user: ${authController.currentUser!.id} (${authController.currentUser!.email})');
      List<String> wishlistIds = await FirebaseDbService.getUserWishlist(
        authController.currentUser!.id,
      );
      debugPrint('Loaded ${wishlistIds.length} wishlist IDs from Firestore: $wishlistIds');
      _wishlistIds.assignAll(wishlistIds);
      debugPrint('Current wishlist in controller after loading: $_wishlistIds');
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
      _wishlistIds.clear(); // Clear wishlist on error
    }
  }
  
  Future<void> toggleWishlist(String productId) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) {
      Get.snackbar('Error', 'Please login to manage wishlist');
      return;
    }
    
    try {
      debugPrint('Toggling wishlist for product: $productId');
      debugPrint('User: ${authController.currentUser!.id} (${authController.currentUser!.email})');
      debugPrint('Current wishlist before toggle: $_wishlistIds');
      
      if (_wishlistIds.contains(productId)) {
        await FirebaseDbService.removeFromWishlist(
          authController.currentUser!.id,
          productId,
        );
        _wishlistIds.remove(productId);
        debugPrint('Removed from wishlist. New list: $_wishlistIds');
        Get.snackbar('Success', 'Item removed from wishlist');
      } else {
        await FirebaseDbService.addToWishlist(
          authController.currentUser!.id,
          productId,
        );
        _wishlistIds.add(productId);
        debugPrint('Added to wishlist. New list: $_wishlistIds');
        Get.snackbar('Success', 'Item added to wishlist');
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }
  
  /// Force refresh the current user's wishlist data
  Future<void> refreshWishlist() async {
    debugPrint('Force refreshing wishlist...');
    await loadUserWishlist();
  }

  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }
  
  /// Debug method to check current user and wishlist state
  void debugWishlistState() {
    final authController = Get.find<AuthController>();
    debugPrint('=== WISHLIST DEBUG STATE ===');
    debugPrint('Current user: ${authController.currentUser?.email ?? 'None'}');
    debugPrint('Current user ID: ${authController.currentUser?.id ?? 'None'}');
    debugPrint('Wishlist IDs in controller: $_wishlistIds');
    debugPrint('Wishlist products count: ${wishlistProducts.length}');
    debugPrint('Total products loaded: ${_products.length}');
    debugPrint('============================');
  }

  // ==== UTILITY METHODS ====
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
  
  List<Product> getWishlistProducts() {
    return _products.where((product) => _wishlistIds.contains(product.id)).toList();
  }
}
