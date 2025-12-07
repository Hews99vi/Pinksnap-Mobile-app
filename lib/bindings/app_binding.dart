import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/search_controller.dart';
import '../controllers/image_search_controller.dart';
import '../services/image_search_service.dart';
import '../services/tflite_model_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register base controllers first (no dependencies)
    Get.put(AuthController(), permanent: true);
    Get.put(CategoryController(), permanent: true);
    Get.put(CartController(), permanent: true);
    
    // Register ProductController (depends on AuthController, CategoryController)
    Get.put(ProductController(), permanent: true);
    
    // Register TFLiteModelService (singleton pattern, no dependencies)
    Get.put(TFLiteModelService(), permanent: true);
    
    // Register ImageSearchService AFTER ProductController and TFLiteModelService
    // This service uses Get.find<ProductController>() internally
    Get.put(ImageSearchService(), permanent: true);
    
    // Register ImageSearchController (depends on ImageSearchService)
    Get.put(ImageSearchController(), permanent: true);
    
    // Register other controllers
    Get.put(OrderController(), permanent: true);
    Get.put(SearchController(), permanent: true);
  }
}
