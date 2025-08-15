import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for activity items
    final List<Map<String, dynamic>> activities = [
      // Today
      {
        'group': 'Today',
        'items': [
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=1',
            'username': 'izabellarodrigues',
            'activityDescription': 'Started following you.',
            'timestamp': '4h',
            'showFollowButton': true,
            'initialFollowing': false,
          },
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=2',
            'username': 'annaclaramm',
            'activityDescription': 'Mentioned you in a comment.',
            'timestamp': '6h',
            'showFollowButton': false,
            'activityAssetUrl': 'https://picsum.photos/100/100?random=3',
          },
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=4',
            'username': 'amandadasilva',
            'activityDescription': 'Started following you.',
            'timestamp': '8h',
            'showFollowButton': true,
            'initialFollowing': true,
          },
        ],
      },
      // Yesterday
      {
        'group': 'Yesterday',
        'items': [
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=5',
            'username': 'marciacristina',
            'activityDescription': 'Mentioned you in a comment.',
            'timestamp': '1d',
            'showFollowButton': false,
            'activityAssetUrl': 'https://picsum.photos/100/100?random=6',
          },
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=7',
            'username': 'alessandroroveronezi',
            'activityDescription': 'Started following you.',
            'timestamp': '1d',
            'showFollowButton': true,
            'initialFollowing': false,
          },
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=8',
            'username': 'gabrielcantarin',
            'activityDescription': 'Mentioned you in a comment.',
            'timestamp': '1d',
            'showFollowButton': false,
            'activityAssetUrl': 'https://picsum.photos/100/100?random=9',
          },
        ],
      },
      // December 22, 2024
      {
        'group': 'December 22, 2024',
        'items': [
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=10',
            'username': 'carolinedias',
            'activityDescription': 'Started following you.',
            'timestamp': '2d',
            'showFollowButton': true,
            'initialFollowing': false,
          },
          {
            'userImageUrl': 'https://picsum.photos/100/100?random=11',
            'username': 'andrebiachi',
            'activityDescription': 'Mentioned you in a comment.',
            'timestamp': '2d',
            'showFollowButton': false,
            'activityAssetUrl': 'https://picsum.photos/100/100?random=12',
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black, // Set icon color to black explicitly
        ),
        title: Text(
          'Activity',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, // Semi-bold as per existing app bars
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz), // Three dots icon
            onPressed: () {
              // Handle more options
            },
            color: Colors.black, // Set icon color to black explicitly
          ),
        ],
        centerTitle: false, // Align title to the left
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        itemCount: activities.length,
        itemBuilder: (context, groupIndex) {
          final group = activities[groupIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupIndex > 0)
                const SizedBox(height: 24), // Add space between groups
              Text(
                group['group'],
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, // Bold for group headers
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16), // Space after group header
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable inner ListView's scrolling
                itemCount: (group['items'] as List).length,
                itemBuilder: (context, itemIndex) {
                  final item = group['items'][itemIndex];
                  return ActivityListItem(
                    userImageUrl: item['userImageUrl'],
                    username: item['username'],
                    activityDescription: item['activityDescription'],
                    timestamp: item['timestamp'],
                    showFollowButton: item['showFollowButton'],
                    initialFollowing: item['initialFollowing'] ?? false,
                    activityAssetUrl: item['activityAssetUrl'],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// A custom widget for a single activity list item
class ActivityListItem extends StatefulWidget {
  final String userImageUrl;
  final String username;
  final String activityDescription;
  final String timestamp;
  final bool
  showFollowButton; // True if this item has a follow/following button
  final bool initialFollowing; // Only relevant if showFollowButton is true
  final String?
  activityAssetUrl; // Only relevant if showFollowButton is false (for mention images)

  const ActivityListItem({
    super.key,
    required this.userImageUrl,
    required this.username,
    required this.activityDescription,
    required this.timestamp,
    this.showFollowButton = false,
    this.initialFollowing = false,
    this.activityAssetUrl,
  });

  @override
  State<ActivityListItem> createState() => _ActivityListItemState();
}

class _ActivityListItemState extends State<ActivityListItem> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialFollowing;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).primaryColor; // Get primary color from theme

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(widget.userImageUrl),
            backgroundColor: Colors.grey[300],
            onBackgroundImageError:
                (exception, stackTrace) =>
                    const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.username,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700, // Bold for username
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: ' ${widget.activityDescription} ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: widget.timestamp,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (widget.showFollowButton)
            _isFollowing
                ? OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isFollowing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor, // Use primary color
                    side: BorderSide(
                      color: primaryColor,
                    ), // Use primary color for border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36), // Ensure consistent height
                  ),
                  child: Text(
                    'Following',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                )
                : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isFollowing = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Use primary color
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36), // Ensure consistent height
                  ),
                  child: Text(
                    'Follow',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                )
          else if (widget.activityAssetUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                8,
              ), // Rounded corners for image
              child: Image.network(
                widget.activityAssetUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: Colors.grey[600]),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
