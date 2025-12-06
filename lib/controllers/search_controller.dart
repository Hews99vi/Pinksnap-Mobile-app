import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../utils/color_utils.dart';

class SearchController extends GetxController {
  ProductController? _productController;
  ProductController get productController {
    _productController ??= Get.find<ProductController>();
    return _productController!;
  }
  
  // Reactive variables
  final RxList<Product> _filteredProducts = <Product>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxString _selectedSize = 'All'.obs;
  final RxString _selectedColor = 'All'.obs;
  final Rx<RangeValues> _priceRange = const RangeValues(0, 1000).obs;
  final RxBool _showFilters = false.obs;

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  String get selectedSize => _selectedSize.value;
  String get selectedColor => _selectedColor.value;
  RangeValues get priceRange => _priceRange.value;
  bool get showFilters => _showFilters.value;

  // Available filter options - simplified to avoid dependency issues
  List<String> get availableCategories {
    try {
      // Try to get from CategoryController first
      if (Get.isRegistered<CategoryController>()) {
        final catController = Get.find<CategoryController>();
        return ['All', ...catController.categories];
      }
    } catch (e) {
      // Fallback silently
    }
    
    // Fallback to product controller categories or default categories
    try {
      return ['All', ...productController.categories];
    } catch (e) {
      // Final fallback to hardcoded categories
      return ['All', 'Dresses', 'Tops', 'Pants', 'Skirts', 'Accessories', 'Shoes', 'Bags', 'Jewelry'];
    }
  }
  
  List<String> get availableSizes => ['All', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];
  
  List<String> get availableColors {
    try {
      // Get all colors from ColorUtils that are used in products
      Set<String> productColors = {};
      for (var product in productController.products) {
        productColors.addAll(product.colors);
      }
      
      // If we have specific colors in products, show only those
      if (productColors.isNotEmpty) {
        return ['All', ...productColors.toList()..sort()];
      }
    } catch (e) {
      // Fallback silently if products can't be accessed
    }
    
    // Otherwise show all available colors from ColorUtils
    return ['All', ...ColorUtils.availableColors];
  }

  @override
  void onInit() {
    super.onInit();
    
    // Load categories and initialize filters
    _loadCategories();
    _initializeFilters();
    
    try {
      _filteredProducts.assignAll(productController.products);
    } catch (e) {
      // If ProductController is not available, initialize with empty list
      _filteredProducts.assignAll([]);
    }
  }

  // Load categories to ensure they're available
  Future<void> _loadCategories() async {
    try {
      // Try to load categories from product controller
      await productController.loadCategories();
      
      // Also try category controller if available
      if (Get.isRegistered<CategoryController>()) {
        final catController = Get.find<CategoryController>();
        await catController.loadCategories();
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Public method to refresh categories
  Future<void> refreshCategories() async {
    await _loadCategories();
  }

  void _initializeFilters() {
    if (productController.products.isNotEmpty) {
      final prices = productController.products.map((p) => p.price).toList();
      prices.sort();
      _priceRange.value = RangeValues(
        prices.first.floorToDouble(),
        prices.last.ceilToDouble(),
      );
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void updateCategory(String category) {
    _selectedCategory.value = category;
    _applyFilters();
  }

  void updateSize(String size) {
    _selectedSize.value = size;
    _applyFilters();
  }
  
  void updateColor(String color) {
    _selectedColor.value = color;
    _applyFilters();
  }

  void updatePriceRange(RangeValues range) {
    _priceRange.value = range;
    _applyFilters();
  }

  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  void clearAllFilters() {
    _searchQuery.value = '';
    _selectedCategory.value = 'All';
    _selectedSize.value = 'All';
    _selectedColor.value = 'All';
    _initializeFilters();
    _applyFilters();
  }

  void _applyFilters() {
    try {
      final filtered = productController.products.where((product) {
        // Text search - still include category text for user-friendly search
        final searchText = _searchQuery.value.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            product.name.toLowerCase().contains(searchText) ||
            product.description.toLowerCase().contains(searchText) ||
            product.category.toLowerCase().contains(searchText);

        // Category filter - STRICT: use categoryKey for logic
        bool matchesCategory;
        if (_selectedCategory.value == 'All') {
          matchesCategory = true;
        } else {
          final categoryKey = _selectedCategory.value
              .trim()
              .toUpperCase()
              .replaceAll(RegExp(r'\s+'), '_');
          matchesCategory = 
              product.categoryKey.trim().toUpperCase() == categoryKey;
        }

        // Size filter
        final matchesSize = _selectedSize.value == 'All' ||
            product.sizes.contains(_selectedSize.value);
            
        // Color filter
        final matchesColor = _selectedColor.value == 'All' ||
            product.colors.contains(_selectedColor.value);

        // Price filter
        final matchesPrice = product.price >= _priceRange.value.start &&
            product.price <= _priceRange.value.end;

        return matchesSearch && matchesCategory && matchesSize && matchesColor && matchesPrice;
      }).toList();

      _filteredProducts.assignAll(filtered);
    } catch (e) {
      // If ProductController is not available, clear filtered products
      _filteredProducts.clear();
    }
  }

  double get maxPrice {
    try {
      if (productController.products.isEmpty) return 1000;
      return productController.products
          .map((p) => p.price)
          .reduce((a, b) => a > b ? a : b)
          .ceilToDouble();
    } catch (e) {
      return 1000;
    }
  }
}
