import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderController extends GetxController {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  
  final RxList<Order> _orders = <Order>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // Statistics
  int get totalOrders => _orders.length;
  
  double get totalRevenue => _orders
      .where((order) => order.paymentStatus == PaymentStatus.paid)
      .fold(0.0, (sum, order) => sum + order.totalAmount);
  
  int get pendingOrders => _orders
      .where((order) => order.status == OrderStatus.pending)
      .length;
  
  int get completedOrders => _orders
      .where((order) => order.status == OrderStatus.delivered)
      .length;

  Map<OrderStatus, int> get ordersByStatus {
    final Map<OrderStatus, int> statusCount = {};
    for (final status in OrderStatus.values) {
      statusCount[status] = _orders
          .where((order) => order.status == status)
          .length;
    }
    return statusCount;
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final querySnapshot = await _firestore
          .collection('orders')
          .get();

      final orders = querySnapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return Order.fromJson(data);
          })
          .toList();

      // Sort locally by creation date
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _orders.value = orders;
    } catch (e) {
      _error.value = 'Failed to load orders: $e';
      debugPrint('Error loading orders: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadUserOrders(String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // First try with orderBy, if that fails, try without orderBy
      firestore.Query query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId);

      firestore.QuerySnapshot querySnapshot;
      
      try {
        // Try with orderBy first
        querySnapshot = await query
            .orderBy('createdAt', descending: true)
            .get();
      } catch (indexError) {
        debugPrint('Index not available, querying without orderBy: $indexError');
        // If index doesn't exist, query without orderBy
        querySnapshot = await query.get();
      }

      final orders = querySnapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return Order.fromJson(data);
          })
          .toList();

      // Sort locally if we couldn't sort on the server
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _orders.value = orders;
      debugPrint('Loaded ${orders.length} orders for user $userId');
    } catch (e) {
      _error.value = 'Failed to load user orders. Please try again.';
      debugPrint('Error loading user orders: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String> createOrder({
    required String userId,
    required String customerName,
    required String customerEmail,
    required List<CartItem> cartItems,
    required ShippingAddress shippingAddress,
    String? paymentIntentId, // Add this parameter
  }) async {
    try {
      debugPrint('Creating order for user: $userId');
      debugPrint('Customer: $customerName');
      debugPrint('Cart items count: ${cartItems.length}');
      
      final orderItems = cartItems.map((cartItem) => OrderItem(
        productId: cartItem.productId,
        productName: cartItem.productName,
        productImage: cartItem.productImage,
        size: cartItem.size,
        quantity: cartItem.quantity,
        price: cartItem.price,
        total: cartItem.total,
      )).toList();

      final totalAmount = cartItems.fold(0.0, (sum, item) => sum + item.total);
      debugPrint('Total amount: $totalAmount');

      final orderData = {
        'userId': userId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'items': orderItems.map((item) => item.toJson()).toList(),
        'shippingAddress': shippingAddress.toJson(),
        'totalAmount': totalAmount,
        'status': OrderStatus.pending.toString().split('.').last,
        'paymentStatus': paymentIntentId != null ? PaymentStatus.paid.toString().split('.').last : PaymentStatus.pending.toString().split('.').last,
        'createdAt': DateTime.now().toIso8601String(),
        'paymentIntentId': paymentIntentId, // Add this line
      };

      debugPrint('Order data prepared, attempting to save to Firestore...');
      
      final docRef = await _firestore.collection('orders').add(orderData);
      debugPrint('Order saved successfully with ID: ${docRef.id}');
      
      // Create order object for local storage
      final order = Order(
        id: docRef.id,
        userId: userId,
        customerName: customerName,
        customerEmail: customerEmail,
        items: orderItems,
        shippingAddress: shippingAddress,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        paymentStatus: paymentIntentId != null ? PaymentStatus.paid : PaymentStatus.pending,
        createdAt: DateTime.now(),
        paymentIntentId: paymentIntentId, // Add this line
      );
      
      // Add the order to local list
      _orders.insert(0, order);

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      debugPrint('Error type: ${e.runtimeType}');
      _error.value = 'Failed to create order: $e';
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      Order? updatedOrder;
      if (orderIndex != -1) {
        updatedOrder = _orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        _orders[orderIndex] = updatedOrder;
        _orders.refresh();
      }

      // Send notification to user about status update
      if (updatedOrder != null) {
        await _sendStatusUpdateNotification(updatedOrder, newStatus);
      }

    } catch (e) {
      _error.value = 'Failed to update order status: $e';
      rethrow;
    }
  }

  Future<void> _sendStatusUpdateNotification(Order order, OrderStatus newStatus) async {
    try {
      // Create a notification document in Firestore
      await _firestore.collection('notifications').add({
        'userId': order.userId,
        'type': 'order_status_update',
        'title': 'Order Status Updated',
        'message': 'Your order #${order.id.substring(0, 8).toUpperCase()} status has been updated to ${newStatus.displayName}',
        'data': {
          'orderId': order.id,
          'status': newStatus.toString().split('.').last,
          'description': newStatus.description,
        },
        'createdAt': DateTime.now().toIso8601String(),
        'read': false,
      });

      debugPrint('Status update notification sent for order ${order.id}');
    } catch (e) {
      debugPrint('Failed to send status update notification: $e');
      // Don't throw error as this is not critical
    }
  }

  Future<void> updatePaymentStatus(String orderId, PaymentStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'paymentStatus': newStatus.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          paymentStatus: newStatus,
          updatedAt: DateTime.now(),
        );
        _orders.refresh();
      }

      Get.snackbar(
        'Success',
        'Payment status updated successfully',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = 'Failed to update payment status: $e';
      Get.snackbar(
        'Error',
        'Failed to update payment status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateTrackingNumber(String orderId, String trackingNumber) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'trackingNumber': trackingNumber,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      Order? updatedOrder;
      if (orderIndex != -1) {
        updatedOrder = _orders[orderIndex].copyWith(
          trackingNumber: trackingNumber,
          updatedAt: DateTime.now(),
        );
        _orders[orderIndex] = updatedOrder;
        _orders.refresh();
      }

      // Send notification to user about tracking number
      if (updatedOrder != null) {
        await _sendTrackingNotification(updatedOrder, trackingNumber);
      }

    } catch (e) {
      _error.value = 'Failed to update tracking number: $e';
      rethrow;
    }
  }

  Future<void> _sendTrackingNotification(Order order, String trackingNumber) async {
    try {
      // Create a notification document in Firestore
      await _firestore.collection('notifications').add({
        'userId': order.userId,
        'type': 'tracking_added',
        'title': 'Tracking Number Added',
        'message': 'Tracking number for your order #${order.id.substring(0, 8).toUpperCase()} is now available: $trackingNumber',
        'data': {
          'orderId': order.id,
          'trackingNumber': trackingNumber,
        },
        'createdAt': DateTime.now().toIso8601String(),
        'read': false,
      });

      debugPrint('Tracking notification sent for order ${order.id}');
    } catch (e) {
      debugPrint('Failed to send tracking notification: $e');
      // Don't throw error as this is not critical
    }
  }

  Future<void> addOrderNotes(String orderId, String notes) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'notes': notes,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          notes: notes,
          updatedAt: DateTime.now(),
        );
        _orders.refresh();
      }

    } catch (e) {
      _error.value = 'Failed to update order notes: $e';
      rethrow;
    }
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _orders.where((order) {
      return order.createdAt.isAfter(startDate) && 
             order.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      
      _orders.removeWhere((order) => order.id == orderId);
      
      Get.snackbar(
        'Success',
        'Order deleted successfully',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = 'Failed to delete order: $e';
      Get.snackbar(
        'Error',
        'Failed to delete order',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearError() {
    _error.value = '';
  }

  // Method to create sample orders for testing
  Future<void> createSampleOrders(String userId) async {
    try {
      // Sample order data
      final sampleOrders = [
        {
          'userId': userId,
          'customerName': 'Test User',
          'customerEmail': 'test@example.com',
          'orderItems': [
            {
              'productId': 'sample_1',
              'productName': 'Pink Summer Dress',
              'productImage': 'https://example.com/dress.jpg',
              'size': 'M',
              'quantity': 1,
              'price': 49.99,
              'total': 49.99,
            }
          ],
          'totalAmount': 49.99,
          'status': OrderStatus.pending.toString(),
          'paymentStatus': PaymentStatus.pending.toString(),
          'shippingAddress': {
            'name': 'Test User',
            'addressLine1': '123 Test Street',
            'addressLine2': 'Apt 4B',
            'city': 'Test City',
            'state': 'Test State',
            'zipCode': '12345',
            'country': 'Test Country',
            'phone': '+1234567890',
          },
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'estimatedDelivery': DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
        },
        {
          'userId': userId,
          'customerName': 'Test User',
          'customerEmail': 'test@example.com',
          'orderItems': [
            {
              'productId': 'sample_2',
              'productName': 'Pink Floral Top',
              'productImage': 'https://example.com/top.jpg',
              'size': 'S',
              'quantity': 2,
              'price': 29.99,
              'total': 59.98,
            }
          ],
          'totalAmount': 59.98,
          'status': OrderStatus.shipped.toString(),
          'paymentStatus': PaymentStatus.paid.toString(),
          'trackingNumber': 'TRK123456789',
          'shippingAddress': {
            'name': 'Test User',
            'addressLine1': '456 Sample Ave',
            'city': 'Sample City',
            'state': 'Sample State',
            'zipCode': '67890',
            'country': 'Sample Country',
            'phone': '+0987654321',
          },
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch,
          'estimatedDelivery': DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
        }
      ];

      // Create the orders in Firestore
      for (final orderData in sampleOrders) {
        await _firestore.collection('orders').add(orderData);
      }
      
      debugPrint('Created ${sampleOrders.length} sample orders for user $userId');
      
      // Reload orders to show the new ones
      await loadUserOrders(userId);
    } catch (e) {
      debugPrint('Error creating sample orders: $e');
    }
  }

  Future<void> updateOrderBatch(String orderId, Map<String, dynamic> updateData, OrderStatus? newStatus) async {
    try {
      // Update Firestore document
      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      Order? updatedOrder;
      if (orderIndex != -1) {
        final currentOrder = _orders[orderIndex];
        updatedOrder = currentOrder.copyWith(
          status: newStatus ?? currentOrder.status,
          trackingNumber: updateData['trackingNumber'] ?? currentOrder.trackingNumber,
          notes: updateData['notes'] ?? currentOrder.notes,
          updatedAt: DateTime.now(),
        );
        _orders[orderIndex] = updatedOrder;
        _orders.refresh();
      }

      // Send notification if status was updated
      if (newStatus != null && updatedOrder != null) {
        await _sendStatusUpdateNotification(updatedOrder, newStatus);
      }

      // Send tracking notification if tracking number was updated
      if (updateData.containsKey('trackingNumber') && updatedOrder != null) {
        await _sendTrackingNotification(updatedOrder, updateData['trackingNumber']);
      }

    } catch (e) {
      _error.value = 'Failed to update order: $e';
      rethrow; // Re-throw to let the UI handle the error
    }
  }
}
