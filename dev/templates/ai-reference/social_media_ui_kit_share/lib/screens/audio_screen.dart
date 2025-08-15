import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/primary_text_button.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  bool _isPlaying = false;
  double _currentSliderValue = 0; // Represents progress from 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy data for grid items
    final List<Map<String, dynamic>> gridItems = [
      {'imageUrl': 'https://picsum.photos/200/300?random=1', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=2', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=3', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=4', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=5', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=6', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=7', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=8', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=9', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=10', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=11', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=12', 'isVideo': false},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        title: Text(
          'Audio',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined), // Send/Share icon
            onPressed: () {},
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz), // More options icon
            onPressed: () {},
            color: Colors.black,
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio/Artist Info Section
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/100/100?random=100',
                  ), // Placeholder for audio/artist image
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Angelina',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'lizzymcalpine',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check_circle,
                            color: primaryColor,
                            size: 16,
                          ), // Verified badge using primaryColor
                        ],
                      ),
                      Text(
                        '1,267 shorts',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Save Audio Button
            PrimaryTextButton(text: "Save Audio"),
            const SizedBox(height: 24),
            // Audio Playback Controls
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                  color: primaryColor, // Use primaryColor for play/pause icon
                  iconSize: 40,
                ),
                Expanded(
                  child: Slider(
                    value: _currentSliderValue,
                    max: 1.0,
                    min: 0.0,
                    onChanged: (value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                    activeColor:
                        primaryColor, // Use primaryColor for active slider part
                    inactiveColor:
                        Colors
                            .grey[300], // Lighter grey for inactive slider part
                    thumbColor: primaryColor, // Use primaryColor for thumb
                  ),
                ),
                Text(
                  '01:37', // Dummy duration
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Grid of Short Videos/Images
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable inner scrolling
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75, // Aspect ratio for short videos
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                final item = gridItems[index];
                return _VideoGridItem(
                  imageUrl: item['imageUrl'],
                  isVideo: item['isVideo'],
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

// Adapted ImageGridItem from SearchScreen to show video items
class _VideoGridItem extends StatelessWidget {
  final String imageUrl;
  final bool isVideo;

  const _VideoGridItem({required this.imageUrl, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        8,
      ), // Slightly rounded corners for grid images
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
                  color: Colors.black.withValues(
                    alpha: 0.3,
                  ), // Semi-transparent background for play icon
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
    );
  }
}
