import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirebaseDbService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products Collection
  static const String _productsCollection = 'products';
  static const String _categoriesCollection = 'categories';
  static const String _cartsCollection = 'carts';
  static const String _ordersCollection = 'orders';
  static const String _wishlistsCollection = 'wishlists';

  // ==== PRODUCTS ====
  
  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
    return null;
  }

  // Add product (Admin only)
  static Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_productsCollection)
          .add(product.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product (Admin only)
  static Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (Admin only)
  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ==== CATEGORIES ====

  // Get all categories
  static Future<List<String>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_categoriesCollection)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['name'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // ==== CART ====

  // Get user's cart
  static Future<List<CartItem>> getUserCart(String userId) async {
    try {
      DocumentSnapshot cartDoc = await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>;
        List<dynamic> items = cartData['items'] ?? [];
        
        return items
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  // Update user's cart
  static Future<void> updateUserCart(String userId, List<CartItem> cartItems) async {
    try {
      await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .set({
            'items': cartItems.map((item) => item.toJson()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  // Clear user's cart
  static Future<void> clearUserCart(String userId) async {
    try {
      await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ==== WISHLIST ====

  // Get user's wishlist
  static Future<List<String>> getUserWishlist(String userId) async {
    try {
      DocumentSnapshot wishlistDoc = await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .get();

      if (wishlistDoc.exists) {
        Map<String, dynamic> wishlistData = wishlistDoc.data() as Map<String, dynamic>;
        return List<String>.from(wishlistData['productIds'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get wishlist: $e');
    }
  }

  // Add to wishlist
  static Future<void> addToWishlist(String userId, String productId) async {
    try {
      await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .set({
            'productIds': FieldValue.arrayUnion([productId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  // Remove from wishlist
  static Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .update({
            'productIds': FieldValue.arrayRemove([productId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  // ==== ORDERS ====

  // Create order
  static Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_ordersCollection)
          .add({
            ...orderData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Update order status (Admin only)
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ==== REAL-TIME LISTENERS ====

  // Listen to products
  static Stream<List<Product>> listenToProducts() {
    return _firestore
        .collection(_productsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Listen to user's cart
  static Stream<List<CartItem>> listenToUserCart(String userId) {
    return _firestore
        .collection(_cartsCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            Map<String, dynamic> cartData = doc.data() as Map<String, dynamic>;
            List<dynamic> items = cartData['items'] ?? [];
            return items
                .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <CartItem>[];
        });
  }
}
