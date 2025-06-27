import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [      {
        'name': 'Dresses',
        'icon': Icons.checkroom,
        'color': Colors.pink[100],
      },
      {
        'name': 'Tops',
        'icon': Icons.shopping_bag,
        'color': Colors.purple[100],
      },
      {
        'name': 'Pants',
        'icon': Icons.recent_actors_outlined,
        'color': Colors.blue[100],
      },
      {
        'name': 'Skirts',
        'icon': Icons.shopping_basket,
        'color': Colors.orange[100],
      },
      {
        'name': 'Accessories',
        'icon': Icons.diamond,
        'color': Colors.green[100],
      },
      {
        'name': 'Shoes',
        'icon': Icons.hiking,
        'color': Colors.red[100],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to category products
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: category['color'],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 48,
                      color: Colors.pink,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
