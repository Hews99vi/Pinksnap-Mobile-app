import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../utils/category_mapper.dart';

class FirebaseDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Model labels from labels.txt (Teachable Machine)
  /// Now centralized in CategoryMapper utility

  /// Helper to guarantee valid model keys
  /// Now uses CategoryMapper for consistent validation
  static String _key(String k) {
    final key = k.trim().toUpperCase();
    if (!CategoryMapper.isValidModelKey(key)) {
      throw Exception("Invalid categoryKey '$k'. Must be one of ${CategoryMapper.modelKeys}");
    }
    return key;
  }

  static Future<void> seedDatabase() async {
    try {
      debugPrint('Starting database seeding...');

      await _seedCategories(); // UI use
      await _seedProducts();   // ML + UI use

      debugPrint('Database seeding completed successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
      throw Exception('Failed to seed database: $e');
    }
  }

  static Future<void> _seedCategories() async {
    debugPrint('Seeding categories...');
    
    final categories = [
      'Dresses',
      'Tops',
      'Bottoms',
      'Outerwear',
      'Accessories',
      'Shoes',
      'Activewear',
      'Lingerie',
    ];

    for (String category in categories) {
      await _firestore.collection('categories').add({
        'name': category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    debugPrint('Categories seeded successfully!');
  }

  static Future<void> _seedProducts() async {
    debugPrint('Seeding products...');

    final sampleProducts = [
      // ===== DRESSES =====
      Product(
        id: '',
        name: 'Summer Floral Dress',
        description: 'Beautiful floral print dress perfect for summer occasions.',
        price: 59.99,
        images: [
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=400&fit=crop',
          'https://images.unsplash.com/photo-1566479179817-c8ce4e59f1ad?w=300&h=400&fit=crop',
        ],
        category: 'Dresses',
        categoryKey: _key('STRAP_DRESS'), // ✅ model key
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: {'XS': 5, 'S': 12, 'M': 20, 'L': 15, 'XL': 8},
        rating: 4.6,
        reviewCount: 124,
      ),

      Product(
        id: '',
        name: 'Elegant Evening Strapless Dress',
        description: 'Sophisticated strapless evening dress.',
        price: 129.99,
        images: [
          'https://images.unsplash.com/photo-1469833120660-1a218b53d28a?w=300&h=400&fit=crop',
        ],
        category: 'Dresses',
        categoryKey: _key('STRAPLESS_FROCK'),
        sizes: ['XS', 'S', 'M', 'L'],
        stock: {'XS': 3, 'S': 8, 'M': 12, 'L': 6},
        rating: 4.8,
        reviewCount: 89,
      ),

      // ===== TOPS / SHIRTS =====
      Product(
        id: '',
        name: 'Classic White Blouse',
        description: 'Timeless white blouse perfect for professional or casual wear.',
        price: 45.99,
        images: [
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300&h=400&fit=crop',
        ],
        category: 'Tops',
        categoryKey: _key('SHIRT'),
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: {'XS': 10, 'S': 15, 'M': 25, 'L': 18, 'XL': 12},
        rating: 4.4,
        reviewCount: 203,
      ),

      Product(
        id: '',
        name: 'Striped Long Sleeve Top',
        description: 'Casual striped long sleeve top.',
        price: 32.99,
        images: [
          'https://images.unsplash.com/photo-1571513722275-4b9cde4d1c4a?w=300&h=400&fit=crop',
        ],
        category: 'Tops',
        categoryKey: _key('TOP'),
        sizes: ['S', 'M', 'L', 'XL'],
        stock: {'S': 20, 'M': 30, 'L': 25, 'XL': 15},
        rating: 4.2,
        reviewCount: 156,
      ),

      Product(
        id: '',
        name: 'Oversized Graphic T-Shirt',
        description: 'Soft cotton oversized tee.',
        price: 29.99,
        images: [
          'https://images.unsplash.com/photo-1523381294911-8d3cead13475?w=300&h=400&fit=crop',
        ],
        category: 'Tops',
        categoryKey: _key('T_SHIRT'),
        sizes: ['XS', 'S', 'M', 'L'],
        stock: {'XS': 8, 'S': 18, 'M': 20, 'L': 10},
        rating: 4.5,
        reviewCount: 73,
      ),

      // ===== BOTTOMS / PANTS =====
      Product(
        id: '',
        name: 'High-Waisted Jeans',
        description: 'Classic high-waisted jeans with a modern fit.',
        price: 68.99,
        images: [
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=300&h=400&fit=crop',
        ],
        category: 'Bottoms',
        categoryKey: _key('PANTS'),
        sizes: ['24', '26', '28', '30', '32', '34'],
        stock: {'24': 8, '26': 15, '28': 22, '30': 18, '32': 12, '34': 6},
        rating: 4.7,
        reviewCount: 298,
      ),

      Product(
        id: '',
        name: 'Flowy Wide-Leg Pants',
        description: 'Comfortable and elegant wide-leg pants.',
        price: 52.99,
        images: [
          'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=300&h=400&fit=crop',
        ],
        category: 'Bottoms',
        categoryKey: _key('PANTS'),
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: {'XS': 5, 'S': 12, 'M': 18, 'L': 14, 'XL': 8},
        rating: 4.3,
        reviewCount: 87,
      ),

      // ===== OUTERWEAR (closest model class) =====
      Product(
        id: '',
        name: 'Denim Jacket',
        description: 'Classic denim jacket that goes with everything.',
        price: 78.99,
        images: [
          'https://images.unsplash.com/photo-1551232864-8f4eb48c7953?w=300&h=400&fit=crop',
        ],
        category: 'Outerwear',
        categoryKey: _key('HOODIE'), // closest class in your model
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: {'XS': 6, 'S': 14, 'M': 20, 'L': 16, 'XL': 10},
        rating: 4.5,
        reviewCount: 234,
      ),

      // ===== ACCESSORIES (if you want ML suggestions later, add class in model) =====
      Product(
        id: '',
        name: 'Leather Crossbody Bag',
        description: 'Stylish leather crossbody bag perfect for daily use.',
        price: 89.99,
        images: [
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=400&fit=crop',
        ],
        category: 'Accessories',
        categoryKey: _key('HAT'), // placeholder closest class
        sizes: ['One Size'],
        stock: {'One Size': 25},
        rating: 4.9,
        reviewCount: 178,
      ),

      Product(
        id: '',
        name: 'Statement Earrings',
        description: 'Bold statement earrings.',
        price: 24.99,
        images: [
          'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?w=300&h=400&fit=crop',
        ],
        category: 'Accessories',
        categoryKey: _key('HAT'), // placeholder closest class
        sizes: ['One Size'],
        stock: {'One Size': 50},
        rating: 4.4,
        reviewCount: 92,
      ),

      // ===== SHOES =====
      Product(
        id: '',
        name: 'Everyday Sneakers',
        description: 'Comfortable sneakers for daily wear.',
        price: 74.99,
        images: [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=400&fit=crop',
        ],
        category: 'Shoes',
        categoryKey: _key('SHOES'),
        sizes: ['36', '37', '38', '39', '40'],
        stock: {'36': 6, '37': 10, '38': 12, '39': 8, '40': 5},
        rating: 4.6,
        reviewCount: 141,
      ),
    ];

    for (Product product in sampleProducts) {
      await _firestore.collection('products').add(product.toJson());
    }

    debugPrint('Products seeded successfully!');
  }
}
