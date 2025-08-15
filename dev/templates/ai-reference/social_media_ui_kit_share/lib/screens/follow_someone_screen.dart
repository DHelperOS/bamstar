import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/primary_text_button.dart';
import 'package:socialPixel/components/search_field.dart';

class FollowSomeoneScreen extends StatelessWidget {
  const FollowSomeoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the list of users
    final List<Map<String, dynamic>> users = [
      {
        'name': 'Jane Cooper',
        'profession': 'Medical Assistant',
        'imageUrl': 'https://picsum.photos/100/100?random=1',
        'following': false,
      },
      {
        'name': 'Wade Warren',
        'profession': 'President of Sales',
        'imageUrl': 'https://picsum.photos/100/100?random=2',
        'following': true,
      },
      {
        'name': 'Jenny Wilson',
        'profession': 'Web Designer',
        'imageUrl': 'https://picsum.photos/100/100?random=3',
        'following': false,
      },
      {
        'name': 'Kristin Watson',
        'profession': 'Dog Trainer',
        'imageUrl': 'https://picsum.photos/100/100?random=4',
        'following': true,
      },
      {
        'name': 'Annette Black',
        'profession': 'Nursing Assistant',
        'imageUrl': 'https://picsum.photos/100/100?random=5',
        'following': true,
      },
      {
        'name': 'Theresa Webb',
        'profession': 'Marketing Coordinator',
        'imageUrl': 'https://picsum.photos/100/100?random=6',
        'following': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ), // Using iOS-style back arrow
          onPressed: () {
            // Handle back button press
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Follow Someone',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, // Extra-bold for title
            fontSize: 20,
            color: Colors.black, // Dark title
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: Stack(
        // Using Stack to place the button at the bottom
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Follow someone you might know or you can skip them too.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                SearchTextField3(),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return FollowListItem(
                        imageUrl: user['imageUrl'],
                        name: user['name'],
                        profession: user['profession'],
                        initialFollowing: user['following'],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100), // Space for the floating button
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PrimaryTextButton(text: "Continue"),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for a single follower list item
class FollowListItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String profession;
  final bool initialFollowing;

  const FollowListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.profession,
    this.initialFollowing = false,
  });

  @override
  State<FollowListItem> createState() => _FollowListItemState();
}

class _FollowListItemState extends State<FollowListItem> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialFollowing;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(widget.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, // Semi-bold for names
                    fontSize: 16,
                    color: Colors.black, // Dark text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.profession,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[600], // Lighter text for profession
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _isFollowing
              ? OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isFollowing = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Following',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
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
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ), // Adjusted padding to match image
                ),
                child: Text(
                  'Follow',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
