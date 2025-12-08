import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart' as models;

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
  static Future<List<models.Category>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_categoriesCollection)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return models.Category.fromDoc(doc.id, data);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      throw Exception('Failed to get categories: $e');
    }
  }

  // Add a new category (or upsert with merge to fix missing fields)
  static Future<void> addCategory(models.Category category) async {
    try {
      // Use category.id if provided, otherwise use key, otherwise generate from name
      final docId = category.id.isNotEmpty 
          ? category.id
          : (category.key.isNotEmpty 
              ? category.key 
              : category.name.toLowerCase().replaceAll(' ', '_'));
      
      // Use merge: true to upsert (update existing or create new)
      await _firestore
          .collection(_categoriesCollection)
          .doc(docId)
          .set({
        ...category.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ Upserted category: ${category.name} (id: $docId) with key: ${category.key}, visibility: ${category.isVisible}');
    } catch (e) {
      debugPrint('❌ Error adding category: $e');
      throw Exception('Failed to add category: $e');
    }
  }

  // Update a category
  static Future<void> updateCategory(models.Category oldCategory, models.Category newCategory) async {
    try {
      // Use document IDs
      final oldDocId = oldCategory.id;
      final newDocId = newCategory.id;
      
      // Create new category document
      await _firestore
          .collection(_categoriesCollection)
          .doc(newDocId)
          .set({
        ...newCategory.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Delete old category document if ID changed
      if (oldDocId != newDocId) {
        await _firestore
            .collection(_categoriesCollection)
            .doc(oldDocId)
            .delete();
      }

      // Update all products with old category to new category
      if (oldCategory.name != newCategory.name) {
        QuerySnapshot products = await _firestore
            .collection(_productsCollection)
            .where('category', isEqualTo: oldCategory.name)
            .get();

        WriteBatch batch = _firestore.batch();
        for (QueryDocumentSnapshot product in products.docs) {
          batch.update(product.reference, {'category': newCategory.name});
        }
        await batch.commit();
      }
      
      debugPrint('Updated category: ${oldCategory.name} -> ${newCategory.name}');
    } catch (e) {
      debugPrint('Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  // Update category visibility
  static Future<void> updateCategoryVisibility(models.Category category, bool isVisible) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)  // Use Firestore document ID
          .update({
        'isVisible': isVisible,
      });
      
      debugPrint('✅ Updated visibility for ${category.name} (id: ${category.id}): $isVisible');
    } catch (e) {
      debugPrint('❌ Error updating category visibility for ${category.name} (id: ${category.id}): $e');
      throw Exception('Failed to update category visibility: $e');
    }
  }

  // Delete a category
  static Future<void> deleteCategory(models.Category category) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)  // Use document ID
          .delete();
      
      debugPrint('✅ Deleted category: ${category.name} (id: ${category.id})');
    } catch (e) {
      debugPrint('❌ Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }

  // Check if category has products
  static Future<bool> categoryHasProducts(String categoryName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: categoryName)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check category products: $e');
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
      debugPrint('FirebaseDbService: Getting wishlist for user: $userId');
      DocumentSnapshot wishlistDoc = await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .get();

      if (wishlistDoc.exists) {
        Map<String, dynamic> wishlistData = wishlistDoc.data() as Map<String, dynamic>;
        List<String> productIds = List<String>.from(wishlistData['productIds'] ?? []);
        debugPrint('FirebaseDbService: Found wishlist document with ${productIds.length} items: $productIds');
        return productIds;
      } else {
        debugPrint('FirebaseDbService: No wishlist document found for user: $userId');
        return [];
      }
    } catch (e) {
      debugPrint('FirebaseDbService: Error getting wishlist for user $userId: $e');
      throw Exception('Failed to get wishlist: $e');
    }
  }

  // Add to wishlist
  static Future<void> addToWishlist(String userId, String productId) async {
    try {
      debugPrint('FirebaseDbService: Adding product $productId to wishlist for user: $userId');
      await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .set({
            'productIds': FieldValue.arrayUnion([productId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      debugPrint('FirebaseDbService: Successfully added product $productId to wishlist for user: $userId');
    } catch (e) {
      debugPrint('FirebaseDbService: Error adding to wishlist for user $userId: $e');
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  // Remove from wishlist
  static Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      debugPrint('FirebaseDbService: Removing product $productId from wishlist for user: $userId');
      await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .update({
            'productIds': FieldValue.arrayRemove([productId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      debugPrint('FirebaseDbService: Successfully removed product $productId from wishlist for user: $userId');
    } catch (e) {
      debugPrint('FirebaseDbService: Error removing from wishlist for user $userId: $e');
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
