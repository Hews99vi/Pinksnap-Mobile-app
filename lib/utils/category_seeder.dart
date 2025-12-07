import '../services/firebase_db_service.dart';
import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;

class CategorySeeder {
  // Keys MUST match assets/models/labels.txt for ML model compatibility
  static final List<Map<String, dynamic>> _defaultCategories = [
    {'name': 'Hats', 'key': 'HAT'},
    {'name': 'Hoodies', 'key': 'HOODIE'},
    {'name': 'Pants', 'key': 'PANTS'},
    {'name': 'Shirts', 'key': 'SHIRT'},
    {'name': 'Shoes', 'key': 'SHOES'},
    {'name': 'Shorts', 'key': 'SHORTS'},
    {'name': 'Tops', 'key': 'TOP'},
    {'name': 'T-Shirts', 'key': 'T_SHIRT'},
    {'name': 'Long Sleeve Frocks', 'key': 'LONG_SLEEVE_FROCK'},
    {'name': 'Strap Dresses', 'key': 'STRAP_DRESS'},
    {'name': 'Strapless Frocks', 'key': 'STRAPLESS_FROCK'},
  ];

  static Future<void> seedDefaultCategories() async {
    try {
      debugPrint('Seeding default categories...');
      
      // Get existing categories
      List<models.Category> existingCategories = await FirebaseDbService.getCategories();
      
      // Add categories that don't exist
      for (var categoryData in _defaultCategories) {
        if (!existingCategories.any((c) => c.name == categoryData['name'])) {
          final category = models.Category(
            id: categoryData['key'],  // Use key as document ID
            name: categoryData['name'],
            key: categoryData['key'],
            isVisible: true,
            sortOrder: _defaultCategories.indexOf(categoryData),
          );
          await FirebaseDbService.addCategory(category);
          debugPrint('Added category: ${category.name} (id: ${category.id}, visible: ${category.isVisible}, sortOrder: ${category.sortOrder})');
        } else {
          debugPrint('Category already exists: ${categoryData['name']}');
        }
      }
      
      debugPrint('Category seeding completed!');
    } catch (e) {
      debugPrint('Error seeding categories: $e');
    }
  }

  static List<String> get defaultCategories => 
      _defaultCategories.map((c) => c['name'] as String).toList();
}
