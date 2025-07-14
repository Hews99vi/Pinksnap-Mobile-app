import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../controllers/product_controller.dart';
import 'package:get/get.dart';

class ImageSearchService {
  final String baseUrl = 'https://your-ml-api-endpoint.com'; // Replace with your ML API endpoint
  final ProductController _productController = Get.find<ProductController>();
  
  Future<List<Product>> searchSimilarProducts(File imageFile) async {
    try {
      // For now, return mock data since ML model isn't implemented yet
      // Later, you can replace this with actual API call to your ML service
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Return mock similar products (random selection from existing products)
      final allProducts = _productController.products;
      if (allProducts.isEmpty) {
        return [];
      }
      
      // Return random 5-8 products as "similar" results for demonstration
      final shuffled = List.from(allProducts)..shuffle();
      final resultCount = (5 + (shuffled.length * 0.1).round()).clamp(5, 8);
      
      return shuffled.take(resultCount).cast<Product>().toList();
      
      /* 
      // Uncomment this when you have your ML API ready:
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/search-similar'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(responseData);
        final List<dynamic> results = jsonData['similar_products'];
        
        return results.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search similar products');
      }
      */
      
    } catch (e) {
      throw Exception('Error searching similar products: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // This will be used for extracting features from the image
      // For now, return mock analysis data
      
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'categories': ['dress', 'formal', 'evening'],
        'colors': ['black', 'red', 'blue'],
        'patterns': ['solid', 'floral'],
        'style': 'elegant',
        'confidence': 0.85,
      };
      
      /*
      // Uncomment this when you have your ML API ready:
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze-image'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to analyze image');
      }
      */
      
    } catch (e) {
      throw Exception('Error analyzing image: ${e.toString()}');
    }
  }
}
