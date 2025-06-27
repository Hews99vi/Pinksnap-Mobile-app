class CartItem {
  final String productId;
  final String size;
  int quantity;
  final double price;
  final String productName;
  final String productImage;

  CartItem({
    required this.productId,
    required this.size,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.productImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      size: json['size'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'size': size,
      'quantity': quantity,
      'price': price,
      'productName': productName,
      'productImage': productImage,
    };
  }

  double get total => price * quantity;
}
