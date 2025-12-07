import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart' as models;

class ManageCategoriesVisibilityScreen extends StatefulWidget {
  const ManageCategoriesVisibilityScreen({super.key});

  @override
  State<ManageCategoriesVisibilityScreen> createState() =>
      _ManageCategoriesVisibilityScreenState();
}

class _ManageCategoriesVisibilityScreenState
    extends State<ManageCategoriesVisibilityScreen> {
  final categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    // Reload categories to ensure we have the latest data
    categoryController.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Category Visibility',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (categoryController.isLoading && categoryController.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryController.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add categories first to manage visibility',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control Category Visibility',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toggle to show/hide categories in the "Shop by Category" section for customers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Category list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoryController.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryController.categories[index];
                  return _buildCategoryCard(category);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryCard(models.Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: category.isVisible
                  ? [Colors.pink[400]!, Colors.pink[600]!]
                  : [Colors.grey[400]!, Colors.grey[600]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category.isVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          category.isVisible
              ? 'Visible to customers • Key: ${category.key}'
              : 'Hidden from customers • Key: ${category.key}',
          style: TextStyle(
            fontSize: 12,
            color: category.isVisible
                ? Colors.green[700]
                : Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: category.isVisible,
          activeColor: Colors.pink[400],
          onChanged: (value) async {
            debugPrint('Toggling visibility for ${category.name} to $value');
            await categoryController.toggleCategoryVisibility(category, value);
          },
        ),
      ),
    );
  }
}
