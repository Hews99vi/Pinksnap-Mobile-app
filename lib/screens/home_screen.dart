import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/best_selling_section.dart';
import '../widgets/designer_categories_section.dart';
import '../widgets/logo.dart' as app_logo;
import '../controllers/product_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'All',
    'Dresses',
    'Tops',
    'Pants',
    'Skirts',
    'Accessories'
  ];

  int _selectedCategoryIndex = 0;
  final ProductController productController = Get.find();

  List<Product> get filteredProducts {
    if (_selectedCategoryIndex == 0) {
      return productController.products;
    }
    final selectedCategory = categories[_selectedCategoryIndex];
    return productController.products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                SizedBox(
                  height: 32,
                  width: 100,
                  child: app_logo.logo,
                ),
                const SizedBox(width: 8),
                Text(
                  'PinkSnap',
                  style: TextStyle(
                    color: Colors.pink[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.pink[900]),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.pink[900]),
                onPressed: () {
                  // TODO: Implement cart
                },
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: HeroCarousel(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: BestSellingSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[900],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(categories[index]),
                            selected: _selectedCategoryIndex == index,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Obx(() => SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: filteredProducts[index],
                  onTap: () {
                    // TODO: Navigate to product details
                  },
                );
              },
            )),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: DesignerCategoriesSection(),
            ),
          ),
        ],
      ),
    );
  }
}
