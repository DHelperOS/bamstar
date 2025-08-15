import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/screens/inbox_screen.dart';

// Helper widget for a single message request list item
class _MessageRequestItem extends StatelessWidget {
  final String userImageUrl;
  final String username;
  final String messageSnippet;
  final String timestamp;
  final int unreadCount; // Unread count is always present for requests

  const _MessageRequestItem({
    required this.userImageUrl,
    required this.username,
    required this.messageSnippet,
    required this.timestamp,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
        ), // Consistent vertical padding
        child: Row(
          children: [
            CircleAvatar(
              radius:
                  28, // Avatar size consistent with InboxScreen's MessageListItem
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
                  const SizedBox(height: 4), // Space between name and message
                  Text(
                    messageSnippet,
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
                const SizedBox(height: 6), // Space between timestamp and badge
                Container(
                  padding: const EdgeInsets.all(6), // Padding inside the badge
                  decoration: BoxDecoration(
                    color: primaryColor, // Using primaryColor for the badge
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageRequestsScreen extends StatelessWidget {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for message requests
    final List<Map<String, dynamic>> messageRequests = [
      {
        'imageUrl': 'https://picsum.photos/100/100?random=1',
        'username': 'Kathryn Murphy',
        'messageSnippet': 'just ideas for next time',
        'timestamp': '16.47',
        'unreadCount': 3,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=2',
        'username': 'Cody Fisher',
        'messageSnippet': 'perfect!',
        'timestamp': '13.26',
        'unreadCount': 3,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=3',
        'username': 'Jane Cooper',
        'messageSnippet': 'How are you?',
        'timestamp': 'Yesterday',
        'unreadCount': 4,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=4',
        'username': 'Leslie Alexander',
        'messageSnippet': 'Haha that\'s terrifying 😂',
        'timestamp': 'Yesterday',
        'unreadCount': 3,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=5',
        'username': 'Albert Flores',
        'messageSnippet': 'I\'ll be there in 2 mins',
        'timestamp': 'Yesterday',
        'unreadCount': 5,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=6',
        'username': 'Eleanor Pena',
        'messageSnippet': 'aww',
        'timestamp': 'Dec 22. 24',
        'unreadCount': 2,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=7',
        'username': 'Arlene McCoy',
        'messageSnippet': 'Wow, this is really epic',
        'timestamp': 'Dec 22. 24',
        'unreadCount': 4,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=8',
        'username': 'Courtney Henry',
        'messageSnippet': 'Haha that\'s terrifying 😂',
        'timestamp': 'Dec 23. 24',
        'unreadCount': 1,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=9',
        'username': 'Savannah Nguyen',
        'messageSnippet': 'aww',
        'timestamp': 'Dec 24. 24',
        'unreadCount': 1,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=10',
        'username': 'Dianne Russell',
        'messageSnippet': 'Hope you are doing well',
        'timestamp': 'Dec 24. 24',
        'unreadCount': 4,
      },
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
          'Message Requests',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz), // Three dots icon
            onPressed: () {},
            color: Colors.black,
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ), // Reduced vertical padding
        itemCount: messageRequests.length,
        itemBuilder: (context, index) {
          final request = messageRequests[index];
          return _MessageRequestItem(
            userImageUrl: request['imageUrl'],
            username: request['username'],
            messageSnippet: request['messageSnippet'],
            timestamp: request['timestamp'],
            unreadCount: request['unreadCount'],
          );
        },
      ),
    );
  }
}
