import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order.dart';
import '../controllers/order_controller.dart';
import '../utils/app_bar_utils.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find<OrderController>();
    
    return Scaffold(
      appBar: AppBarUtils.whiteAppBar(
        title: 'Order #${order.id.substring(0, 8).toUpperCase()}',
        actions: [
          IconButton(
            onPressed: () {
              orderController.loadUserOrders(order.userId);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Order',
          ),
        ],
      ),
      body: GetBuilder<OrderController>(
        builder: (controller) {
          // Try to get the updated order from the controller
          Order? updatedOrder;
          try {
            updatedOrder = controller.orders.firstWhere(
              (o) => o.id == order.id,
              orElse: () => order,
            );
          } catch (e) {
            print('Error finding updated order: $e');
            updatedOrder = order;
          }
          
          // Safety check to ensure we have valid order data
          if (updatedOrder.id.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Order data is invalid',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Please try refreshing or go back',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return _buildOrderDetails(updatedOrder);
        },
      ),
    );
  }

  Widget _buildOrderDetails(Order currentOrder) {
    try {
      return SingleChildScrollView(
        child: Column(
          children: [
            // Order Status Progress
            _buildStatusProgress(currentOrder),
            
            // Order Details Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOrderSummaryCard(currentOrder),
                  const SizedBox(height: 16),
                  _buildOrderItemsCard(currentOrder),
                  const SizedBox(height: 16),
                  _buildShippingCard(currentOrder),
                  const SizedBox(height: 16),
                  if (currentOrder.trackingNumber != null && currentOrder.trackingNumber!.isNotEmpty)
                    _buildTrackingCard(currentOrder),
                  if (currentOrder.notes != null && currentOrder.notes!.isNotEmpty)
                    _buildNotesCard(currentOrder),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building order details: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading order details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Error: $e',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusProgress(Order currentOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            currentOrder.status.color.withValues(alpha: 0.1),
            currentOrder.status.color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Current Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: currentOrder.status.color,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentOrder.status.icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  currentOrder.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Description
          Text(
            currentOrder.status.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Progress Timeline
          _buildProgressTimeline(currentOrder),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(Order currentOrder) {
    final progressStatuses = OrderStatusExtension.progressOrder;
    final currentIndex = currentOrder.status == OrderStatus.cancelled || currentOrder.status == OrderStatus.refunded
        ? -1
        : progressStatuses.indexOf(currentOrder.status);

    return Column(
      children: progressStatuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == progressStatuses.length - 1;

        return Column(
          children: [
            Row(
              children: [
                // Status Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? status.color : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(
                      color: status.color,
                      width: 3,
                    ) : null,
                  ),
                  child: Icon(
                    status.icon,
                    color: isCompleted ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Status Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.displayName,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCompleted ? Colors.black87 : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 4),
                        Text(
                          status.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            // Connecting Line
            if (!isLast)
              Container(
                margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                height: 30,
                width: 2,
                color: isCompleted ? status.color : Colors.grey[300],
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummaryCard(Order currentOrder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Order ID', '#${currentOrder.id.substring(0, 8).toUpperCase()}'),
            _buildInfoRow('Order Date', _formatDateTime(currentOrder.createdAt)),
            _buildInfoRow('Payment Status', currentOrder.paymentStatus.displayName),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${currentOrder.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(Order currentOrder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${currentOrder.items.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...currentOrder.items.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard(Order currentOrder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentOrder.shippingAddress.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentOrder.shippingAddress.fullAddress,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard(Order currentOrder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.blue[50] ?? Colors.blue.withValues(alpha: 0.1),
              Colors.blue[25] ?? Colors.blue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Package Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200] ?? Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracking Number',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentOrder.trackingNumber ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: currentOrder.trackingNumber != null ? () {
                      // Copy tracking number to clipboard
                      Get.snackbar(
                        'Copied!',
                        'Tracking number copied to clipboard',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    } : null,
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Order currentOrder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notes,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200] ?? Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Text(
                currentOrder.notes ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
