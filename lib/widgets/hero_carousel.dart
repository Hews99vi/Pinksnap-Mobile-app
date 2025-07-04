import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<Map<String, String>> heroSlides = [
    {
      'title': 'Discover and\nFind Your Own\nFashion',
      'subtitle': 'Design your perfect fit',
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=720&h=450&fit=crop',
    },
    {
      'title': 'Exclusive\nFashion\nCollection',
      'subtitle': 'Shop the latest trends',
      'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=720&h=450&fit=crop',
    },
    {
      'title': 'New Summer\nCollection\n2025',
      'subtitle': 'Get ready for summer',
      'image': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=720&h=450&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % heroSlides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: heroSlides.length,
              itemBuilder: (context, index) {
                final slide = heroSlides[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Full background image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          slide['image']!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                                size: 50,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Gradient overlay for better text contrast
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      // Text content with improved styling
                      Positioned(
                        left: 24,
                        top: 24,
                        bottom: 24,
                        right: MediaQuery.of(context).size.width * 0.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                slide['title']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.grey[900],
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.pink[50]!.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.pink[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                slide['subtitle']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.pink[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implement explore action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                elevation: 4,
                                shadowColor: Colors.pink[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'EXPLORE NOW',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
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
          const SizedBox(height: 16),
          SmoothPageIndicator(
            controller: _pageController,
            count: heroSlides.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.pink,
              dotColor: Colors.pink.shade100,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
            ),
          ),
        ],
      ),
    );
  }
}
