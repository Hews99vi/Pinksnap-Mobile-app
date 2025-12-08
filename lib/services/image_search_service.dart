import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import 'tflite_model_service.dart';
import 'package:get/get.dart';

class ImageSearchService {
  final String baseUrl = 'https://your-ml-api-endpoint.com'; // unused for now
  final ProductController _productController = Get.find<ProductController>();
  final TFLiteModelService _tfliteService = TFLiteModelService();

  // Store the last predictions for display/debug
  List<Map<String, dynamic>>? lastPredictions;
  
  // Store predicted category from last search
  String? lastPredictedCategoryKey;
  String? lastPredictedLabel;
  double? lastPredictedConfidence;
  bool isMixedCategoryResults = false; // True if showing fallback/mixed results

  // Build-once index: categoryKey -> products
  final Map<String, List<Product>> _indexByCategoryKey = {};
  bool _indexBuilt = false;

  // Tune this after real-world testing
  // Lowered from 0.78 to 0.55 for better real-world photo matching
  static const double _confidenceThreshold = 0.55;

  /// Normalize label to ML key format: "Long sleeve frock" -> "LONG_SLEEVE_FROCK"
  String _normalizeLabelToKey(String label) {
    final raw = label.trim().toUpperCase();
    
    // Normalize spaces/hyphens first
    final norm = raw.replaceAll(RegExp(r'[\s\-]+'), '_');
    
    // ✅ MUST MATCH product.dart aliasMap exactly!
    // Model keys: HAT, HOODIE, PANTS, SHIRT, SHOES, SHORTS, TOP, T_SHIRT, 
    //             LONG_SLEEVE_FROCK, STRAP_DRESS, STRAPLESS_FROCK
    const aliasMap = {
      'STRAPLESS_FROCKS': 'STRAPLESS_FROCK',
      'STRAP_DRESSES': 'STRAP_DRESS',
      'LONG_SLEEVE_FROCKS': 'LONG_SLEEVE_FROCK',
      'HOODIES': 'HOODIE',
      'T_SHIRTS': 'T_SHIRT',
      'HATS': 'HAT',
      'SHIRTS': 'SHIRT',
      'TOPS': 'TOP',
      // ✅ Model uses PLURAL for these three:
      'SHOE': 'SHOES',      // singular -> model key (SHOES)
      'PANT': 'PANTS',      // singular -> model key (PANTS)
      'SHORT': 'SHORTS',    // singular -> model key (SHORTS)
      // Common variants:
      'BAGS': 'BAG',
      'SKIRTS': 'SKIRT',
      // ✅ Keep FROCKS and DRESSES distinct - do NOT alias to specific types
      'COATS': 'COAT',
      'JACKETS': 'JACKET',
      'JEANS': 'PANTS',             // jeans -> PANTS
      'TROUSERS': 'PANTS',          // trousers -> PANTS
      'SWEATERS': 'SWEATER',
      'T__SHIRT': 'T_SHIRT',        // double underscore cleanup
    };
    
    final result = aliasMap[norm] ?? norm;
    debugPrint('🔥 NORMALIZE: "$label" -> "$raw" -> "$norm" -> "$result"');
    return result;
  }

  /// Build categoryKey index only once (fast lookup later)
  void _buildIndexIfNeeded() {
    if (_indexBuilt) return;

    final allProducts = _productController.products;
    debugPrint('🔥 INDEX BUILD allProducts.length = ${allProducts.length}');

    _indexByCategoryKey.clear();

    for (final p in allProducts) {
      final rawKey = p.categoryKey;
      final key = _normalizeLabelToKey(rawKey); // normalize here too
      
      if (key.isEmpty) {
        debugPrint('⚠️ Product ${p.name} has empty categoryKey');
        continue;
      }
      
      // 🆕 ENHANCED MISMATCH DETECTION with prices and detailed info
      final nameLower = p.name.toLowerCase();
      
      if (nameLower.contains('long sleeve') && key == 'STRAPLESS_FROCK') {
        debugPrint('🚨 MISMATCH FOUND!');
        debugPrint('   Product: "${p.name}"');
        debugPrint('   Price: \$${p.price}');
        debugPrint('   Raw categoryKey from DB: "$rawKey"');
        debugPrint('   Normalized to: "$key"');
        debugPrint('   Expected: "LONG_SLEEVE_FROCK"');
      }
      
      if (nameLower.contains('strapless') && key != 'STRAPLESS_FROCK') {
        debugPrint('🚨 MISMATCH FOUND!');
        debugPrint('   Product: "${p.name}"');
        debugPrint('   Price: \$${p.price}');
        debugPrint('   Raw categoryKey from DB: "$rawKey"');
        debugPrint('   Normalized to: "$key"');
        debugPrint('   Expected: "STRAPLESS_FROCK"');
      }
      
      if (nameLower.contains('short') && !key.contains('SHORT')) {
        debugPrint('⚠️ POSSIBLE MISMATCH: "${p.name}" (\$${p.price}) has categoryKey "$rawKey" -> "$key" (name mentions short)');
      }
      if (nameLower.contains('shoe') && !key.contains('SHOE')) {
        debugPrint('⚠️ POSSIBLE MISMATCH: "${p.name}" (\$${p.price}) has categoryKey "$rawKey" -> "$key" (name mentions shoe)');
      }
      
      _indexByCategoryKey.putIfAbsent(key, () => []).add(p);
    }

    // 🆕 SHOW SPECIFIC CATEGORY DETAILS
    debugPrint('\n🔍 ALL PRODUCTS IN STRAPLESS_FROCK CATEGORY:');
    final straplessProducts = _indexByCategoryKey['STRAPLESS_FROCK'] ?? [];
    if (straplessProducts.isEmpty) {
      debugPrint('   (none)');
    } else {
      for (final p in straplessProducts) {
        debugPrint('   - ${p.name} (\$${p.price}) | raw key: ${p.categoryKey}');
      }
    }
    
    debugPrint('\n🔍 ALL PRODUCTS IN LONG_SLEEVE_FROCK CATEGORY:');
    final longSleeveProducts = _indexByCategoryKey['LONG_SLEEVE_FROCK'] ?? [];
    if (longSleeveProducts.isEmpty) {
      debugPrint('   (none)');
    } else {
      for (final p in longSleeveProducts) {
        debugPrint('   - ${p.name} (\$${p.price}) | raw key: ${p.categoryKey}');
      }
    }
    
    debugPrint('\n🔍 ALL PRODUCTS IN STRAP_DRESS CATEGORY:');
    final strapDressProducts = _indexByCategoryKey['STRAP_DRESS'] ?? [];
    if (strapDressProducts.isEmpty) {
      debugPrint('   (none)');
    } else {
      for (final p in strapDressProducts) {
        debugPrint('   - ${p.name} (\$${p.price}) | raw key: ${p.categoryKey}');
      }
    }

    // ✅ COMPREHENSIVE INDEX SUMMARY
    debugPrint('\n🔍 ===== PRODUCT INDEX BUILT =====');
    debugPrint('🔥 Total products indexed: ${allProducts.length}');
    debugPrint('🔥 Unique category keys: ${_indexByCategoryKey.keys.length}');
    debugPrint('🔥 INDEX KEYS = ${_indexByCategoryKey.keys.toList()}');
    debugPrint('🔥 INDEX COUNTS:');
    _indexByCategoryKey.forEach((key, products) {
      debugPrint('   $key: ${products.length} products');
      for (final p in products) {
        debugPrint('     - ${p.name} (\$${p.price}) | raw key: ${p.categoryKey}');
      }
    });
    debugPrint('🔍 ===== END INDEX SUMMARY =====');
    
    _indexBuilt = true;
  }

  /// Normalize confidence to 0..1
  /// (some models return 0..100)
  double _normalizeConfidence(dynamic c) {
    final v = (c as num).toDouble();
    return v > 1.0 ? v / 100.0 : v;
  }

  Future<List<Product>> searchSimilarProducts(File imageFile) async {
    debugPrint('🔥 searchSimilarProducts CALLED');
    
    try {
      // 1) Classify
      if (!_tfliteService.isModelLoaded) {
        await _tfliteService.loadModel();
      }
      
      final predictions = await _tfliteService.classifyImage(imageFile);
      lastPredictions = predictions;
      
      debugPrint('🔥 PREDICTIONS RAW = $predictions');

      if (predictions.isEmpty) {
        debugPrint('🔥 PREDICTIONS EMPTY => returning []');
        _clearLastPrediction();
        return [];
      }

      final top = predictions.first;
      final predictedKeyRaw = (top['label'] as String?) ?? '';
      final confidence = _normalizeConfidence(top['confidence']);
      
      // ✅ STEP 1: Normalize predicted category key using Product helper
      final predictedKey = Product.normalizeCategoryKey(predictedKeyRaw);
      debugPrint('🧠 Predicted raw="$predictedKeyRaw" normalized="$predictedKey"');

      // Store predicted category info
      lastPredictedLabel = predictedKeyRaw;
      lastPredictedCategoryKey = predictedKey;
      lastPredictedConfidence = confidence;

      debugPrint('🔥 Confidence = $confidence');
      debugPrint('🔥 Threshold = $_confidenceThreshold');

      if (predictedKey.isEmpty) {
        debugPrint('⚠️ Predicted key is empty after normalization => returning []');
        return [];
      }

      // ✅ STEP 2: Build index if needed
      _buildIndexIfNeeded();
      
      // ✅ STEP 3: Filter products ONLY by categoryKey (strict equality)
      final allProducts = _productController.products;
      final sameCategoryProducts = allProducts
          .where((p) => p.categoryKey == predictedKey)
          .toList();
      
      debugPrint('✅ Same-category-only products for $predictedKey: ${sameCategoryProducts.length}');
      
      // ✅ STEP 4: Show what's available in predicted category with raw vs normalized keys
      if (sameCategoryProducts.isNotEmpty && sameCategoryProducts.length <= 20) {
        debugPrint('\n🔍 Products in $predictedKey category:');
        for (final p in sameCategoryProducts) {
          final normalizedKey = Product.normalizeCategoryKey(p.categoryKey);
          debugPrint('   - ${p.name} (\$${p.price}) | raw: "${p.categoryKey}" -> normalized: "$normalizedKey"');
        }
      }

      // ✅ STEP 5: Return same-category-only results (NO FALLBACK MIXING)
      if (sameCategoryProducts.isEmpty) {
        debugPrint('⚠️ No products in predicted category: $predictedKey');
        isMixedCategoryResults = false;
        return [];
      }

      // Take up to 10 products from same category
      List<Product> results = sameCategoryProducts.toList();
      results.shuffle();
      results = results.take(10).toList();
      isMixedCategoryResults = false;
      
      debugPrint('✅ Same-category-only results: ${results.length}');
      
      // ✅ STEP 6: Final guard - enforce same category only (bulletproof)
      final lockedResults = results
          .where((p) => p.categoryKey == predictedKey)
          .toList();
      
      // ✅ STEP 7: Log category distribution of final results
      final dist = <String, int>{};
      for (final p in lockedResults) {
        dist[p.categoryKey] = (dist[p.categoryKey] ?? 0) + 1;
      }
      debugPrint('📊 Final results category distribution: $dist');
      
      // Show returned products with raw vs normalized keys
      debugPrint('\n🔍 ========== RETURNED PRODUCTS ($predictedKey) ==========');
      for (int i = 0; i < lockedResults.length; i++) {
        final p = lockedResults[i];
        final normalizedKey = Product.normalizeCategoryKey(p.categoryKey);
        debugPrint('   ${i + 1}. "${p.name}" - \$${p.price} | raw: "${p.categoryKey}" -> normalized: "$normalizedKey"');
      }
      debugPrint('🔍 ========================================\n');

      return lockedResults;
      
    } catch (e) {
      debugPrint('🔥 ERROR: $e');
      _clearLastPrediction();
      throw Exception('Error searching similar products: ${e.toString()}');
    }
  }

  /// Clear stored prediction info
  void _clearLastPrediction() {
    lastPredictedCategoryKey = null;
    lastPredictedLabel = null;
    lastPredictedConfidence = null;
    isMixedCategoryResults = false;
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return {
        'categories': ['dress', 'formal', 'evening'],
        'colors': ['black', 'red', 'blue'],
        'patterns': ['solid', 'floral'],
        'style': 'elegant',
        'confidence': 0.85,
      };
    } catch (e) {
      throw Exception('Error analyzing image: ${e.toString()}');
    }
  }

  /// Optional: call this if products list changes at runtime
  /// (ex: after refresh / pagination)
  void rebuildIndex() {
    _indexBuilt = false;
    _buildIndexIfNeeded();
  }
}
