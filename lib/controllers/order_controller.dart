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
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => Order.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _orders.value = orders;
    } catch (e) {
      _error.value = 'Failed to load orders: $e';
      debugPrint('Error loading orders: $e');
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
        'paymentStatus': PaymentStatus.pending.toString().split('.').last,
        'createdAt': DateTime.now().toIso8601String(),
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
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now(),
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
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        _orders.refresh();
      }

      Get.snackbar(
        'Success',
        'Order status updated successfully',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = 'Failed to update order status: $e';
      Get.snackbar(
        'Error',
        'Failed to update order status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          trackingNumber: trackingNumber,
          updatedAt: DateTime.now(),
        );
        _orders.refresh();
      }

      Get.snackbar(
        'Success',
        'Tracking number updated successfully',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = 'Failed to update tracking number: $e';
      Get.snackbar(
        'Error',
        'Failed to update tracking number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

      Get.snackbar(
        'Success',
        'Order notes updated successfully',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = 'Failed to update order notes: $e';
      Get.snackbar(
        'Error',
        'Failed to update order notes',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
}
