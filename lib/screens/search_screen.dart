import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../widgets/product_card.dart';
import '../utils/responsive.dart';
import 'product_details_screen.dart';
import '../utils/color_utils.dart';

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
          'Search & Discover',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withValues(alpha: 0.1),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: searchController.filteredProducts.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${searchController.filteredProducts.length} found',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          )),
          Obx(() => IconButton(
            icon: Icon(
              searchController.showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: searchController.showFilters ? Colors.pink[600] : Colors.grey[600],
            ),
            tooltip: 'Filters',
            onPressed: () => searchController.toggleFilters(),
          )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => searchController.updateSearchQuery(value),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for dresses, tops, accessories...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.pink[400],
                      size: 24,
                    ),
                  ),
                  suffixIcon: Obx(() => searchController.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                          onPressed: () {
                            _searchController.clear();
                            searchController.updateSearchQuery('');
                          },
                        )
                      : const SizedBox()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
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
                        spacing: 8,
                        runSpacing: 6,
                        children: searchController.availableCategories
                            .map((category) => InkWell(
                                  onTap: () {
                                    searchController.updateCategory(category);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                    child: Chip(
                                      label: Text(category),
                                      labelStyle: TextStyle(
                                        color: searchController.selectedCategory == category
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      backgroundColor: searchController.selectedCategory == category
                                          ? Colors.pink[400]
                                          : Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    ),
                                  ),
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
                        spacing: 8,
                        runSpacing: 6,
                        children: searchController.availableSizes
                            .map((size) => InkWell(
                                  onTap: () {
                                    searchController.updateSize(size);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                    child: Chip(
                                      label: Text(size),
                                      labelStyle: TextStyle(
                                        color: searchController.selectedSize == size
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      backgroundColor: searchController.selectedSize == size
                                          ? Colors.pink[400]
                                          : Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    ),
                                  ),
                                ))
                            .toList(),
                      )),
                      
                      const SizedBox(height: 20),
                      
                      // Color Filter
                      const Text(
                        'Color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // All colors option
                          InkWell(
                            onTap: () {
                              searchController.updateColor('All');
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                              child: Chip(
                                label: const Text('All'),
                                labelStyle: TextStyle(
                                  color: searchController.selectedColor == 'All' 
                                      ? Colors.white 
                                      : Colors.grey[700],
                                  fontSize: 12,
                                ),
                                backgroundColor: searchController.selectedColor == 'All' 
                                    ? Colors.pink[400] 
                                    : Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              ),
                            ),
                          ),
                          
                          // Individual colors
                          ...searchController.availableColors
                              .where((color) => color != 'All')
                              .map((color) {
                                bool isSelected = searchController.selectedColor == color;
                                Color displayColor = ColorUtils.getColorFromName(color);
                                
                                return InkWell(
                                  onTap: () {
                                    searchController.updateColor(color);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                    child: Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: displayColor,
                                        radius: 8,
                                      ),
                                      label: Text(color),
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      backgroundColor: isSelected 
                                          ? Colors.pink[400] 
                                          : Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  ),
                                ),
                              );
                            }),
                      ],
                    )),                      const SizedBox(height: 20),
                      
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
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[200]!, Colors.grey[100]!],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Products Found',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters\nto find what you\'re looking for',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Responsive grid with max-width constraint
                final crossAxisCount = Responsive.value<int>(
                  context: context,
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                );
                
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.isDesktop(context) ? 1400.0 : double.infinity,
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(Responsive.isDesktop(context) ? 20 : 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
                        mainAxisSpacing: Responsive.isDesktop(context) ? 20 : 16,
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
                ),
              ),
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
