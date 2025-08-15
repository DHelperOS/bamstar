import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/screens/filter_screen.dart';

class NewPostGalleryScreen extends StatefulWidget {
  const NewPostGalleryScreen({super.key});

  @override
  State<NewPostGalleryScreen> createState() => _NewPostGalleryScreenState();
}

class _NewPostGalleryScreenState extends State<NewPostGalleryScreen> {
  String _selectedImageUrl =
      'https://picsum.photos/400/500?random=1'; // Initial selected image
  final Set<String> _selectedGridImages = {
    'https://picsum.photos/400/500?random=1',
  }; // Track selected grid images

  // Dummy gallery images
  final List<String> _galleryImages = [
    'https://picsum.photos/400/500?random=1',
    'https://picsum.photos/400/500?random=2',
    'https://picsum.photos/400/500?random=3',
    'https://picsum.photos/400/500?random=4',
    'https://picsum.photos/400/500?random=5',
    'https://picsum.photos/400/500?random=6',
    'https://picsum.photos/400/500?random=7',
    'https://picsum.photos/400/500?random=8',
    'https://picsum.photos/400/500?random=9',
    'https://picsum.photos/400/500?random=10',
    'https://picsum.photos/400/500?random=11',
    'https://picsum.photos/400/500?random=12',
  ];

  void _handleImageSelected(String imageUrl, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedImageUrl = imageUrl;
        _selectedGridImages.clear(); // Only allow one selection for now
        _selectedGridImages.add(imageUrl);
      } else {
        _selectedGridImages.remove(imageUrl);
        // Logic to select another image if current one is deselected (if multiple selection is allowed)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close), // Close/Cancel icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        title: Text(
          'New Post',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: primaryColor,
            ), // Forward arrow icon
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(pageBuilder: (_, __, ___) => FilterScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true, // Center title as per image
      ),
      body: Column(
        children: [
          // Main Image Preview
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                16,
              ), // Rounded corners for preview
              child: Image.network(
                _selectedImageUrl,
                fit: BoxFit.cover,
                height: 350, // Fixed height for preview
                width: double.infinity,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 350,
                      width: double.infinity,
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
          // Gallery Controls
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Show album/source selection
                  },
                  child: Row(
                    children: [
                      Text(
                        'Gallery',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.apps_outlined,
                        color: Colors.black,
                        size: 28,
                      ), // Grid view icon
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                        size: 28,
                      ), // Camera icon
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Image Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ), // Padding for grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0, // Square images
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                final imageUrl = _galleryImages[index];
                return _GalleryGridItem(
                  imageUrl: imageUrl,
                  initialSelected: _selectedGridImages.contains(imageUrl),
                  onSelected:
                      (isSelected) =>
                          _handleImageSelected(imageUrl, isSelected),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper for image grid items with selection state
class _GalleryGridItem extends StatefulWidget {
  final String imageUrl;
  final bool initialSelected;
  final ValueChanged<bool>? onSelected;

  const _GalleryGridItem({
    required this.imageUrl,
    this.initialSelected = false,
    this.onSelected,
  });

  @override
  __GalleryGridItemState createState() => __GalleryGridItemState();
}

class __GalleryGridItemState extends State<_GalleryGridItem> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onSelected?.call(_isSelected);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          8,
        ), // Rounded corners for grid images
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
            ),
            if (_isSelected)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.3,
                  ), // Dark overlay when selected
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded, // Filled checkmark icon
                      color: primaryColor, // Primary color for the checkmark
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
