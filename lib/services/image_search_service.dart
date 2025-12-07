import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import 'tflite_model_service.dart';
import '../utils/logger.dart';
import 'package:get/get.dart';

class ImageSearchService {
  final String baseUrl = 'https://your-ml-api-endpoint.com'; // unused for now
  final ProductController _productController = Get.find<ProductController>();
  final TFLiteModelService _tfliteService = TFLiteModelService();

  // Store the last predictions for display/debug
  List<Map<String, dynamic>>? lastPredictions;

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
    
    // ✅ Enhanced alias map for all potential plural/variant forms
    const aliasMap = {
      'STRAPLESS_FROCKS': 'STRAPLESS_FROCK',
      'STRAP_DRESSES': 'STRAP_DRESS',
      'HOODIES': 'HOODIE',
      'T_SHIRTS': 'T_SHIRT',
      'LONG_SLEEVE_FROCKS': 'LONG_SLEEVE_FROCK',
      'HATS': 'HAT',
      'SHIRTS': 'SHIRT',
      'SHORT': 'SHORTS',  // singular -> plural
      'SHOE': 'SHOES',    // singular -> plural
      'PANT': 'PANTS',    // singular -> plural
      'TOPS': 'TOP',      // plural -> singular
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
      
      _indexByCategoryKey.putIfAbsent(key, () => []).add(p);
    }

    debugPrint('🔥 INDEX KEYS = ${_indexByCategoryKey.keys.toList()}');
    debugPrint('🔥 INDEX COUNTS:');
    _indexByCategoryKey.forEach((key, products) {
      debugPrint('   $key: ${products.length} products');
    });
    
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
        return [];
      }

      final top = predictions.first;
      final rawLabel = (top['label'] as String?) ?? '';
      final predictedLabel = _normalizeLabelToKey(rawLabel);
      final confidence = _normalizeConfidence(top['confidence']);

      debugPrint('🔥 TOP RAW LABEL = $rawLabel');
      debugPrint('🔥 TOP LABEL KEY = $predictedLabel');
      debugPrint('🔥 TOP CONF = $confidence');
      debugPrint('🔥 THRESHOLD = $_confidenceThreshold');

      if (predictedLabel.isEmpty) {
        debugPrint('🔥 predictedLabel EMPTY after normalize => returning []');
        return [];
      }

      // 2) Ensure index is built
      _buildIndexIfNeeded();

      // 3) Compute matches BEFORE confidence gate
      final matches = _indexByCategoryKey[predictedLabel] ?? [];
      debugPrint('🔥 MATCHES for $predictedLabel = ${matches.length}');

      // 4) Confidence gate with fallback
      if (confidence < _confidenceThreshold) {
        debugPrint('🔥 Low confidence but we will fallback if matches exist');
        if (matches.isNotEmpty) {
          debugPrint('🔥 Returning matches despite low confidence');
          matches.shuffle();
          return matches.take(10).toList();
        }
        debugPrint('🔥 Low confidence + no matches => returning []');
        return [];
      }

      // 5) Normal return
      debugPrint('🔥 High confidence - returning matches');
      if (matches.isEmpty) {
        debugPrint('🔥 No products in catalog for $predictedLabel');
        return [];
      }
      
      matches.shuffle();
      return matches.take(10).toList();
      
    } catch (e) {
      debugPrint('🔥 ERROR: $e');
      throw Exception('Error searching similar products: ${e.toString()}');
    }
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
