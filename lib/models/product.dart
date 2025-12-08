
class Product {
  /// Normalize category key to ML format: "strapless frocks" -> "STRAPLESS_FROCK"
  static String _normalizeCategoryKey(String raw) {
    if (raw.isEmpty) return '';
    
    // Uppercase and replace spaces/hyphens with underscore
    String normalized = raw.trim().toUpperCase().replaceAll(RegExp(r'[\s\-]+'), '_');
    
    // Collapse multiple underscores
    normalized = normalized.replaceAll(RegExp(r'_+'), '_');
    
    // ✅ Alias map - maps variants to ACTUAL MODEL KEYS from labels.txt
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
    
    return aliasMap[normalized] ?? normalized;
  }
  
  /// Public helper so controllers can normalize category keys consistently.
  static String normalizeCategoryKey(String raw) => _normalizeCategoryKey(raw);
  
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;

  /// Old human-readable category (keep for UI / backward compat)
  final String category;

  /// New strict key that must match model labels
  final String categoryKey;

  final List<String> sizes;
  final List<String> colors;
  final Map<String, int> stock;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.categoryKey, // ✅ NEW
    required this.sizes,
    this.colors = const [],
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawCategoryKey = (json['categoryKey'] ?? json['category'] ?? '')
        .toString()
        .trim();
    
    // ✅ NORMALIZE on read - single source of truth
    final normalizedKey = _normalizeCategoryKey(rawCategoryKey);

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] as List),

      // Backward compatible:
      category: (json['category'] ?? '').toString(),
      categoryKey: normalizedKey, // ✅ NORMALIZED

      sizes: List<String>.from(json['sizes'] as List),
      colors: json['colors'] != null
          ? List<String>.from(json['colors'] as List)
          : [],
      stock: Map<String, int>.from(json['stock'] as Map),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,

      // keep both for now
      'category': category,
      'categoryKey': categoryKey, // ✅ NEW

      'sizes': sizes,
      'colors': colors,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
