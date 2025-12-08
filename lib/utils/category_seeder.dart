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
      debugPrint('🌱 Seeding/updating default categories with UPSERT...');
      
      // Upsert all categories with merge to fix missing fields
      for (var categoryData in _defaultCategories) {
        final category = models.Category(
          id: categoryData['key'],  // Use key as document ID
          name: categoryData['name'],
          key: categoryData['key'],
          isVisible: true,
          sortOrder: _defaultCategories.indexOf(categoryData),
        );
        
        // Use addCategory which will set the document
        await FirebaseDbService.addCategory(category);
        debugPrint('✅ Upserted: ${category.name} (id: ${category.id}, key: ${category.key}, visible: ${category.isVisible}, sortOrder: ${category.sortOrder})');
      }
      
      debugPrint('✅ Category seeding completed! All categories now have key and sortOrder fields.');
    } catch (e) {
      debugPrint('❌ Error seeding categories: $e');
    }
  }

  static List<String> get defaultCategories => 
      _defaultCategories.map((c) => c['name'] as String).toList();
}
