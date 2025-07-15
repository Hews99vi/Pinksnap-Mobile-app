import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';

class SearchController extends GetxController {
  final ProductController productController = Get.find();
  late final CategoryController categoryController;
  
  // Reactive variables
  final RxList<Product> _filteredProducts = <Product>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxString _selectedSize = 'All'.obs;
  final Rx<RangeValues> _priceRange = const RangeValues(0, 1000).obs;
  final RxBool _showFilters = false.obs;

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  String get selectedSize => _selectedSize.value;
  RangeValues get priceRange => _priceRange.value;
  bool get showFilters => _showFilters.value;

  // Available filter options - make categories reactive
  List<String> get availableCategories {
    try {
      if (Get.isRegistered<CategoryController>()) {
        final catController = Get.find<CategoryController>();
        return ['All', ...catController.categories];
      }
    } catch (e) {
      // Fallback to product controller categories if category controller not available
    }
    return ['All', ...productController.categories];
  }
  
  List<String> get availableSizes => ['All', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void onInit() {
    super.onInit();
    
    // Initialize category controller if not already registered
    try {
      categoryController = Get.find<CategoryController>();
    } catch (e) {
      categoryController = Get.put(CategoryController());
    }
    
    // Ensure categories are loaded
    _loadCategories();
    
    _initializeFilters();
    _filteredProducts.assignAll(productController.products);
  }

  // Load categories to ensure they're available
  Future<void> _loadCategories() async {
    try {
      await categoryController.loadCategories();
      await productController.loadCategories();
    } catch (e) {
      debugPrint('Error loading categories in search controller: $e');
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
    _initializeFilters();
    _applyFilters();
  }

  void _applyFilters() {
    final filtered = productController.products.where((product) {
      // Text search
      final searchText = _searchQuery.value.toLowerCase();
      final matchesSearch = searchText.isEmpty ||
          product.name.toLowerCase().contains(searchText) ||
          product.description.toLowerCase().contains(searchText) ||
          product.category.toLowerCase().contains(searchText);

      // Category filter
      final matchesCategory = _selectedCategory.value == 'All' ||
          product.category == _selectedCategory.value;

      // Size filter
      final matchesSize = _selectedSize.value == 'All' ||
          product.sizes.contains(_selectedSize.value);

      // Price filter
      final matchesPrice = product.price >= _priceRange.value.start &&
          product.price <= _priceRange.value.end;

      return matchesSearch && matchesCategory && matchesSize && matchesPrice;
    }).toList();

    _filteredProducts.assignAll(filtered);
  }

  double get maxPrice {
    if (productController.products.isEmpty) return 1000;
    return productController.products
        .map((p) => p.price)
        .reduce((a, b) => a > b ? a : b)
        .ceilToDouble();
  }
}
