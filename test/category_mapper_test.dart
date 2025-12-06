import 'package:flutter_test/flutter_test.dart';
import 'package:pinksmapmobile/utils/category_mapper.dart';

void main() {
  group('CategoryMapper Tests', () {
    test('UI Categories map to correct Model Keys', () {
      // Test core UI categories
      expect(CategoryMapper.uiToModelKey('Dresses'), 'STRAP_DRESS');
      expect(CategoryMapper.uiToModelKey('Tops'), 'TOP');
      expect(CategoryMapper.uiToModelKey('Bottoms'), 'PANTS');
      expect(CategoryMapper.uiToModelKey('Outerwear'), 'HOODIE');
      expect(CategoryMapper.uiToModelKey('Shoes'), 'SHOES');
      expect(CategoryMapper.uiToModelKey('Accessories'), 'HAT');
      expect(CategoryMapper.uiToModelKey('Activewear'), 'TOP');
      expect(CategoryMapper.uiToModelKey('Lingerie'), 'TOP');
    });

    test('Model key normalization works', () {
      expect(CategoryMapper.normalizeModelKey('strap dress'), 'STRAP_DRESS');
      expect(CategoryMapper.normalizeModelKey('T Shirt'), 'T_SHIRT');
      expect(CategoryMapper.normalizeModelKey('  top  '), 'TOP');
      expect(CategoryMapper.normalizeModelKey('long sleeve frock'), 'LONG_SLEEVE_FROCK');
    });

    test('Model key validation works', () {
      expect(CategoryMapper.isValidModelKey('HAT'), true);
      expect(CategoryMapper.isValidModelKey('TOP'), true);
      expect(CategoryMapper.isValidModelKey('STRAP_DRESS'), true);
      expect(CategoryMapper.isValidModelKey('T_SHIRT'), true);
      expect(CategoryMapper.isValidModelKey('INVALID_KEY'), false);
      expect(CategoryMapper.isValidModelKey('TOPS'), false); // TOPS is invalid, should be TOP
      expect(CategoryMapper.isValidModelKey('DRESSES'), false); // DRESSES is invalid
    });

    test('All default mappings produce valid model keys', () {
      for (var entry in CategoryMapper.defaultUiToModel.entries) {
        final uiCategory = entry.key;
        final modelKey = entry.value;
        expect(
          CategoryMapper.isValidModelKey(modelKey),
          true,
          reason: 'UI Category "$uiCategory" maps to invalid key "$modelKey"',
        );
      }
    });

    test('Unmapped categories return empty string', () {
      expect(CategoryMapper.uiToModelKey('Unknown Category'), '');
      expect(CategoryMapper.uiToModelKey('Random Item'), '');
    });

    test('Model keys set contains all valid labels', () {
      expect(CategoryMapper.modelKeys, hasLength(11));
      expect(CategoryMapper.modelKeys, containsAll([
        'HAT', 'HOODIE', 'PANTS', 'SHIRT', 'SHOES', 'SHORTS',
        'TOP', 'T_SHIRT', 'LONG_SLEEVE_FROCK', 'STRAP_DRESS', 'STRAPLESS_FROCK'
      ]));
    });

    test('Normalized keys that match model labels are valid', () {
      // If someone passes a model key that's valid but not in defaultUiToModel,
      // it falls back to normalized check
      final result = CategoryMapper.uiToModelKey('HAT');
      // HAT normalizes to 'HAT' which IS in modelKeys, so returns 'HAT'
      expect(result, 'HAT');
      
      // Normalization + validation should work
      final normalized = CategoryMapper.normalizeModelKey('HAT');
      expect(CategoryMapper.isValidModelKey(normalized), true);
    });

    test('Whitespace handling', () {
      expect(CategoryMapper.uiToModelKey('  Tops  '), 'TOP');
      expect(CategoryMapper.uiToModelKey('Dresses'), 'STRAP_DRESS');
    });
  });
}
