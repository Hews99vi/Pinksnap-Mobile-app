class Category {
  final String id;  // Firestore document ID
  final String name;
  final String key;
  final String? icon;
  final String? imageUrl;
  final bool isVisible;
  final int sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.key,
    this.icon,
    this.imageUrl,
    this.isVisible = true,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json, {String? id}) {
    final docId = id ?? json['id'] as String? ?? '';
    
    // Fallback chain for key: key → categoryKey → name → docId
    final rawKey = (json['key'] ??
        json['categoryKey'] ??
        json['name'] ??
        docId)
        .toString()
        .trim();
    
    // Fallback for isVisible field
    final visible = json['isVisible'] as bool? ??
        json['isShopByCategoryVisible'] as bool? ??
        true;
    
    return Category(
      id: docId,
      name: json['name'] as String? ?? '',
      key: _normalizeKey(rawKey),
      icon: json['icon'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isVisible: visible,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
  
  // Normalize key to UPPER_SNAKE_CASE format
  static String _normalizeKey(String k) {
    if (k.isEmpty) return '';
    return k
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  // Factory constructor specifically for Firestore documents
  factory Category.fromDoc(String docId, Map<String, dynamic> data) {
    return Category.fromJson(data, id: docId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
      if (icon != null) 'icon': icon,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isVisible': isVisible,
      'sortOrder': sortOrder,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? key,
    String? icon,
    String? imageUrl,
    bool? isVisible,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, key: $key, isVisible: $isVisible, sortOrder: $sortOrder)';
  }
}
