import 'package:get/get.dart';
import '../models/product.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  
  final RxList<Product> _products = <Product>[].obs;
  final RxBool _isLoading = false.obs;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSampleProducts();
  }
  
  void _loadSampleProducts() {
    // Add some sample products
    _products.addAll([
      Product(
        id: '1',
        name: 'Summer Dress',
        description: 'Beautiful summer dress perfect for any occasion',
        price: 59.99,
        images: ['https://via.placeholder.com/300x400'],
        category: 'Dresses',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: {'XS': 5, 'S': 10, 'M': 15, 'L': 8, 'XL': 3},
        rating: 4.5,
        reviewCount: 124,
      ),
      Product(
        id: '2',
        name: 'Elegant Blouse',
        description: 'Sophisticated blouse for professional wear',
        price: 45.99,
        images: ['https://via.placeholder.com/300x400'],
        category: 'Tops',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: {'XS': 3, 'S': 7, 'M': 12, 'L': 6, 'XL': 4},
        rating: 4.2,
        reviewCount: 89,
      ),
    ]);
  }
  
  Future<bool> addProduct(Product product) async {
    try {
      _isLoading.value = true;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _products.add(product);
      
      Get.snackbar(
        'Success',
        'Product added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading.value = true;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        
        Get.snackbar(
          'Success',
          'Product updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading.value = true;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _products.removeWhere((p) => p.id == productId);
      
      Get.snackbar(
        'Success',
        'Product deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
  
  List<String> get categories {
    return _products.map((product) => product.category).toSet().toList();
  }
}
