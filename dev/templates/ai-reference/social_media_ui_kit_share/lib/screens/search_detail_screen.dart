import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/search_field.dart';

class SearchDetailScreen extends StatefulWidget {
  const SearchDetailScreen({super.key});

  @override
  State<SearchDetailScreen> createState() => _SearchDetailScreenState();
}

class _SearchDetailScreenState extends State<SearchDetailScreen> {
  final TextEditingController _searchController = TextEditingController(
    text: 'angelina |',
  );

  @override
  void initState() {
    super.initState();
    // Move cursor to the end when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    final List<Map<String, dynamic>> recentSearches = [
      {
        'type': 'user',
        'imageUrl': 'https://picsum.photos/100/100?random=1',
        'title': 'julia_adaline',
        'subtitle': 'Photographer',
      },
      {
        'type': 'location',
        'icon': Icons.location_on,
        'title': 'Los Angeles',
        'subtitle': '1901 Thornridge Cir. Shiloh, 81063',
      },
      {
        'type': 'user',
        'imageUrl': 'https://picsum.photos/100/100?random=2',
        'title': 'sarah_wilona',
        'subtitle': 'Web Designer',
      },
      {
        'type': 'hashtag',
        'icon': Icons.numbers, // Using numbers icon for hashtag
        'title': '#beautifulgirl',
        'subtitle': '447M posts',
      },
      {
        'type': 'general',
        'icon': Icons.search,
        'title': 'Angelina',
        'subtitle': '12M founds',
      },
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 26),
          // Custom Search Bar at the top
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: SearchTextField3(),
          ),
          // Recent Searches Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: recentSearches.length,
              itemBuilder: (context, index) {
                final item = recentSearches[index];
                return _RecentSearchItem(
                  leadingIcon:
                      item['type'] == 'user'
                          ? _SearchListItemIcon(
                            imageUrl: item['imageUrl'],
                            backgroundColor: Colors.transparent,
                            radius: 28,
                          ) // For user avatars
                          : _SearchListItemIcon(
                            icon: item['icon'],
                            backgroundColor: primaryColor,
                            radius: 28,
                          ), // For other icons
                  title: item['title'],
                  subtitle: item['subtitle'],
                  onClear: () {
                    // Implement logic to remove item from list
                  },
                  onTap: () {
                    // Handle navigation to search results
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget to create the circular icon with a colored background
// Adapted from CircularIconBackground in menu_item_tile.dart
class _SearchListItemIcon extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final Color backgroundColor;
  final Color iconColor;
  final double radius;
  final double iconSize;

  const _SearchListItemIcon({
    this.icon,
    this.imageUrl,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.radius = 28, // Default radius for consistency with avatars
    this.iconSize = 24, // Default icon size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        image:
            imageUrl != null &&
                    icon ==
                        null // Display image if imageUrl is provided
                ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          icon != null
              ? Center(child: Icon(icon, color: iconColor, size: iconSize))
              : (imageUrl == null
                  ? Center(
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  )
                  : null), // Fallback icon if no image/icon
    );
  }
}

// Helper widget for a single recent search item
class _RecentSearchItem extends StatelessWidget {
  final Widget leadingIcon; // Can be _SearchListItemIcon or CircleAvatar
  final String title;
  final String subtitle;
  final VoidCallback onClear; // Callback for the 'x' button
  final VoidCallback onTap; // Callback for tapping the item

  const _RecentSearchItem({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onClear,
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
            leadingIcon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, // Semi-bold for titles
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.grey[400],
              ), // Small 'x' icon
              onPressed: onClear,
              splashRadius: 20, // Reduce splash radius for small icon
            ),
          ],
        ),
      ),
    );
  }
}
