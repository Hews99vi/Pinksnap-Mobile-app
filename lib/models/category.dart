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
    return Category(
      id: id ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      key: json['key'] as String? ?? '',
      icon: json['icon'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isVisible: json['isVisible'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  // Factory constructor specifically for Firestore documents
  factory Category.fromDoc(String docId, Map<String, dynamic> data) {
    return Category(
      id: docId,
      name: data['name'] as String? ?? '',
      key: data['key'] as String? ?? '',
      icon: data['icon'] as String?,
      imageUrl: data['imageUrl'] as String?,
      isVisible: data['isVisible'] as bool? ?? true,
      sortOrder: data['sortOrder'] as int? ?? 0,
    );
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
