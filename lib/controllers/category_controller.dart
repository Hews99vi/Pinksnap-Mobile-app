import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_db_service.dart';
import '../utils/category_seeder.dart';
import '../models/category.dart' as models;
import '../models/product.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();
  
  final RxList<models.Category> _categories = <models.Category>[].obs;
  final RxBool _isLoading = false.obs;
  
  List<models.Category> get categories => _categories;
  RxList<models.Category> get categoriesRx => _categories; // ✅ Expose reactive list
  bool get isLoading => _isLoading.value;
  
  // Get only visible categories for Shop by Category section
  List<models.Category> get visibleShopCategories => 
      _categories.where((c) => c.isVisible)
          .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  
  // Get category names for backward compatibility
  List<String> get categoryNames => _categories.map((c) => c.name).toList();
  
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }
  
  // Load all categories
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;
      List<models.Category> loadedCategories = await FirebaseDbService.getCategories();
      
      debugPrint('🔥 RAW categories count = ${loadedCategories.length}');
      for (final c in loadedCategories) {
        debugPrint('🔥 cat name="${c.name}" key="${c.key}" visible=${c.isVisible} sortOrder=${c.sortOrder} id="${c.id}"');
      }
      
      _categories.assignAll(loadedCategories);
      
      final visibleCount = _categories.where((c) => c.isVisible).length;
      debugPrint('✅ Loaded ${loadedCategories.length} categories ($visibleCount visible)');
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Seed default categories
  Future<void> seedDefaultCategories() async {
    try {
      _isLoading.value = true;
      await CategorySeeder.seedDefaultCategories();
      await loadCategories(); // Reload after seeding
      Get.snackbar('Success', 'Default categories added successfully');
    } catch (e) {
      debugPrint('Error seeding categories: $e');
      Get.snackbar('Error', 'Failed to add default categories');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Add a new category
  Future<bool> addCategory(String categoryName) async {
    try {
      _isLoading.value = true;
      
      // Check if category already exists
      if (_categories.any((c) => c.name == categoryName)) {
        Get.snackbar('Error', 'Category already exists');
        return false;
      }
      
      final categoryKey = categoryName.toUpperCase().replaceAll(' ', '_');
      final category = models.Category(
        id: categoryKey,  // Use key as document ID
        name: categoryName,
        key: categoryKey,
        isVisible: true,
        sortOrder: _categories.length,
      );
      
      await FirebaseDbService.addCategory(category);
      _categories.add(category);
      Get.snackbar('Success', 'Category added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      Get.snackbar('Error', 'Failed to add category');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Update a category
  Future<bool> updateCategory(String oldName, String newName) async {
    try {
      _isLoading.value = true;
      
      // Find the old category
      final oldCategory = _categories.firstWhereOrNull((c) => c.name == oldName);
      if (oldCategory == null) {
        Get.snackbar('Error', 'Category not found');
        return false;
      }
      
      // Check if new name already exists (and it's different from old name)
      if (oldName != newName && _categories.any((c) => c.name == newName)) {
        Get.snackbar('Error', 'Category name already exists');
        return false;
      }
      
      final newCategory = oldCategory.copyWith(
        name: newName,
        key: newName.toUpperCase().replaceAll(' ', '_'),
      );
      
      await FirebaseDbService.updateCategory(oldCategory, newCategory);
      
      // Update local list
      int index = _categories.indexWhere((c) => c.name == oldName);
      if (index != -1) {
        _categories[index] = newCategory;
      }
      
      Get.snackbar('Success', 'Category updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      Get.snackbar('Error', 'Failed to update category');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Toggle category visibility
  Future<bool> toggleCategoryVisibility(models.Category category, bool isVisible) async {
    try {
      _isLoading.value = true;
      
      debugPrint('🔄 Toggling visibility for ${category.name} (id: ${category.id}, key: ${category.key}) to $isVisible');
      await FirebaseDbService.updateCategoryVisibility(category, isVisible);
      
      // Update local list by id (not name)
      int index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category.copyWith(isVisible: isVisible);
        debugPrint('✅ Updated local category list at index $index');
      } else {
        debugPrint('⚠️ Category not found in local list: ${category.id}');
      }
      
      debugPrint('✅ Toggled visibility for ${category.name}: $isVisible');
      Get.snackbar(
        'Success', 
        'Category ${isVisible ? "shown" : "hidden"} successfully',
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      debugPrint('Error toggling category visibility: $e');
      Get.snackbar('Error', 'Failed to update category visibility');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Delete a category
  Future<bool> deleteCategory(String categoryName) async {
    try {
      _isLoading.value = true;
      
      // Find the category
      final category = _categories.firstWhereOrNull((c) => c.name == categoryName);
      if (category == null) {
        Get.snackbar('Error', 'Category not found');
        return false;
      }
      
      // Check if category has products
      bool hasProducts = await FirebaseDbService.categoryHasProducts(categoryName);
      if (hasProducts) {
        Get.snackbar(
          'Warning', 
          'Cannot delete category with existing products. Please move or delete products first.',
          duration: const Duration(seconds: 4),
        );
        return false;
      }
      
      await FirebaseDbService.deleteCategory(category);
      _categories.removeWhere((c) => c.name == categoryName);
      Get.snackbar('Success', 'Category deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      Get.snackbar('Error', 'Failed to delete category');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Get category count
  int get categoryCount => _categories.length;
  
  // Helper: Normalize a category key using Product's normalization logic
  String normalizeKey(String raw) => Product.normalizeCategoryKey(raw);
  
  // Helper: Get category name for a given normalized key
  String? nameForKey(String key) {
    return _categories.firstWhereOrNull(
      (c) => normalizeKey(c.key.isNotEmpty ? c.key : c.name) == key
    )?.name;
  }
}
