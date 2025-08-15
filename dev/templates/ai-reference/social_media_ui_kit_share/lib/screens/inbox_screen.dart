import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/search_field.dart';
import 'package:socialPixel/screens/chat_screen.dart';
import 'package:socialPixel/screens/feed_screen.dart';
import 'package:socialPixel/screens/message_requests_screen.dart';

// Reusing CustomSearchTextField from earlier tasks
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

class _RecentlyAvatar extends StatefulWidget {
  final String imageUrl;
  final String username;
  final Color primaryColor;

  const _RecentlyAvatar({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.primaryColor,
  });

  @override
  State<_RecentlyAvatar> createState() => __RecentlyAvatarState();
}

class __RecentlyAvatarState extends State<_RecentlyAvatar> {
  bool showBorder = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                setState(() {
                  showBorder = !showBorder;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      showBorder
                          ? Border.all(color: widget.primaryColor, width: 2.0)
                          : null,
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(widget.imageUrl),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.username,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// New widget for a single message list item
class _MessageListItem extends StatelessWidget {
  final String userImageUrl;
  final String username;
  final String lastMessage;
  final String timestamp;
  final int? unreadCount; // Optional unread message count

  const _MessageListItem({
    required this.userImageUrl,
    required this.username,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(PageRouteBuilder(pageBuilder: (_, __, ___) => ChatScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(userImageUrl),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, // Bold for username
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
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
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timestamp,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (unreadCount != null && unreadCount! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            primaryColor, // Using primaryColor for unread badge
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    final List<Map<String, dynamic>> recentlyActive = [
      {
        'imageUrl': 'https://picsum.photos/100/100?random=1',
        'username': 'Julia',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=2',
        'username': 'Jenny',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=3',
        'username': 'Andrew',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=4',
        'username': 'Sarah',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=5',
        'username': 'Kevin',
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=6',
        'username': 'Alice',
      },
    ];

    final List<Map<String, dynamic>> messages = [
      {
        'imageUrl': 'https://picsum.photos/100/100?random=7',
        'username': 'Annette Black',
        'lastMessage': 'Message',
        'timestamp': '20:00',
        'unreadCount': 3,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=8',
        'username': 'Wade Warren',
        'lastMessage': 'perfect!',
        'timestamp': '16:20',
        'unreadCount': 3,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=9',
        'username': 'Jenny Wilson',
        'lastMessage': 'How are you?',
        'timestamp': 'Yesterday',
        'unreadCount': null,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=10',
        'username': 'Theresa Webb',
        'lastMessage': 'Haha that\'s terrifying 😂',
        'timestamp': 'Yesterday',
        'unreadCount': null,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=11',
        'username': 'Brooklyn Simmons',
        'lastMessage': 'I\'ll be there in 2 mins',
        'timestamp': 'Yesterday',
        'unreadCount': null,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=12',
        'username': 'Robert Fox',
        'lastMessage': 'aww',
        'timestamp': 'Dec 22. 24',
        'unreadCount': null,
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
          color: Colors.black,
        ),
        title: Text(
          'Inbox',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Add icon
            onPressed: () {},
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined), // Video icon
            onPressed: () {},
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz), // More icon
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
            SearchTextField3(controller: TextEditingController()),
            const SizedBox(height: 24),
            Text(
              'Recently',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100, // Height for avatars and names
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyActive.length,
                itemBuilder: (context, index) {
                  final user = recentlyActive[index];
                  return _RecentlyAvatar(
                    imageUrl: user['imageUrl'],
                    username: user['username'],
                    primaryColor: primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 16), // Reduced from 24 to 16
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MessageRequestsScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        primaryColor, // Using primaryColor for "Requests"
                  ),
                  child: Text(
                    'Requests',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable inner scrolling
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _MessageListItem(
                  userImageUrl: message['imageUrl'],
                  username: message['username'],
                  lastMessage: message['lastMessage'],
                  timestamp: message['timestamp'],
                  unreadCount: message['unreadCount'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
