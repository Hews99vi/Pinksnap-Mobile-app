import '../services/firebase_db_service.dart';
import 'package:flutter/foundation.dart';

class CategorySeeder {
  static final List<String> _defaultCategories = [
    'Dresses',
    'Tops',
    'Bottoms',
    'Outerwear',
    'Activewear',
    'Lingerie',
    'Swimwear',
    'Accessories',
    'Shoes',
    'Bags',
  ];

  static Future<void> seedDefaultCategories() async {
    try {
      debugPrint('Seeding default categories...');
      
      // Get existing categories
      List<String> existingCategories = await FirebaseDbService.getCategories();
      
      // Add categories that don't exist
      for (String category in _defaultCategories) {
        if (!existingCategories.contains(category)) {
          await FirebaseDbService.addCategory(category);
          debugPrint('Added category: $category');
        } else {
          debugPrint('Category already exists: $category');
        }
      }
      
      debugPrint('Category seeding completed!');
    } catch (e) {
      debugPrint('Error seeding categories: $e');
    }
  }

  static List<String> get defaultCategories => _defaultCategories;
}
