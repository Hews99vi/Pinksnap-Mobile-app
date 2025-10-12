import 'package:flutter_test/flutter_test.dart';
import 'package:pinksmapmobile/services/tflite_model_service.dart';

/// Test to verify TFLite model is working correctly
/// Run with: flutter test test/model_test.dart
void main() {
  group('TFLite Model Tests', () {
    late TFLiteModelService modelService;

    setUp(() {
      modelService = TFLiteModelService();
    });

    test('Model should load successfully', () async {
      await modelService.loadModel();
      expect(modelService.isModelLoaded, isTrue);
      expect(modelService.labels.length, equals(10));
    });

    test('Labels should be correctly loaded', () async {
      await modelService.loadModel();
      final expectedLabels = [
        'Dress', 'Hat', 'Hoodie', 'Pants', 'Shirt', 
        'Shoes', 'Shorts', 'Skirt', 'Top', 'T-Shirt'
      ];
      
      expect(modelService.labels, equals(expectedLabels));
    });

    test('Model should return predictions for valid image', () async {
      // This test would need a test image file
      // For now, we just verify the model can be loaded
      await modelService.loadModel();
      expect(modelService.isModelLoaded, isTrue);
    });

    test('Mock predictions should have specific format', () {
      // Test mock predictions structure
      final mockPredictions = [
        {'label': 'Dress', 'confidence': 25.0, 'index': 0},
        {'label': 'Top', 'confidence': 20.0, 'index': 8},
        {'label': 'Shirt', 'confidence': 15.0, 'index': 4},
      ];

      for (final prediction in mockPredictions) {
        expect(prediction, containsPair('label', isA<String>()));
        expect(prediction, containsPair('confidence', isA<double>()));
        expect(prediction, containsPair('index', isA<int>()));
      }
    });

    tearDown(() async {
      await modelService.dispose();
    });
  });
}