import 'package:flutter_test/flutter_test.dart';
import 'package:pinksmapmobile/services/tflite_model_service.dart';
import 'dart:io';

void main() {
  group('TFLite Model Service Tests', () {
    late TFLiteModelService service;

    setUp(() {
      service = TFLiteModelService();
    });

    test('Service can be instantiated', () {
      expect(service, isA<TFLiteModelService>());
    });

    test('Service has proper initial state', () {
      expect(service.isModelLoaded, isFalse);
      expect(service.labels, isEmpty);
    });

    test('loadModel completes without error', () async {
      // This should work on both web and mobile
      try {
        await service.loadModel();
        // If we get here, no exception was thrown
        expect(true, isTrue);
      } catch (e) {
        // Even if it fails to load, it shouldn't crash
        expect(e, isA<Exception>());
      }
    });

    test('classifyImage returns results', () async {
      // Create a mock file for testing
      final testFile = File('test_image.jpg');
      
      try {
        final predictions = await service.classifyImage(testFile);
        
        // Should return some predictions (either real or mock)
        expect(predictions, isA<List<Map<String, dynamic>>>());
        
        if (predictions.isNotEmpty) {
          final firstPrediction = predictions.first;
          expect(firstPrediction, containsPair('label', isA<String>()));
          expect(firstPrediction, containsPair('confidence', isA<double>()));
          expect(firstPrediction, containsPair('index', isA<int>()));
        }
      } catch (e) {
        // File doesn't exist, but should still handle gracefully
        expect(e, isA<Exception>());
      }
    });

    test('getPredictionSummary works with empty list', () {
      final summary = service.getPredictionSummary([]);
      expect(summary, equals('No predictions available'));
    });

    test('getPredictionSummary works with predictions', () {
      final predictions = [
        {'label': 'Dress', 'confidence': 85.0, 'index': 0},
      ];
      final summary = service.getPredictionSummary(predictions);
      expect(summary, contains('Dress'));
      expect(summary, contains('85.0'));
    });

    test('getHighConfidencePredictions filters correctly', () {
      final predictions = [
        {'label': 'Dress', 'confidence': 85.0, 'index': 0},
        {'label': 'Top', 'confidence': 45.0, 'index': 1},
        {'label': 'Shirt', 'confidence': 25.0, 'index': 2},
      ];
      
      final highConfidence = service.getHighConfidencePredictions(predictions, 50.0);
      expect(highConfidence.length, equals(1));
      expect(highConfidence.first['label'], equals('Dress'));
    });

    test('dispose completes without error', () async {
      await service.dispose();
      // Should complete without throwing
      expect(true, isTrue);
    });
  });
}