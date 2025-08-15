import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/screens/new_post_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final PageController _pageController = PageController();
  // Dummy data for main image previews (can represent different filters applied)
  final List<String> _mainImagePreviews = [
    'https://picsum.photos/400/500?random=100', // Original image
    'https://picsum.photos/400/500?random=101', // Filtered version 1
    'https://picsum.photos/400/500?random=102', // Filtered version 2
  ];

  // Dummy data for filter options
  final List<Map<String, dynamic>> _filters = [
    {'name': 'Normal', 'imageUrl': 'https://picsum.photos/100/100?random=1'},
    {'name': 'Clarendon', 'imageUrl': 'https://picsum.photos/100/100?random=2'},
    {'name': 'Gingham', 'imageUrl': 'https://picsum.photos/100/100?random=3'},
    {'name': 'Moon', 'imageUrl': 'https://picsum.photos/100/100?random=4'},
    {'name': 'Lark', 'imageUrl': 'https://picsum.photos/100/100?random=5'},
    {'name': 'Reyes', 'imageUrl': 'https://picsum.photos/100/100?random=6'},
    {'name': 'Juno', 'imageUrl': 'https://picsum.photos/100/100?random=7'},
    {'name': 'Slumber', 'imageUrl': 'https://picsum.photos/100/100?random=8'},
    {'name': 'Crema', 'imageUrl': 'https://picsum.photos/100/100?random=9'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        // No title in the center as per image
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: primaryColor,
            ), // Forward arrow icon
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(pageBuilder: (_, __, ___) => NewPostScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false, // Ensure actions are right-aligned if no title
      ),
      body: SingleChildScrollView(
        // Wrapped entire body content in SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image Preview Carousel
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _mainImagePreviews.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Handle tap on image (e.g., show full screen or navigate)
                          },
                          child: Image.network(
                            _mainImagePreviews[index],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey[600],
                                    size: 80,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Filter Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to a full list of filters
                    },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          primaryColor, // Use primaryColor for "See All"
                    ),
                    child: Text(
                      'See All',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Filter Grid
            GridView.builder(
              shrinkWrap: true, // Important when inside SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Disable inner scrolling as parent scrolls
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ), // Padding for the grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16, // Spacing between filter items
                mainAxisSpacing: 16,
                childAspectRatio: 0.8, // Adjust aspect ratio to fit text below
              ),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                return _FilterPreviewItem(
                  filterName: filter['name'],
                  imageUrl: filter['imageUrl'],
                );
              },
            ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
    );
  }
}

// Helper widget for a single filter preview item in the grid
class _FilterPreviewItem extends StatelessWidget {
  final String filterName;
  final String imageUrl;

  const _FilterPreviewItem({required this.filterName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              // Handle filter tap
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          filterName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
