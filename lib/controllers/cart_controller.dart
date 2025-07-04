import 'package:get/get.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartController extends GetxController {
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  
  List<CartItem> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.length;
  
  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }
  
  void addToCart(Product product, String size, int quantity) {
    // Check if item already exists in cart
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id && item.size == size,
    );
    
    if (existingItemIndex >= 0) {
      // Update quantity of existing item
      _cartItems[existingItemIndex].quantity += quantity;
      _cartItems.refresh();
    } else {
      // Add new item to cart
      final cartItem = CartItem(
        productId: product.id,
        size: size,
        quantity: quantity,
        price: product.price,
        productName: product.name,
        productImage: product.images.first,
      );
      _cartItems.add(cartItem);
    }
    
    update();
  }
  
  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      update();
    }
  }
  
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else {
        _cartItems[index].quantity = newQuantity;
        _cartItems.refresh();
        update();
      }
    }
  }
  
  void clearCart() {
    _cartItems.clear();
    update();
  }
  
  bool isInCart(String productId, String size) {
    return _cartItems.any(
      (item) => item.productId == productId && item.size == size,
    );
  }
  
  int getQuantityInCart(String productId, String size) {
    final item = _cartItems.firstWhereOrNull(
      (item) => item.productId == productId && item.size == size,
    );
    return item?.quantity ?? 0;
  }
}
