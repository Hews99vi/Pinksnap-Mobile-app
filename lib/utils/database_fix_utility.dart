import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_db_service.dart';
import 'product_validation_helper.dart';

/// One-time database fix utility to correct miscategorized products
/// 
/// This utility will:
/// 1. Scan all products in Firebase
/// 2. Detect products with wrong categoryKeys (e.g., "long sleeve dress" with STRAPLESS_FROCK)
/// 3. Auto-correct them based on product names
/// 
/// USAGE:
/// ```dart
/// // DRY RUN (safe - just shows what would be fixed)
/// await DatabaseFixUtility.fixMiscategorizedProducts(dryRun: true);
/// 
/// // ACTUAL FIX (modifies Firebase - use carefully!)
/// await DatabaseFixUtility.fixMiscategorizedProducts(dryRun: false);
/// ```
class DatabaseFixUtility {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Main method to fix miscategorized products
  static Future<void> fixMiscategorizedProducts({bool dryRun = true}) async {
    debugPrint('\n🔧 ========================================');
    debugPrint('🔧 ${dryRun ? "DRY RUN" : "FIXING"} MISCATEGORIZED PRODUCTS');
    debugPrint('🔧 ========================================\n');

    try {
      // Load all products from Firebase
      final products = await FirebaseDbService.getAllProducts();
      debugPrint('📦 Total products in database: ${products.length}\n');

      int fixedCount = 0;
      int errorCount = 0;
      final List<String> fixedProducts = [];
      final List<String> errorProducts = [];

      // Check each product
      for (final product in products) {
        final fix = await _checkAndFixProduct(product, dryRun: dryRun);
        
        if (fix['fixed'] == true) {
          fixedCount++;
          fixedProducts.add('${product.name} (\$${product.price})');
        } else if (fix['error'] == true) {
          errorCount++;
          errorProducts.add('${product.name}: ${fix['errorMessage']}');
        }
      }

      // Print summary
      debugPrint('\n📊 ========================================');
      debugPrint('📊 ${dryRun ? "DRY RUN" : "FIX"} SUMMARY');
      debugPrint('📊 ========================================');
      debugPrint('Total products: ${products.length}');
      debugPrint('Products ${dryRun ? "would be" : ""} fixed: $fixedCount');
      if (!dryRun && errorCount > 0) {
        debugPrint('Errors: $errorCount');
      }
      
      if (fixedProducts.isNotEmpty) {
        debugPrint('\n✅ Fixed products:');
        for (final p in fixedProducts) {
          debugPrint('   - $p');
        }
      }
      
      if (errorProducts.isNotEmpty) {
        debugPrint('\n❌ Errors:');
        for (final e in errorProducts) {
          debugPrint('   - $e');
        }
      }
      
      if (dryRun && fixedCount > 0) {
        debugPrint('\n💡 To actually fix these products, run:');
        debugPrint('   DatabaseFixUtility.fixMiscategorizedProducts(dryRun: false)');
      }
      
      debugPrint('📊 ========================================\n');

    } catch (e) {
      debugPrint('❌ Fatal error during fix: $e');
    }
  }

  /// Check and fix a single product
  static Future<Map<String, dynamic>> _checkAndFixProduct(
    Product product, {
    required bool dryRun,
  }) async {
    final issues = ProductValidationHelper.validateProduct(product);
    
    // No issues found
    if (issues.isEmpty) {
      return {'fixed': false, 'error': false};
    }

    // Suggest correct categoryKey
    final suggestedKey = ProductValidationHelper.suggestCategoryKey(product.name);
    final normalizedCurrent = Product.normalizeCategoryKey(product.categoryKey);
    
    // If no suggestion or it's already correct, skip
    if (suggestedKey.isEmpty || suggestedKey == normalizedCurrent) {
      return {'fixed': false, 'error': false};
    }

    // Found a mismatch that needs fixing
    debugPrint('${dryRun ? "WOULD FIX" : "FIXING"}: "${product.name}" (\$${product.price})');
    debugPrint('   Current categoryKey: $normalizedCurrent');
    debugPrint('   Suggested categoryKey: $suggestedKey');
    debugPrint('   Issues found:');
    for (final issue in issues) {
      debugPrint('      - $issue');
    }

    // If dry run, just return success
    if (dryRun) {
      debugPrint('   ${dryRun ? "Would update" : "Updated"} in Firebase\n');
      return {'fixed': true, 'error': false};
    }

    // Actually update in Firebase
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update({'categoryKey': suggestedKey});
      
      debugPrint('   ✅ Updated in Firebase\n');
      return {'fixed': true, 'error': false};
      
    } catch (e) {
      debugPrint('   ❌ Error updating: $e\n');
      return {
        'fixed': false,
        'error': true,
        'errorMessage': e.toString(),
      };
    }
  }

  /// Fix specific products by name pattern
  static Future<void> fixProductsByNamePattern({
    required String namePattern,
    required String correctCategoryKey,
    bool dryRun = true,
  }) async {
    debugPrint('\n🔧 Fixing products matching: "$namePattern" -> $correctCategoryKey');
    debugPrint('Mode: ${dryRun ? "DRY RUN" : "ACTUAL FIX"}\n');

    try {
      final products = await FirebaseDbService.getAllProducts();
      int fixedCount = 0;

      for (final product in products) {
        if (product.name.toLowerCase().contains(namePattern.toLowerCase())) {
          final currentKey = Product.normalizeCategoryKey(product.categoryKey);
          
          if (currentKey != correctCategoryKey) {
            debugPrint('${dryRun ? "WOULD FIX" : "FIXING"}: "${product.name}"');
            debugPrint('   Current: $currentKey -> New: $correctCategoryKey');
            
            if (!dryRun) {
              try {
                await _firestore
                    .collection('products')
                    .doc(product.id)
                    .update({'categoryKey': correctCategoryKey});
                debugPrint('   ✅ Updated');
              } catch (e) {
                debugPrint('   ❌ Error: $e');
              }
            }
            
            fixedCount++;
          }
        }
      }

      debugPrint('\n📊 ${dryRun ? "Would fix" : "Fixed"} $fixedCount products\n');
      
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  /// Quick fix for known issues
  static Future<void> quickFix({bool dryRun = true}) async {
    debugPrint('\n🔧 Running quick fixes for known issues...\n');
    
    // Fix "long sleeve" products
    await fixProductsByNamePattern(
      namePattern: 'long sleeve',
      correctCategoryKey: 'LONG_SLEEVE_FROCK',
      dryRun: dryRun,
    );
    
    // Fix "strapless" products  
    await fixProductsByNamePattern(
      namePattern: 'strapless',
      correctCategoryKey: 'STRAPLESS_FROCK',
      dryRun: dryRun,
    );
  }
}
