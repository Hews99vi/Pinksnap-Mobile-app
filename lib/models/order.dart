import 'package:flutter/material.dart';
import '../utils/logger.dart';

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;
  final String? notes;
  final String? paymentIntentId; // Add this field

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.shippingAddress,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.updatedAt,
    this.trackingNumber,
    this.notes,
    this.paymentIntentId, // Add this parameter
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      return Order(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        customerName: json['customerName'] ?? '',
        customerEmail: json['customerEmail'] ?? '',
        items: (json['items'] as List?)
            ?.map((item) => OrderItem.fromJson(item))
            .toList() ?? [],
        shippingAddress: json['shippingAddress'] != null 
            ? ShippingAddress.fromJson(json['shippingAddress'])
            : ShippingAddress(fullName: '', address: '', city: '', zipCode: ''),
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
          orElse: () => OrderStatus.pending,
        ),
        paymentStatus: PaymentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (json['paymentStatus'] ?? 'pending'),
          orElse: () => PaymentStatus.pending,
        ),
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : null,
        trackingNumber: json['trackingNumber'],
        notes: json['notes'],
        paymentIntentId: json['paymentIntentId'],
      );
    } catch (e) {
      Logger.error('Error parsing Order from JSON: $e', error: e);
      Logger.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'notes': notes,
      'paymentIntentId': paymentIntentId, // Add this line
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    List<OrderItem>? items,
    ShippingAddress? shippingAddress,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    String? notes,
    String? paymentIntentId, // Add this parameter
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId, // Add this line
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final String size;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.size,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItem(
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? '',
        productImage: json['productImage'] ?? '',
        size: json['size'] ?? '',
        quantity: json['quantity'] ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      Logger.error('Error parsing OrderItem from JSON: $e', error: e);
      Logger.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'size': size,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class ShippingAddress {
  final String fullName;
  final String address;
  final String city;
  final String zipCode;
  final String? state;
  final String? country;

  ShippingAddress({
    required this.fullName,
    required this.address,
    required this.city,
    required this.zipCode,
    this.state,
    this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    try {
      return ShippingAddress(
        fullName: json['fullName'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        zipCode: json['zipCode'] ?? '',
        state: json['state'],
        country: json['country'],
      );
    } catch (e) {
      Logger.error('Error parsing ShippingAddress from JSON: $e', error: e);
      Logger.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'state': state,
      'country': country,
    };
  }

  String get fullAddress {
    final parts = [address, city, state, zipCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .join(', ');
    return parts;
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order has been received and is waiting for confirmation.';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed and will be processed soon.';
      case OrderStatus.processing:
        return 'Your order is being prepared and packaged.';
      case OrderStatus.shipped:
        return 'Your order has been shipped and is on the way.';
      case OrderStatus.delivered:
        return 'Your order has been successfully delivered.';
      case OrderStatus.cancelled:
        return 'This order has been cancelled.';
      case OrderStatus.refunded:
        return 'This order has been refunded.';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.home;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.money_off;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.indigo;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  int get progressValue {
    switch (this) {
      case OrderStatus.pending:
        return 1;
      case OrderStatus.confirmed:
        return 2;
      case OrderStatus.processing:
        return 3;
      case OrderStatus.shipped:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return 0;
      case OrderStatus.refunded:
        return 0;
    }
  }

  static List<OrderStatus> get progressOrder => [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.grey;
    }
  }
}
