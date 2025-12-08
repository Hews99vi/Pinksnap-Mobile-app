import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../utils/color_utils.dart';

class SearchController extends GetxController {
  // Controllers
  late final ProductController _productController;
  late final CategoryController _categoryController;
  
  // All products (base list)
  final RxList<Product> _allProducts = <Product>[].obs;
  
  // Reactive variables
  final RxList<Product> _filteredProducts = <Product>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxString _selectedSize = 'All'.obs;
  final RxString _selectedColor = 'All'.obs;
  final Rx<RangeValues> _priceRange = const RangeValues(0, 1000).obs;
  final RxBool _showFilters = false.obs;
  
  // Stable price bounds from ALL products (not filtered)
  double _stableMinPrice = 0;
  double _stableMaxPrice = 1000;
  
  // Debounce timer to prevent filter spam
  Timer? _filterTimer;

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  String get selectedSize => _selectedSize.value;
  String get selectedColor => _selectedColor.value;
  RangeValues get priceRange => _priceRange.value;
  bool get showFilters => _showFilters.value;

  // Available filter options - from CategoryController with fallback to products
  List<Map<String, String>> get availableCategories {
    try {
      final allCats = _categoryController.categories;
      debugPrint('🔍 Building availableCategories from ${allCats.length} Firestore categories');
      
      // Get all visible categories (don't exclude empty keys yet)
      final visibleCats = allCats
          .where((c) => c.isVisible)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      debugPrint('✅ Found ${visibleCats.length} visible categories');
      
      // Map categories - derive key from name if Firestore key is empty
      final mappedCats = visibleCats.map((c) {
        final rawKey = c.key.trim();
        final safeKey = rawKey.isNotEmpty
            ? Product.normalizeCategoryKey(rawKey)
            : Product.normalizeCategoryKey(c.name);
        
        if (rawKey.isEmpty) {
          debugPrint('⚠️ Category "${c.name}" has empty key, derived: $safeKey');
        }
        
        return {'key': safeKey, 'name': c.name};
      }).toList();
      
      // If no categories from Firestore, fallback to product keys
      if (mappedCats.isEmpty && _allProducts.isNotEmpty) {
        debugPrint('⚠️ No valid Firestore categories, falling back to product keys');
        final productKeys = _allProducts
            .map((p) => p.categoryKey)
            .where((k) => k.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        
        return [
          {'key': 'All', 'name': 'All'},
          ...productKeys.map((k) => {'key': k, 'name': k})
        ];
      }
      
      return [
        {'key': 'All', 'name': 'All'},
        ...mappedCats
      ];
    } catch (e) {
      debugPrint('❌ Error getting categories: $e');
      return [{'key': 'All', 'name': 'All'}];
    }
  }
  
  List<String> get availableSizes => ['All', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];
  
  List<String> get availableColors {
    if (_allProducts.isEmpty) return ['All', ...ColorUtils.availableColors];
    
    final productColors = <String>{};
    for (var product in _allProducts) {
      productColors.addAll(product.colors);
    }
    
    return productColors.isEmpty 
        ? ['All', ...ColorUtils.availableColors]
        : ['All', ...productColors.toList()..sort()];
  }

  @override
  void onInit() {
    super.onInit();
    
    // Get controller references
    _productController = Get.find<ProductController>();
    _categoryController = Get.find<CategoryController>();
    
    // Initialize async
    _initializeController();
  }

  // Initialize controller data asynchronously
  Future<void> _initializeController() async {
    // Ensure categories are loaded
    if (_categoryController.categories.isEmpty) {
      debugPrint('📋 Categories not loaded, loading now...');
      await _categoryController.loadCategories();
    } else {
      debugPrint('📋 Categories already loaded: ${_categoryController.categories.length}');
    }
    
    // Initialize products list (fast initial state)
    _allProducts.assignAll(_productController.products);
    _filteredProducts.assignAll(_allProducts);
    
    // Set stable price bounds when products change (once)
    if (_allProducts.isNotEmpty) {
      _stableMinPrice = _allProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b).floorToDouble();
      _stableMaxPrice = _allProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b).ceilToDouble();
      
      // Initialize priceRange with stable bounds
      _priceRange.value = RangeValues(_stableMinPrice, _stableMaxPrice);
      
      debugPrint('💰 Stable price bounds: \$$_stableMinPrice - \$$_stableMaxPrice');
      
      final uniqueKeys = _allProducts.map((p) => p.categoryKey).toSet().toList()..sort();
      debugPrint('🔑 Normalized category keys (${uniqueKeys.length}): $uniqueKeys');
    }
    
    // ✅ KEEP SearchController products in sync with ProductController
    ever<List<Product>>(_productController.productsRx, (list) {
      debugPrint('🔄 Products updated in SearchController: ${list.length}');
      
      _allProducts.assignAll(list);
      _filteredProducts.assignAll(list);

      // Recompute stable price bounds whenever products load
      if (_allProducts.isNotEmpty) {
        _stableMinPrice = _allProducts
            .map((p) => p.price)
            .reduce((a, b) => a < b ? a : b)
            .floorToDouble();

        _stableMaxPrice = _allProducts
            .map((p) => p.price)
            .reduce((a, b) => a > b ? a : b)
            .ceilToDouble();

        _priceRange.value = RangeValues(_stableMinPrice, _stableMaxPrice);

        final uniqueKeys = _allProducts
            .map((p) => p.categoryKey)
            .toSet()
            .toList()
          ..sort();

        debugPrint('📋 Available keys: $uniqueKeys');
      }

      // ✅ Re-apply filters after sync
      _scheduleFilter();
    });
    
    // React to filter changes with debouncing to prevent spam
    everAll([
      _searchQuery,
      _selectedCategory,
      _selectedSize,
      _selectedColor,
      _priceRange,
    ], (_) {
      _scheduleFilter();
    });
  }
  
  // Debounced filter execution to prevent spam
  void _scheduleFilter() {
    _filterTimer?.cancel();
    _filterTimer = Timer(const Duration(milliseconds: 80), _applyFilters);
  }

  // Public method to refresh data
  Future<void> refreshData() async {
    await _categoryController.loadCategories();
    _allProducts.assignAll(_productController.products);
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    // everAll will trigger _applyFilters automatically
  }

  void updateCategory(String categoryKey) {
    // ✅ PREVENT EMPTY KEYS
    final safeKey = (categoryKey.isEmpty || categoryKey.trim().isEmpty) ? 'All' : categoryKey;
    _selectedCategory.value = safeKey;
    debugPrint('🔍 Selected category key: "$safeKey"');
    // everAll will trigger _scheduleFilter automatically
  }

  void updateSize(String size) {
    _selectedSize.value = size;
    // everAll will trigger _applyFilters automatically
  }
  
  void updateColor(String color) {
    _selectedColor.value = color;
    // everAll will trigger _applyFilters automatically
  }

  void updatePriceRange(RangeValues range) {
    final min = _stableMinPrice;
    final max = _stableMaxPrice;

    final clampedStart = range.start.clamp(min, max);
    final clampedEnd = range.end.clamp(min, max);

    _priceRange.value = RangeValues(
      clampedStart <= clampedEnd ? clampedStart : clampedEnd,
      clampedEnd >= clampedStart ? clampedEnd : clampedStart,
    );
    // everAll will trigger _applyFilters automatically
  }

  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  void clearAllFilters() {
    _searchQuery.value = '';
    _selectedCategory.value = 'All';
    _selectedSize.value = 'All';
    _selectedColor.value = 'All';
    _priceRange.value = RangeValues(_stableMinPrice, _stableMaxPrice);
    // everAll will trigger _applyFilters automatically
  }

  void _applyFilters() {
    final searchText = _searchQuery.value.toLowerCase();
    final cat = _selectedCategory.value;
    final size = _selectedSize.value;
    final color = _selectedColor.value;
    final range = _priceRange.value;

    final filtered = _allProducts.where((product) {
      // Text search
      final matchesSearch = searchText.isEmpty ||
          product.name.toLowerCase().contains(searchText) ||
          product.description.toLowerCase().contains(searchText) ||
          product.category.toLowerCase().contains(searchText);

      // Category filter - normalize both sides for reliable matching
      final normalizedSelected = (cat == 'All') 
          ? 'All' 
          : Product.normalizeCategoryKey(cat);
      
      final matchesCategory = (normalizedSelected == 'All') ||
          (product.categoryKey.trim().toUpperCase() == normalizedSelected);

      // Size filter
      final matchesSize = (size == 'All') || product.sizes.contains(size);
          
      // Color filter
      final matchesColor = (color == 'All') || product.colors.contains(color);

      // Price filter
      final matchesPrice = product.price >= range.start && product.price <= range.end;

      return matchesSearch && matchesCategory && matchesSize && matchesColor && matchesPrice;
    }).toList();

    _filteredProducts.assignAll(filtered);
    
    // Debug logging only for category filter issues
    if (cat != 'All' && filtered.isEmpty) {
      debugPrint('⚠️ No products for category "$cat"');
      final uniqueKeys = _allProducts.map((p) => p.categoryKey).toSet().toList()..sort();
      debugPrint('📋 Available keys: $uniqueKeys');
    }
  }

  // ✅ STABLE bounds from ALL products, not filtered
  double get minPrice => _stableMinPrice;
  double get maxPrice => _stableMaxPrice;
  
  @override
  void onClose() {
    _filterTimer?.cancel();
    super.onClose();
  }
}
