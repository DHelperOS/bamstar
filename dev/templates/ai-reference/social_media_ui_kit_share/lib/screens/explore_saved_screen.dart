import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreSavedScreen extends StatelessWidget {
  const ExploreSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy data for sections
    final List<String> postImages = [
      'https://picsum.photos/200/200?random=13',
      'https://picsum.photos/200/200?random=14',
      'https://picsum.photos/200/200?random=15',
      'https://picsum.photos/200/200?random=16',
      'https://picsum.photos/200/200?random=17',
      'https://picsum.photos/200/200?random=18',
    ];

    final List<String> shortsImages = [
      'https://picsum.photos/120/180?random=19',
      'https://picsum.photos/120/180?random=20',
      'https://picsum.photos/120/180?random=21',
      'https://picsum.photos/120/180?random=22',
      'https://picsum.photos/120/180?random=23',
    ];

    final List<Map<String, dynamic>> audioTracks = [
      {
        'title': 'Angelina',
        'subtitle': 'Lizzy McAlpine',
        'imageUrl': 'https://picsum.photos/100/100?random=24',
      },
      {
        'title': 'Angelina', // Re-using title, assuming it's a popular track
        'subtitle': 'Louis Prima',
        'imageUrl': 'https://picsum.photos/100/100?random=25',
      },
      {
        'title': 'Sunflower',
        'subtitle': 'Post Malone, Swae Lee',
        'imageUrl': 'https://picsum.photos/100/100?random=26',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Saved',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.black,
            ), // Plus icon
            onPressed: () {
              // Handle add action
            },
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Posts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posts',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle see all posts
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  child: Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Important for nested scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0, // Ensures square images
              ),
              itemCount: postImages.length,
              itemBuilder: (context, index) {
                return ImageGridItem(imageUrl: postImages[index]);
              },
            ),

            const SizedBox(height: 32),

            // Shorts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shorts',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle see all shorts
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  child: Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180, // Height of the Shorts cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: shortsImages.length,
                itemBuilder: (context, index) {
                  return ShortsCard(imageUrl: shortsImages[index]);
                },
              ),
            ),

            const SizedBox(height: 32),

            // Audio Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Audio',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle see all audio
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  child: Text(
                    'See All',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Important for nested scrolling
              itemCount: audioTracks.length,
              itemBuilder: (context, index) {
                final track = audioTracks[index];
                return AudioListItem(
                  imageUrl: track['imageUrl'],
                  title: track['title'],
                  subtitle: track['subtitle'],
                  onTap: () {},
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

// Custom SearchTextField adapted from UIKit (not used in this screen but kept for consistency)
class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const CustomSearchTextField({
    super.key,
    this.hintText = 'Search',
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF4F6F7,
        ), // Lighter grey background as per UIKit template
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// Reusable widget for image grid item (for Posts)
class ImageGridItem extends StatelessWidget {
  final String imageUrl;

  const ImageGridItem({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle image tap
          },
          child: Image.network(
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
        ),
      ),
    );
  }
}

// Reusable widget for horizontal image card (for Shorts)
class ShortsCard extends StatelessWidget {
  final String imageUrl;

  const ShortsCard({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Fixed width for shorts cards
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle tap on shorts card
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 180,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable widget for audio list item (adapted from NewsTile)
class AudioListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AudioListItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24, // Smaller circle for audio avatar
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError:
                  (exception, stackTrace) =>
                      const Icon(Icons.music_note, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
