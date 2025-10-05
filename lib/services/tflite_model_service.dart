import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/logger.dart';

class TFLiteModelService {
  static final TFLiteModelService _instance = TFLiteModelService._internal();
  factory TFLiteModelService() => _instance;
  TFLiteModelService._internal();

  bool _modelLoaded = false;
  List<String> _labels = [];
  Interpreter? _interpreter;

  bool get isModelLoaded => _modelLoaded;
  List<String> get labels => _labels;

  /// Initialize and load the TFLite model
  Future<void> loadModel() async {
    try {
      if (_modelLoaded) {
        Logger.info('Model already loaded');
        return;
      }

      Logger.info('Loading TFLite model...');

      // Load the model
      _interpreter = await Interpreter.fromAsset('assets/models/model_unquant.tflite');
      
      _modelLoaded = true;
      await _loadLabels();
      
      Logger.success('Model loaded successfully with ${_labels.length} labels');
      
      // Log model input/output details
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      Logger.info('Model input shape: $inputShape');
      Logger.info('Model output shape: $outputShape');
      
    } catch (e) {
      Logger.error('Error loading model: $e');
      throw Exception('Failed to load TFLite model: $e');
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
      if (!_modelLoaded || _interpreter == null) {
        throw Exception('Model not loaded. Call loadModel() first.');
      }

      Logger.info('Classifying image: ${imageFile.path}');

      // Read and decode the image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Get input shape from model
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputHeight = inputShape[1];
      final inputWidth = inputShape[2];
      
      Logger.info('Resizing image to ${inputWidth}x$inputHeight');

      // Resize image to model input size
      img.Image resizedImage = img.copyResize(
        image,
        width: inputWidth,
        height: inputHeight,
      );

      // Convert image to input tensor (normalize to 0-1 range)
      var input = _imageToByteListFloat32(resizedImage, inputHeight, inputWidth);

      // Prepare output tensor
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Process output
      List<Map<String, dynamic>> results = [];
      final probabilities = output[0] as List<double>;
      
      for (int i = 0; i < probabilities.length; i++) {
        final confidence = probabilities[i] * 100;
        if (confidence >= 1.0) { // Only include predictions above 1%
          results.add({
            'label': _labels[i],
            'confidence': confidence,
            'index': i,
          });
        }
      }

      // Sort by confidence (highest first)
      results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

      // Take top 5 predictions
      results = results.take(5).toList();

      Logger.info('Got ${results.length} predictions');
      for (var result in results) {
        Logger.info('Prediction: ${result['label']} - ${(result['confidence'] as double).toStringAsFixed(2)}%');
      }

      return results;
    } catch (e) {
      Logger.error('Error classifying image: $e');
      throw Exception('Failed to classify image: $e');
    }
  }

  /// Convert image to Float32 input tensor
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
        _interpreter!.close();
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
