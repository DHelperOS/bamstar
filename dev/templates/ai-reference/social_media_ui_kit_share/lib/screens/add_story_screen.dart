import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy gallery images (excluding the camera tile)
    final List<String> galleryImages = [
      'https://picsum.photos/200/300?random=1', // First image in the row
      'https://picsum.photos/200/300?random=2',
      'https://picsum.photos/200/300?random=3',
      'https://picsum.photos/200/300?random=4',
      'https://picsum.photos/200/300?random=5',
      'https://picsum.photos/200/300?random=6',
      'https://picsum.photos/200/300?random=7',
      'https://picsum.photos/200/300?random=8',
      'https://picsum.photos/200/300?random=9',
      'https://picsum.photos/200/300?random=10',
      'https://picsum.photos/200/300?random=11',
      'https://picsum.photos/200/300?random=12',
    ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ), // Black border as per image
            ),
            child: const Icon(
              Icons.close,
              color: Colors.black,
              size: 20,
            ), // Close icon
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Add Story',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 28,
            ), // Settings icon
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true, // Center title as per image
      ),
      body: Column(
        children: [
          // Gallery Controls
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
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
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor, // Use primaryColor for text
                    side: BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ), // Primary color border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Select',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
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
                childAspectRatio: 0.75, // Aspect ratio to match images
              ),
              itemCount: galleryImages.length + 1, // +1 for the camera tile
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Camera Tile
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        // Open camera
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800], // Dark grey for camera tile
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Camera',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Regular gallery images
                  final imageUrl =
                      galleryImages[index -
                          1]; // -1 to get correct image from list
                  return _StoryMediaGridItem(
                    imageUrl: imageUrl,
                    isVideo:
                        index % 3 == 0, // Example: make every 3rd item a video
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Reused grid item logic from _VideoGridItem in audio_screen.dart, adapted for this screen
class _StoryMediaGridItem extends StatelessWidget {
  final String imageUrl;
  final bool isVideo;

  const _StoryMediaGridItem({required this.imageUrl, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // Rounded corners for grid items
      child: Material(
        color: Colors.transparent, // Needed to show underlying image
        child: InkWell(
          onTap: () {
            // Handle tap (open image/video)
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    ),
              ),
              if (isVideo)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80), // 0.3 opacity
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
