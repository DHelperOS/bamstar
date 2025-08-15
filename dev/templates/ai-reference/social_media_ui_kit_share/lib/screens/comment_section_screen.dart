import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentSectionScreen extends StatefulWidget {
  const CommentSectionScreen({super.key});

  @override
  State<CommentSectionScreen> createState() => _CommentSectionScreenState();
}

class _CommentSectionScreenState extends State<CommentSectionScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_commentController.text.isNotEmpty) {
      // In a real app, you would add the comment to a list/database
      _commentController.clear();
      // Optionally, dismiss keyboard or show success message
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for the original post
    final Map<String, dynamic> originalPost = {
      'userImageUrl': 'https://picsum.photos/100/100?random=1',
      'username': 'anny_wilson',
      'profession': 'Marketing Coordinator',
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'hashtags': [
        '#girl',
        '#girls',
        '#babygirl',
        '#girlpower',
        '#girlswholift',
        '#polishgirl',
        '#girlboss',
        '#girly',
        '#girlfriend',
        '#fitgirl',
        '#birthdaygirl',
        '#instagirl',
        '#girlsnight',
        '#animegirl',
        '#mygirl',
      ],
      'timestamp': '6 hours ago',
      'likes': 44389,
      'commentsCount': 26376,
    };

    // Dummy data for comments
    final List<Map<String, dynamic>> comments = [
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=13',
        'username': 'sarah_brisson',
        'profession': 'Nursing Assistant',
        'commentText': 'So adorable!',
        'timestamp': '5h',
      },
      // Add more dummy comments here if needed for scrolling demonstration
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=14',
        'username': 'john_doe',
        'commentText': 'Love this post!',
        'timestamp': '4h',
      },
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=15',
        'username': 'jane_smith',
        'commentText': 'Inspiring content!',
        'timestamp': '3h',
      },
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=16',
        'username': 'alex_jones',
        'commentText': 'Absolutely fantastic!',
        'timestamp': '2h',
      },
      {
        'userImageUrl': 'https://picsum.photos/100/100?random=17',
        'username': 'emily_white',
        'commentText': 'Great perspective.',
        'timestamp': '1h',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        title: Text(
          'Comments',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined), // Paper plane icon
            onPressed: () {
              // Handle send/share action
            },
            color: Colors.black,
          ),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OriginalPostWidget(
                    userImageUrl: originalPost['userImageUrl'],
                    username: originalPost['username'],
                    profession: originalPost['profession'],
                    content: originalPost['content'],
                    hashtags: originalPost['hashtags'],
                    timestamp: originalPost['timestamp'],
                    likes: originalPost['likes'],
                    commentsCount: originalPost['commentsCount'],
                  ),
                  const SizedBox(height: 20),
                  // List of comments
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Important for nested scrolling
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _CommentListItem(
                        userImageUrl: comment['userImageUrl'],
                        username: comment['username'],
                        profession:
                            comment['profession'] ??
                            '', // Profession might be null for comments
                        commentText: comment['commentText'],
                        timestamp: comment['timestamp'],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Comment Input Section
          _CommentInputWidget(
            currentUserImageUrl:
                'https://picsum.photos/100/100?random=2', // Placeholder for current user's avatar
            commentController: _commentController,
            onPost: _postComment,
          ),
          // The keyboard visual is removed from here.
        ],
      ),
    );
  }
}

// Widget for the original post/content that comments are for
class _OriginalPostWidget extends StatelessWidget {
  final String userImageUrl;
  final String username;
  final String profession;
  final String content;
  final List<String> hashtags;
  final String timestamp;
  final int likes;
  final int commentsCount;

  const _OriginalPostWidget({
    required this.userImageUrl,
    required this.username,
    required this.profession,
    required this.content,
    required this.hashtags,
    required this.timestamp,
    required this.likes,
    required this.commentsCount,
  });

  @override
  Widget build(BuildContext context) {
    const Color hashtagColor = Color(
      0xFF7356FF,
    ); // Primary color for hashtags as per UIKit theme
    const Color likeHeartColor = Color(
      0xFFFF5270,
    ); // Specific pink for heart icon

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(userImageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      profession,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black),
                onPressed: () {
                  // Handle more options
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: Colors.black,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          // Hashtags
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children:
                hashtags
                    .map(
                      (tag) => Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          color: hashtagColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            timestamp,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Likes and Comments
          Row(
            children: [
              Icon(Icons.favorite, color: likeHeartColor, size: 20),
              const SizedBox(width: 4),
              Text(
                likes.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                commentsCount.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget for a single comment item
class _CommentListItem extends StatelessWidget {
  final String userImageUrl;
  final String username;
  final String profession;
  final String commentText;
  final String timestamp;

  const _CommentListItem({
    required this.userImageUrl,
    required this.username,
    required this.profession,
    required this.commentText,
    this.timestamp = 'Just now',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(userImageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Handle comment tap (e.g., reply)
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            username,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timestamp,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        commentText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for the comment input field and button
class _CommentInputWidget extends StatelessWidget {
  final String currentUserImageUrl;
  final TextEditingController commentController;
  final VoidCallback onPost;

  const _CommentInputWidget({
    required this.currentUserImageUrl,
    required this.commentController,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF7356FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(currentUserImageUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primaryColor,
                  width: 1,
                ), // Pink border
              ),
              child: TextField(
                controller: commentController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'So adorable!',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onPost,
            child: Text(
              'Post',
              style: GoogleFonts.plusJakartaSans(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
