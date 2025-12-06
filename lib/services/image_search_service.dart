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
  Map<String, List<Product>> _indexByCategoryKey = {};
  bool _indexBuilt = false;

  // Tune this after real-world testing
  // Lowered from 0.78 to 0.55 for better real-world photo matching
  static const double _confidenceThreshold = 0.55;

  /// Build categoryKey index only once (fast lookup later)
  void _buildIndexIfNeeded() {
    if (_indexBuilt) return;

    debugPrint('🔥 ImageSearchService ProductController instance = ${_productController.hashCode}');
    debugPrint('🔥 ProductController.products length = ${_productController.products.length}');

    _indexByCategoryKey = {};
    final allProducts = _productController.products;

    debugPrint('🔥 INDEX BUILD allProducts.length = ${allProducts.length}');

    for (final product in allProducts) {
      final key = product.categoryKey.trim().toUpperCase();
      if (key.isEmpty) continue;

      (_indexByCategoryKey[key] ??= []).add(product);
    }

    _indexBuilt = true;

    debugPrint('🔥 INDEX BUILD keys = ${_indexByCategoryKey.keys.toList()}');
    // TEMP DEBUG LOGS
    Logger.info("INDEX BUILD products count = ${allProducts.length}");
    Logger.info("INDEX BUILD keys = ${_indexByCategoryKey.keys.toList()}");

    Logger.info(
      'Category index built with ${_indexByCategoryKey.length} keys '
      'from ${allProducts.length} products',
    );
  }

  /// Normalize confidence to 0..1
  /// (some models return 0..100)
  double _normalizeConfidence(dynamic c) {
    final v = (c as num).toDouble();
    return v > 1.0 ? v / 100.0 : v;
  }

  Future<List<Product>> searchSimilarProducts(File imageFile) async {
    debugPrint('🔥🔥🔥 searchSimilarProducts CALLED');
    debugPrint('🔥 ImageFile: ${imageFile.path}');
    try {
      Logger.info('Starting STRICT image search for similar products');

      // Ensure model is loaded
      if (!_tfliteService.isModelLoaded) {
        Logger.info('Model not loaded, loading now...');
        await _tfliteService.loadModel();
      }

      // Classify the image using TFLite model
      final predictions = await _tfliteService.classifyImage(imageFile);
      lastPredictions = predictions;

      debugPrint('🔥 PREDICTIONS RAW = $predictions');

      if (predictions.isEmpty) {
        debugPrint('🔥 PREDICTIONS EMPTY => returning []');
        Logger.warning('No predictions returned from model');
        return [];
      }

      // Build product index once
      _buildIndexIfNeeded();

      // Top prediction
      final topPrediction = predictions.first;
      final predictedLabel =
          (topPrediction['label'] as String).trim().toUpperCase();
      final confidence = _normalizeConfidence(topPrediction['confidence']);

      debugPrint('🔥 TOP LABEL = $predictedLabel');
      debugPrint('🔥 TOP CONF  = $confidence');
      debugPrint('🔥 THRESHOLD = $_confidenceThreshold');

      // TEMP DEBUG LOGS
      double norm(num v) => v > 1 ? v / 100.0 : v.toDouble();
      Logger.info("CONF NORM = ${norm(topPrediction['confidence'] as num)}");
      Logger.info("LOOKUP label = '$predictedLabel'");
      Logger.info("LOOKUP available keys = ${_indexByCategoryKey.keys.toList()}");

      Logger.info(
        'Top prediction: $predictedLabel '
        '(${(confidence * 100).toStringAsFixed(1)}%)',
      );

      // Confidence gate to avoid wrong suggestions
      if (confidence < _confidenceThreshold) {
        debugPrint('🔥 CONFIDENCE GATE: $confidence < $_confidenceThreshold => returning []');
        Logger.info(
          'Confidence ${(confidence * 100).toStringAsFixed(1)}% '
          'below threshold ${(_confidenceThreshold * 100).toStringAsFixed(0)}%, '
          'returning no suggestions.',
        );
        return [];
      }
      debugPrint('🔥 CONFIDENCE OK: $confidence >= $_confidenceThreshold');

      // Strict lookup by categoryKey = predictedLabel
      final matches = _indexByCategoryKey[predictedLabel] ?? [];
      debugPrint('🔥 MATCHES for $predictedLabel = ${matches.length}');

      if (matches.isEmpty) {
        Logger.warning(
          'No products found for categoryKey: $predictedLabel '
          '(category may not exist in shop yet)',
        );
        return [];
      }

      // Shuffle for variety and limit to 10
      matches.shuffle();
      final results = matches.take(10).toList();

      Logger.info(
        'Returning ${results.length} products for categoryKey: $predictedLabel',
      );
      return results;
    } catch (e) {
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
