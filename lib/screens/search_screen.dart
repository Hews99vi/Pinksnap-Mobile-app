import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final search_ctrl.SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = Get.put(search_ctrl.SearchController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Search Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              searchController.showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: searchController.showFilters ? Colors.pink[600] : Colors.grey[600],
            ),
            onPressed: () => searchController.toggleFilters(),
          )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => searchController.updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: Obx(() => searchController.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _searchController.clear();
                            searchController.updateSearchQuery('');
                          },
                        )
                      : const SizedBox()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Filters Section
            Obx(() {
              if (!searchController.showFilters) return const SizedBox();
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () => searchController.clearAllFilters(),
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category Filter
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: searchController.availableCategories
                            .map((category) => FilterChip(
                                  label: Text(
                                    category,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  selected: searchController.selectedCategory == category,
                                  onSelected: (selected) {
                                    searchController.updateCategory(category);
                                  },
                                  selectedColor: Colors.pink[100],
                                  checkmarkColor: Colors.pink[600],
                                  backgroundColor: Colors.grey[50],
                                  side: BorderSide(
                                    color: searchController.selectedCategory == category 
                                        ? Colors.pink[600]! 
                                        : Colors.grey[300]!,
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                ))
                            .toList(),
                      )),
                      
                      const SizedBox(height: 20),
                      
                      // Size Filter
                      const Text(
                        'Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: searchController.availableSizes
                            .map((size) => FilterChip(
                                  label: Text(
                                    size,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  selected: searchController.selectedSize == size,
                                  onSelected: (selected) {
                                    searchController.updateSize(size);
                                  },
                                  selectedColor: Colors.pink[100],
                                  checkmarkColor: Colors.pink[600],
                                  backgroundColor: Colors.grey[50],
                                  side: BorderSide(
                                    color: searchController.selectedSize == size 
                                        ? Colors.pink[600]! 
                                        : Colors.grey[300]!,
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                ))
                            .toList(),
                      )),
                      
                      const SizedBox(height: 20),
                      
                      // Price Range Filter
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Column(
                        children: [
                          RangeSlider(
                            values: searchController.priceRange,
                            min: 0,
                            max: searchController.maxPrice,
                            divisions: 20,
                            activeColor: Colors.pink[600],
                            inactiveColor: Colors.pink[100],
                            onChanged: (values) {
                              searchController.updatePriceRange(values);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${searchController.priceRange.start.toInt()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '\$${searchController.priceRange.end.toInt()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Obx(() => Text(
                    '${searchController.filteredProducts.length} products found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Products Grid
            Expanded(
              child: Obx(() {
                if (searchController.filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: searchController.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = searchController.filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetailsScreen(product: product));
                      },
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          Get.to(() => ProductDetailsScreen(product: product));
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<search_ctrl.SearchController>();
    super.dispose();
  }
}
