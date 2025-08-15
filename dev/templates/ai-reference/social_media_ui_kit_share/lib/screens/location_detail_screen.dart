import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/primary_text_button.dart';

class LocationDetailScreen extends StatefulWidget {
  const LocationDetailScreen({super.key});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Top', 'Recent', 'Shorts'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy data for grid items
    final List<Map<String, dynamic>> gridItems = [
      {'imageUrl': 'https://picsum.photos/200/300?random=1', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=2', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=3', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=4', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=5', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=6', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=7', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=8', 'isVideo': false},
      {'imageUrl': 'https://picsum.photos/200/300?random=9', 'isVideo': true},
      {'imageUrl': 'https://picsum.photos/200/300?random=10', 'isVideo': false},
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
          'Location',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz), // More options icon
            onPressed: () {},
            color: Colors.black,
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Info Section
                Row(
                  children: [
                    _CircularLocationIcon(
                      icon: Icons.location_on, // Location icon
                      backgroundColor: primaryColor, // Using primaryColor
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Angelina, Santa Catarina',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'City',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '1,137 posts',
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
                // More Information Button
                PrimaryTextButton(text: "More Information"),
                const SizedBox(height: 24),
                // Map Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Rounded corners for map
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        'https://picsum.photos/600/300?random=200', // Placeholder for map image
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200, // Fixed height for the map
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.map,
                                color: Colors.grey[600],
                                size: 80,
                              ),
                            ),
                      ),
                      Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 40,
                      ), // Location pin on map
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tabs (Segmented Control)
          TabBar(
            controller: _tabController,
            labelColor: primaryColor, // Use primaryColor for selected tab label
            unselectedLabelColor: Colors.grey[600],
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            indicatorColor: primaryColor, // Use primaryColor for indicator
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
          ),
          // TabBarView for content grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  _tabs.map((String tab) {
                    // For simplicity, all tabs show the same grid data.
                    return GridView.builder(
                      padding: const EdgeInsets.all(
                        16.0,
                      ), // Padding around the grid
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio:
                                0.75, // Aspect ratio from SearchScreen
                          ),
                      itemCount: gridItems.length,
                      itemBuilder: (context, index) {
                        final item = gridItems[index];
                        return _LocationGridItem(
                          imageUrl: item['imageUrl'],
                          isVideo: item['isVideo'],
                        );
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget to create the circular icon with a colored background
// Reused from _SearchListItemIcon in search_detail_screen.dart for consistency
class _CircularLocationIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double radius;
  final double iconSize;

  const _CircularLocationIcon({
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.radius = 28, // Default radius for consistency
    this.iconSize = 28, // Default icon size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(child: Icon(icon, color: iconColor, size: iconSize)),
    );
  }
}

// Reused grid item logic from _HashtagGridItem in hashtag_detail_screen.dart
class _LocationGridItem extends StatelessWidget {
  final String imageUrl;
  final bool isVideo;

  const _LocationGridItem({required this.imageUrl, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap on location item
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
                      color: Colors.black.withAlpha(80), // ~0.3 opacity
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
