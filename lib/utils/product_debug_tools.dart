/// Example: How to manually validate and fix products
/// 
/// Add this to your app's debug menu or run once during development
/// 

import 'package:flutter/foundation.dart';
import '../services/firebase_db_service.dart';
import '../utils/product_validation_helper.dart';
import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDebugTools {
  /// Run validation and display results
  static Future<void> validateAllProducts() async {
    debugPrint('🔧 Running product validation...');
    
    final products = await FirebaseDbService.getAllProducts();
    ProductValidationHelper.validateProducts(products);
  }
  
  /// Check a single product
  static void validateSingleProduct(Product product) {
    final issues = ProductValidationHelper.validateProduct(product);
    
    if (issues.isEmpty) {
      debugPrint('✅ Product "${product.name}" is valid');
    } else {
      debugPrint('⚠️ Product "${product.name}" has issues:');
      for (final issue in issues) {
        debugPrint('   $issue');
      }
      
      final suggested = ProductValidationHelper.suggestCategoryKey(product.name);
      if (suggested.isNotEmpty && suggested != product.categoryKey) {
        debugPrint('💡 Suggested categoryKey: $suggested (current: ${product.categoryKey})');
      }
    }
  }
  
  /// ONE-TIME FIX: Auto-correct all products in Firebase
  /// ⚠️ USE WITH CAUTION - This modifies your database!
  static Future<void> autoFixAllProducts({bool dryRun = true}) async {
    debugPrint('🔧 ${dryRun ? "DRY RUN" : "FIXING"} products in Firebase...');
    
    final products = await FirebaseDbService.getAllProducts();
    int fixCount = 0;
    int errorCount = 0;
    
    for (final product in products) {
      final issues = ProductValidationHelper.validateProduct(product);
      
      if (issues.isNotEmpty) {
        final suggested = ProductValidationHelper.suggestCategoryKey(product.name);
        
        if (suggested.isNotEmpty && suggested != product.categoryKey) {
          debugPrint('${dryRun ? "WOULD FIX" : "FIXING"}: ${product.name}');
          debugPrint('   Current: ${product.categoryKey}');
          debugPrint('   Suggested: $suggested');
          
          if (!dryRun) {
            try {
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(product.id)
                  .update({'categoryKey': suggested});
              fixCount++;
              debugPrint('   ✅ Updated');
            } catch (e) {
              debugPrint('   ❌ Error: $e');
              errorCount++;
            }
          } else {
            fixCount++;
          }
        }
      }
    }
    
    debugPrint('');
    debugPrint('📊 ${dryRun ? "DRY RUN" : "FIX"} SUMMARY:');
    debugPrint('   Total products: ${products.length}');
    debugPrint('   Products ${dryRun ? "would be" : ""} fixed: $fixCount');
    if (!dryRun && errorCount > 0) {
      debugPrint('   Errors: $errorCount');
    }
  }
  
  /// Display all products grouped by categoryKey
  static Future<void> showCategoryDistribution() async {
    debugPrint('📊 Product Category Distribution:');
    
    final products = await FirebaseDbService.getAllProducts();
    final distribution = <String, List<Product>>{};
    
    for (final product in products) {
      final key = Product.normalizeCategoryKey(product.categoryKey);
      distribution.putIfAbsent(key, () => []).add(product);
    }
    
    final sortedKeys = distribution.keys.toList()..sort();
    
    for (final key in sortedKeys) {
      final productList = distribution[key]!;
      debugPrint('');
      debugPrint('$key: ${productList.length} products');
      for (final p in productList) {
        debugPrint('   - ${p.name}');
      }
    }
  }
}

/// Example usage in your app:
/// 
/// // In a debug button or initialization:
/// ProductDebugTools.validateAllProducts();
/// 
/// // To see what would be fixed (safe):
/// ProductDebugTools.autoFixAllProducts(dryRun: true);
/// 
/// // To actually fix (run once):
/// ProductDebugTools.autoFixAllProducts(dryRun: false);
/// 
/// // To validate a single product:
/// final product = getProductById('some-id');
/// ProductDebugTools.validateSingleProduct(product);
/// 
/// // To see current distribution:
/// ProductDebugTools.showCategoryDistribution();
