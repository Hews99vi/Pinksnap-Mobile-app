import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'category_mapper.dart';

/// Helper class to validate product data and detect category mismatches
class ProductValidationHelper {
  /// Validates a list of products and logs any detected issues
  static void validateProducts(List<Product> products) {
    debugPrint('🔍 ===== PRODUCT VALIDATION STARTED =====');
    debugPrint('Total products to validate: ${products.length}');
    
    int emptyKeyCount = 0;
    int invalidKeyCount = 0;
    int mismatchCount = 0;
    
    for (final product in products) {
      final issues = validateProduct(product);
      
      if (issues.isNotEmpty) {
        debugPrint('⚠️ Product: "${product.name}" (ID: ${product.id})');
        for (final issue in issues) {
          debugPrint('   - $issue');
          
          if (issue.contains('empty')) emptyKeyCount++;
          if (issue.contains('invalid')) invalidKeyCount++;
          if (issue.contains('MISMATCH')) mismatchCount++;
        }
      }
    }
    
    debugPrint('');
    debugPrint('📊 VALIDATION SUMMARY:');
    debugPrint('   Total products: ${products.length}');
    debugPrint('   Products with empty keys: $emptyKeyCount');
    debugPrint('   Products with invalid keys: $invalidKeyCount');
    debugPrint('   Products with name/key mismatches: $mismatchCount');
    debugPrint('   ✅ Valid products: ${products.length - emptyKeyCount - invalidKeyCount - mismatchCount}');
    debugPrint('🔍 ===== PRODUCT VALIDATION COMPLETED =====');
  }
  
  /// Validates a single product and returns list of issues
  static List<String> validateProduct(Product product) {
    final issues = <String>[];
    final nameLower = product.name.toLowerCase();
    final normalizedKey = Product.normalizeCategoryKey(product.categoryKey);
    
    // Check 1: Empty category key
    if (product.categoryKey.isEmpty || normalizedKey.isEmpty) {
      issues.add('❌ Empty categoryKey');
      return issues;
    }
    
    // Check 2: Invalid model key
    if (!CategoryMapper.isValidModelKey(normalizedKey)) {
      issues.add('❌ Invalid categoryKey "$normalizedKey" - not in model labels');
    }
    
    // Check 3: Name/Category mismatches
    if (nameLower.contains('long sleeve') || nameLower.contains('long-sleeve')) {
      if (normalizedKey != 'LONG_SLEEVE_FROCK') {
        issues.add('🚨 MISMATCH: Name mentions "long sleeve" but categoryKey is "$normalizedKey" (expected: LONG_SLEEVE_FROCK)');
      }
    }
    
    if (nameLower.contains('strapless')) {
      if (normalizedKey != 'STRAPLESS_FROCK') {
        issues.add('🚨 MISMATCH: Name mentions "strapless" but categoryKey is "$normalizedKey" (expected: STRAPLESS_FROCK)');
      }
    }
    
    if (nameLower.contains('strap dress') || (nameLower.contains('strap') && nameLower.contains('dress'))) {
      if (normalizedKey != 'STRAP_DRESS') {
        issues.add('🚨 MISMATCH: Name mentions "strap dress" but categoryKey is "$normalizedKey" (expected: STRAP_DRESS)');
      }
    }
    
    if ((nameLower.contains('hoodie') || nameLower.contains('sweatshirt'))) {
      if (normalizedKey != 'HOODIE') {
        issues.add('⚠️ POSSIBLE MISMATCH: Name mentions "hoodie" but categoryKey is "$normalizedKey" (expected: HOODIE)');
      }
    }
    
    if (nameLower.contains('t-shirt') || nameLower.contains('t shirt') || nameLower.contains('tee')) {
      if (normalizedKey != 'T_SHIRT') {
        issues.add('⚠️ POSSIBLE MISMATCH: Name mentions "t-shirt" but categoryKey is "$normalizedKey" (expected: T_SHIRT)');
      }
    }
    
    if ((nameLower.contains('shorts') || nameLower.contains('short pant')) && !nameLower.contains('sleeve')) {
      if (normalizedKey != 'SHORTS') {
        issues.add('⚠️ POSSIBLE MISMATCH: Name mentions "shorts" but categoryKey is "$normalizedKey" (expected: SHORTS)');
      }
    }
    
    if ((nameLower.contains('shoe') || nameLower.contains('sneaker') || nameLower.contains('boot')) && normalizedKey != 'SHOES') {
      issues.add('⚠️ POSSIBLE MISMATCH: Name mentions footwear but categoryKey is "$normalizedKey" (expected: SHOES)');
    }
    
    if ((nameLower.contains('pant') || nameLower.contains('trouser') || nameLower.contains('jean')) && !nameLower.contains('short')) {
      if (normalizedKey != 'PANTS') {
        issues.add('⚠️ POSSIBLE MISMATCH: Name mentions pants/trousers but categoryKey is "$normalizedKey" (expected: PANTS)');
      }
    }
    
    if (nameLower.contains('shirt') && !nameLower.contains('t-shirt') && !nameLower.contains('sweat')) {
      if (normalizedKey != 'SHIRT') {
        issues.add('⚠️ POSSIBLE MISMATCH: Name mentions "shirt" but categoryKey is "$normalizedKey" (expected: SHIRT)');
      }
    }
    
    if (nameLower.contains('hat') || nameLower.contains('cap') || nameLower.contains('beanie')) {
      if (normalizedKey != 'HAT') {
        issues.add('⚠️ POSSIBLE MISMATCH: Name mentions headwear but categoryKey is "$normalizedKey" (expected: HAT)');
      }
    }
    
    return issues;
  }
  
  /// Suggests correct categoryKey based on product name
  static String suggestCategoryKey(String productName) {
    final nameLower = productName.toLowerCase();
    
    // Dress categories (most specific first)
    if (nameLower.contains('long sleeve') || nameLower.contains('long-sleeve')) {
      return 'LONG_SLEEVE_FROCK';
    }
    if (nameLower.contains('strapless')) {
      return 'STRAPLESS_FROCK';
    }
    if (nameLower.contains('strap') && nameLower.contains('dress')) {
      return 'STRAP_DRESS';
    }
    
    // Top categories
    if (nameLower.contains('hoodie') || nameLower.contains('sweatshirt')) {
      return 'HOODIE';
    }
    if (nameLower.contains('t-shirt') || nameLower.contains('t shirt') || nameLower.contains('tee')) {
      return 'T_SHIRT';
    }
    if (nameLower.contains('shirt') && !nameLower.contains('t-shirt')) {
      return 'SHIRT';
    }
    if (nameLower.contains('top') || nameLower.contains('blouse')) {
      return 'TOP';
    }
    
    // Bottom categories
    if ((nameLower.contains('shorts') || nameLower.contains('short pant')) && !nameLower.contains('sleeve')) {
      return 'SHORTS';
    }
    if (nameLower.contains('pant') || nameLower.contains('trouser') || nameLower.contains('jean')) {
      return 'PANTS';
    }
    
    // Accessories
    if (nameLower.contains('shoe') || nameLower.contains('sneaker') || nameLower.contains('boot')) {
      return 'SHOES';
    }
    if (nameLower.contains('hat') || nameLower.contains('cap') || nameLower.contains('beanie')) {
      return 'HAT';
    }
    
    return ''; // Could not determine
  }
}
