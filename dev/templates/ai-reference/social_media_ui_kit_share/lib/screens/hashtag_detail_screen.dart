import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/primary_text_button.dart';

class HashtagDetailScreen extends StatefulWidget {
  const HashtagDetailScreen({super.key});

  @override
  State<HashtagDetailScreen> createState() => _HashtagDetailScreenState();
}

class _HashtagDetailScreenState extends State<HashtagDetailScreen>
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
          '#angelina', // Hashtag title
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
              children: [
                // Hashtag Profile Image
                CircleAvatar(
                  radius: 40, // Larger radius for the hashtag profile image
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/100/100?random=101',
                  ),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Text(
                  '217M posts', // Post count
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                // Follow Button
                PrimaryTextButton(text: "Follow "),
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
                    // In a real app, content would differ based on the tab.
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
                        return _HashtagGridItem(
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

class _HashtagGridItem extends StatelessWidget {
  final String imageUrl;
  final bool isVideo;

  const _HashtagGridItem({required this.imageUrl, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap on hashtag item
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
