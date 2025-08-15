import 'package:flutter/material.dart';

class ReplayQuestionScreen extends StatefulWidget {
  const ReplayQuestionScreen({super.key});

  @override
  State<ReplayQuestionScreen> createState() => _ReplayQuestionScreenState();
}

class _ReplayQuestionScreenState extends State<ReplayQuestionScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _messageController.clear();
      // Logic to send message and update UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 18,
        ),
        title: Text(
          'Replay Question',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Question Section
                  _buildQuestionHeader(
                    context,
                    'Kai Havertz',
                    'https://picsum.photos/id/237/200/200',
                    '3 days ago',
                    'How to create component?',
                  ),
                  const SizedBox(height: 24),

                  // Answer Section Header
                  Text(
                    'Answer (3)',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of Answers
                  _buildAnswerItem(
                    context,
                    'Guy Hawkins',
                    'https://picsum.photos/id/1005/200/200',
                    true, // isMentor
                    'Hi Kai, you can create component by right click and select create component or by selecting button component on figma navbar.',
                    primaryColor,
                    textTheme,
                  ),
                  Divider(
                    height: 32,
                    thickness: 0.5,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ), // Separator
                  _buildAnswerItem(
                    context,
                    'Ralph Edwards',
                    'https://picsum.photos/id/1009/200/200',
                    false, // not a mentor
                    'How to create variants?',
                    primaryColor,
                    textTheme,
                  ),
                  Divider(
                    height: 32,
                    thickness: 0.5,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ), // Separator
                  _buildAnswerItem(
                    context,
                    'Guy Hawkins',
                    'https://picsum.photos/id/1005/200/200',
                    true, // isMentor
                    'You can create multiple components and rename them to one and the same name. then select "Combine as Variants" on the right.',
                    primaryColor,
                    textTheme,
                  ),
                ],
              ),
            ),
          ),
          // Bottom Input Bar
          _buildBottomInputBar(context, primaryColor, textTheme),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(
    BuildContext context,
    String name,
    String avatarUrl,
    String timeAgo,
    String questionText,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 12),
            Text(
              name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              ' • $timeAgo',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          questionText,
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerItem(
    BuildContext context,
    String name,
    String avatarUrl,
    bool isMentor,
    String answerText,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 12),
            Text(
              name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (isMentor) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.1,
                  ), // Light primary color background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mentor',
                  style: textTheme.bodySmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(
          answerText,
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInputBar(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.sentiment_satisfied_alt,
                    color: Colors.grey[600],
                  ),
                  suffixIcon: Icon(Icons.attach_file, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                  filled: true,
                  fillColor: Colors.grey[100], // Light grey background
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                ),
                onTap: () {
                  // Handle keyboard appearance
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
