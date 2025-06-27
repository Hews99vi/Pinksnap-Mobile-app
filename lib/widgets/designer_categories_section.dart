import 'package:flutter/material.dart';

class DesignerCategoriesSection extends StatelessWidget {
  const DesignerCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Overcoats',
        'description': 'Designer overcoats and coats,\nfeaturing brands such as Trench\nand low-key essentials.',
        'image': 'assets/images/placeholder.png',
      },
      {
        'title': 'Dresses',
        'description': 'From casual to cocktail\ndresses, including graphic prints\nand tie-dye designs.',
        'image': 'assets/images/placeholder.png',
      },
      {
        'title': 'Outerwear',
        'description': 'Luxury outerwear including\njackets, and hoodies by top fashion\nbrands including classics.',
        'image': 'assets/images/placeholder.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Designer Clothes For You',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover yourself with our curated selection of designer clothes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(16),
                        ),
                        child: Image.asset(
                          category['image'],
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['title'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['description'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.pink[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
