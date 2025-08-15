import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/screens/call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // In a real app, add message to a list
      _messageController.clear();
    }
  }

  void _handleCameraTap() {
    // Handle image selection/capture
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        title: Text(
          'Annette Black',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, // Bold
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.call_outlined,
              color: Colors.black,
              size: 24,
            ), // Call icon
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: Colors.black,
              size: 24,
            ), // Video call icon
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(pageBuilder: (_, __, ___) => CallScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.black,
              size: 24,
            ), // Three dots
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: _DateChip(date: 'Today'),
                ),
                const SizedBox(height: 16),
                // Received Post Message
                const _PostMessageBubble(
                  userImageUrl: 'https://picsum.photos/100/100?random=1',
                  username: 'anny_wilson',
                  profession: 'Marketing Coordinator',
                  postImageUrl: 'https://picsum.photos/400/400?random=2',
                  timestamp: '09:59',
                ),
                const SizedBox(height: 8),
                // Received Text Message
                const _MessageBubble(
                  text: 'She is adorable! Don\'t you want to meet her?? 😂',
                  timestamp: '10:00',
                  isSentByMe: false,
                ),
                const SizedBox(height: 8),
                // Sent Text Message
                const _MessageBubble(
                  text:
                      'Please. don\'t make me do it.\nI\'m sure you know my character 😭',
                  timestamp: '10:01',
                  isSentByMe: true,
                ),
                // Add more messages here for scrolling if needed
              ],
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onCameraTap: _handleCameraTap,
          ),
          const SizedBox(height: 8), // Padding below input field
        ],
      ),
    );
  }
}

// Helper widget for the "Today" chip
class _DateChip extends StatelessWidget {
  final String date;

  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7), // Light grey background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        date,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Helper widget for text message bubbles
class _MessageBubble extends StatelessWidget {
  final String text;
  final String timestamp;
  final bool isSentByMe;

  const _MessageBubble({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).primaryColor; // Get primary color from theme
    const Color receivedBubbleColor = Color(0xFFF4F6F7); // Light grey

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // Reduced horizontal padding
        margin: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          left:
              isSentByMe
                  ? 60.0
                  : 0.0, // Reduced padding on left for sent messages
          right:
              isSentByMe
                  ? 0.0
                  : 60.0, // Reduced padding on right for received messages
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.75, // Max width for message bubble
        ),
        decoration: BoxDecoration(
          color:
              isSentByMe
                  ? primaryColor
                  : receivedBubbleColor, // Use primaryColor for sent messages
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isSentByMe
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
            bottomRight:
                isSentByMe
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Wrap content
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: isSentByMe ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timestamp,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isSentByMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for a shared post message bubble
class _PostMessageBubble extends StatelessWidget {
  final String userImageUrl;
  final String username;
  final String profession;
  final String postImageUrl;
  final String timestamp; // Timestamp for the message bubble itself

  const _PostMessageBubble({
    required this.userImageUrl,
    required this.username,
    required this.profession,
    required this.postImageUrl,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    const Color bubbleColor = Color(0xFFF4F6F7); // Light grey background
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        // Reduced horizontal padding
        margin: const EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          left: 0.0,
          right: 60.0, // Reduced padding on right for received post messages
        ),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.85, // Max width for shared post
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Post header (user info)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20, // Smaller avatar for shared post
                  backgroundImage: NetworkImage(userImageUrl),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        profession,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Post Image
            ClipRRect(
              borderRadius: BorderRadius.circular(
                8,
              ), // Rounded corners for post image
              child: Image.network(
                postImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180, // Height for shared image
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            // Timestamp
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timestamp,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the message input field
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCameraTap;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).primaryColor; // Get primary color from theme

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F7), // Light grey background
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: onCameraTap,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          RawMaterialButton(
            onPressed: onSend,
            fillColor: primaryColor, // Use primaryColor for send button
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.send, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
