import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/best_selling_section.dart';
import '../widgets/designer_categories_section.dart';
import '../widgets/logo.dart' as app_logo;

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

  // Temporary mock data - replace with actual API calls later
  final List<Product> mockProducts = [
    Product(
      id: '1',
      name: 'Floral Summer Dress',
      description: 'Beautiful floral dress perfect for summer',
      price: 59.99,
      images: ['assets/images/placeholder.png'],
      category: 'Dresses',
      sizes: ['S', 'M', 'L'],
      stock: {'S': 5, 'M': 3, 'L': 2},
      rating: 4.5,
      reviewCount: 128,
    ),
    // Add more mock products here
  ];

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
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: mockProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: mockProducts[index],
                  onTap: () {
                    // TODO: Navigate to product details
                  },
                );
              },
            ),
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
