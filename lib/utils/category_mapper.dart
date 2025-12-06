class CategoryMapper {
  /// ✅ Your Teachable Machine labels (must match labels.txt)
  static const Set<String> modelKeys = {
    'HAT',
    'HOODIE',
    'PANTS',
    'SHIRT',
    'SHOES',
    'SHORTS',
    'TOP',
    'T_SHIRT',
    'LONG_SLEEVE_FROCK',
    'STRAP_DRESS',
    'STRAPLESS_FROCK',
  };

  /// UI category → DEFAULT model key
  /// (used if admin doesn't pick a more specific model key)
  static const Map<String, String> defaultUiToModel = {
    'Dresses': 'STRAP_DRESS',
    'Tops': 'TOP',
    'Bottoms': 'PANTS',
    'Outerwear': 'HOODIE',
    'Hoodies': 'HOODIE',   // ✅ Explicit mapping to prevent HOODIES fallback
    'Accessories': 'HAT',  // no accessories class in model
    'Shoes': 'SHOES',
    'Activewear': 'TOP',
    'Lingerie': 'TOP',
  };

  /// Normalize any key to MODEL FORMAT
  static String normalizeModelKey(String key) {
    return key.trim().toUpperCase().replaceAll(' ', '_');
  }

  /// Convert UI category to a modelKey (fallback default)
  static String uiToModelKey(String uiCategory) {
    final clean = uiCategory.trim();
    final mapped = defaultUiToModel[clean];
    if (mapped == null) {
      // fallback: try normalized version (but may not be valid)
      final fallbackKey = normalizeModelKey(clean);
      return modelKeys.contains(fallbackKey) ? fallbackKey : '';
    }
    return mapped;
  }

  /// Validate a model key before saving
  static bool isValidModelKey(String key) {
    return modelKeys.contains(normalizeModelKey(key));
  }
}
