import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/image_search_service.dart';
import '../../controllers/product_controller.dart';

/// Debug screen to show all products and their categories
/// Add this to your app to easily see what's in the database
class ProductDebugScreen extends StatelessWidget {
  const ProductDebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final imageSearchService = Get.find<ImageSearchService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Debug Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force rebuild index to see logs
              imageSearchService.rebuildIndex();
              Get.snackbar('Debug', 'Index rebuilt - check console logs');
            },
          ),
        ],
      ),
      body: Obx(() {
        final products = productController.products;
        
        // Group by categoryKey
        final grouped = <String, List<dynamic>>{};
        for (final p in products) {
          final key = p.categoryKey;
          grouped.putIfAbsent(key, () => []).add(p);
        }
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Total Products: ${products.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Categories: ${grouped.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...grouped.entries.map((entry) {
              final categoryKey = entry.key;
              final categoryProducts = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    categoryKey,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${categoryProducts.length} products'),
                  children: [
                    ...categoryProducts.map((p) {
                      // Check for mismatches
                      final nameLower = p.name.toLowerCase();
                      bool isMismatch = false;
                      String warning = '';
                      
                      if (nameLower.contains('long sleeve') && categoryKey == 'STRAPLESS_FROCK') {
                        isMismatch = true;
                        warning = '⚠️ Should be LONG_SLEEVE_FROCK';
                      } else if (nameLower.contains('strapless') && categoryKey != 'STRAPLESS_FROCK') {
                        isMismatch = true;
                        warning = '⚠️ Should be STRAPLESS_FROCK';
                      }
                      
                      return ListTile(
                        leading: Icon(
                          isMismatch ? Icons.warning : Icons.check_circle,
                          color: isMismatch ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            color: isMismatch ? Colors.red : Colors.black,
                            fontWeight: isMismatch ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '\$${p.price}${isMismatch ? '\n$warning' : ''}',
                          style: TextStyle(
                            color: isMismatch ? Colors.red : Colors.grey,
                          ),
                        ),
                        trailing: isMismatch 
                          ? const Icon(Icons.error, color: Colors.red)
                          : null,
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      }),
    );
  }
}
