import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart'; // Disabled for web compatibility
import '../utils/logger.dart';

class TFLiteModelService {
  static final TFLiteModelService _instance = TFLiteModelService._internal();
  factory TFLiteModelService() => _instance;
  TFLiteModelService._internal();

  bool _modelLoaded = false;
  List<String> _labels = [];
  // Interpreter? _interpreter; // Disabled for web compatibility
  dynamic _interpreter; // Using dynamic for web compatibility

  bool get isModelLoaded => _modelLoaded;
  List<String> get labels => _labels;

  /// Initialize and load the TFLite model
  Future<void> loadModel() async {
    try {
      if (_modelLoaded) {
        Logger.info('Model already loaded');
        return;
      }

      // Skip TFLite on web - not supported
      if (kIsWeb) {
        Logger.warning('TFLite is not supported on web platform');
        _modelLoaded = false;
        return;
      }

      Logger.info('Loading TFLite model...');

      // TFLite is not available - this code will not run on web
      // If somehow reached, log warning
      Logger.warning('TFLite model loading attempted but not available');
      _modelLoaded = false;
      return;
      
      // Original code commented out for web compatibility:
      // _interpreter = await Interpreter.fromAsset('assets/models/model_unquant.tflite');
      // _modelLoaded = true;
      // await _loadLabels();
      // Logger.success('Model loaded successfully with ${_labels.length} labels');
      // final inputShape = _interpreter!.getInputTensor(0).shape;
      // final outputShape = _interpreter!.getOutputTensor(0).shape;
      // Logger.info('Model input shape: $inputShape');
      // Logger.info('Model output shape: $outputShape');
      
    } catch (e) {
      Logger.error('Error loading model: $e');
      _modelLoaded = false;
      // Don't throw on web, just log the error
      if (!kIsWeb) {
        throw Exception('Failed to load TFLite model: $e');
      }
    }
  }

  /// Load labels from the labels.txt file
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            // Remove the number prefix (e.g., "0 Dress" -> "Dress")
            final parts = line.trim().split(' ');
            return parts.length > 1 ? parts.sublist(1).join(' ') : line.trim();
          })
          .toList();
      
      Logger.info('Loaded ${_labels.length} labels: $_labels');
    } catch (e) {
      Logger.error('Error loading labels: $e');
      _labels = [];
    }
  }

  /// Run image classification on the provided image file
  Future<List<Map<String, dynamic>>> classifyImage(File imageFile) async {
    try {
      // On web, return mock predictions
      if (kIsWeb || !_modelLoaded || _interpreter == null) {
        Logger.warning('TFLite not available - returning mock predictions');
        return _getMockPredictions();
      }

      Logger.info('Classifying image: ${imageFile.path}');

      // TFLite classification code disabled for web compatibility
      // Original code would go here
      return _getMockPredictions();
      
    } catch (e) {
      Logger.error('Error classifying image: $e');
      // Return mock data instead of throwing on web
      if (kIsWeb) {
        return _getMockPredictions();
      }
      throw Exception('Failed to classify image: $e');
    }
  }

  /// Get mock predictions for web or when model is not available
  List<Map<String, dynamic>> _getMockPredictions() {
    // Return mock fashion item predictions
    return [
      {'label': 'Dress', 'confidence': 85.5, 'index': 0},
      {'label': 'Top', 'confidence': 45.2, 'index': 1},
      {'label': 'Skirt', 'confidence': 12.8, 'index': 2},
    ];
  }

  /// Convert image to Float32 input tensor
  /// (Kept for reference, not used on web)
  List<List<List<List<double>>>> _imageToByteListFloat32(
    img.Image image,
    int inputHeight,
    int inputWidth,
  ) {
    var convertedBytes = List.generate(
      1,
      (i) => List.generate(
        inputHeight,
        (y) => List.generate(
          inputWidth,
          (x) {
            final pixel = image.getPixel(x, y);
            // Normalize to 0-1 range
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
    return convertedBytes;
  }

  /// Get the top prediction from classification results
  Map<String, dynamic>? getTopPrediction(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) return null;
    return predictions.first;
  }

  /// Get predictions above a certain confidence threshold
  List<Map<String, dynamic>> getHighConfidencePredictions(
    List<Map<String, dynamic>> predictions, 
    double threshold
  ) {
    return predictions.where((p) => p['confidence'] >= threshold).toList();
  }

  /// Dispose and close the model
  Future<void> dispose() async {
    try {
      if (_modelLoaded && _interpreter != null) {
        // _interpreter!.close(); // Disabled for web
        _interpreter = null;
        _modelLoaded = false;
        _labels.clear();
        Logger.info('Model closed successfully');
      }
    } catch (e) {
      Logger.error('Error closing model: $e');
    }
  }

  /// Get a human-readable summary of predictions
  String getPredictionSummary(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) {
      return 'No predictions available';
    }

    final top = predictions.first;
    final label = top['label'] as String;
    final confidence = top['confidence'] as double;

    if (confidence >= 70) {
      return 'This looks like a $label (${confidence.toStringAsFixed(1)}% confident)';
    } else if (confidence >= 40) {
      return 'This might be a $label (${confidence.toStringAsFixed(1)}% confident)';
    } else {
      return 'Possibly a $label, but not very confident (${confidence.toStringAsFixed(1)}%)';
    }
  }
}
