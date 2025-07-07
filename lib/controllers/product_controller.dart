import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/firebase_db_service.dart';
import 'auth_controller.dart';

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
    ever(authController.currentUser.obs, (user) {
      if (user != null) {
        loadUserCart();
        loadUserWishlist();
      } else {
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
      
      Get.snackbar('Success', 'Product added successfully!');
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
      _cartItems.assignAll(cartItems);
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
      return;
    }
    
    try {
      debugPrint('Loading wishlist for user: ${authController.currentUser!.id}');
      List<String> wishlistIds = await FirebaseDbService.getUserWishlist(
        authController.currentUser!.id,
      );
      debugPrint('Loaded wishlist IDs: $wishlistIds');
      _wishlistIds.assignAll(wishlistIds);
      debugPrint('Current wishlist in controller: $_wishlistIds');
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
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
  
  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
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
