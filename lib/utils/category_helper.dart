/// Category key normalization helper
/// Used to maintain backward compatibility with old product data
class CategoryHelper {
  /// Normalize category label to standard key format
  /// Example: "strapless frocks" -> "STRAPLESS_FROCK"
  static String normalizeToKey(String label) {
    final raw = label.trim().toUpperCase();
    
    // Normalize spaces/hyphens to underscores
    final norm = raw.replaceAll(RegExp(r'[\s\-]+'), '_');
    
    // Enhanced alias map for all potential plural/variant forms
    const aliasMap = {
      'STRAPLESS_FROCKS': 'STRAPLESS_FROCK',
      'STRAP_DRESSES': 'STRAP_DRESS',
      'HOODIES': 'HOODIE',
      'T_SHIRTS': 'T_SHIRT',
      'LONG_SLEEVE_FROCKS': 'LONG_SLEEVE_FROCK',
      'HATS': 'HAT',
      'SHIRTS': 'SHIRT',
      'SHORT': 'SHORTS',
      'SHOE': 'SHOES',
      'PANT': 'PANTS',
      'TOPS': 'TOP',
      'BAGS': 'BAG',
      'DRESSES': 'DRESS',
      'COATS': 'COAT',
      'JACKETS': 'JACKET',
      'SKIRTS': 'SKIRT',
      'JEANS': 'JEAN',
      'TROUSERS': 'TROUSER',
      'SWEATERS': 'SWEATER',
      'PULLOVER': 'PULLOVERS',
      'SANDALS': 'SANDAL',
      'SNEAKERS': 'SNEAKER',
      'ANKLEBOOT': 'ANKLE_BOOT',
      'ANKLE_BOOTS': 'ANKLE_BOOT',
    };
    
    return aliasMap[norm] ?? norm;
  }

  /// Check if two category keys match (after normalization)
  static bool keysMatch(String key1, String key2) {
    final normalized1 = normalizeToKey(key1);
    final normalized2 = normalizeToKey(key2);
    return normalized1 == normalized2;
  }
}
