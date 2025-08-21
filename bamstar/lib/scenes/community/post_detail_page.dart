import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

// Simple post detail page replacement. Keeps layout minimal and focused on
// the comment UI: top comment input (like community_home_page) and a
// vertically scrolling comment list with nested replies.

class CommunityPostDetailPage extends StatelessWidget {
  // Minimal contract: caller provides a title and optional image urls.
  final String title;
  final String body;
  const CommunityPostDetailPage({super.key, required this.title, this.body = ''});

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final tt = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('커뮤니티')),
      body: SafeArea(
        child: Column(
          children: [
            // Top comment input (sticky-like) — visually matches community_home_page
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write a comment',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                        ),
                        style: tt.bodyMedium,
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(SolarIconsOutline.paperclip)),
                    IconButton(onPressed: () {}, icon: const Icon(SolarIconsOutline.arrowRight, size: 28)),
                  ],
                ),
              ),
            ),

            // Comments list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Example comments rendered to match screenshot layout
                    _CommentItem(
                      avatarUrl: 'https://i.pravatar.cc/100?img=32',
                      name: 'Esther Howard',
                      time: '25 minutes ago',
                      text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod.',
                      likes: 18,
                    ),
                    const SizedBox(height: 10),
                    _CommentItem(
                      avatarUrl: 'https://i.pravatar.cc/100?img=12',
                      name: 'Jerome Bell',
                      time: '3 minutes ago',
                      text: 'Dolor sit ameteiusmod consectetur adipiscing elit.',
                      likes: 2,
                      replies: [
                        _Reply(
                          avatarUrl: 'https://i.pravatar.cc/100?img=5',
                          name: 'Eleanor Pena',
                          time: '15 minutes ago',
                          text: 'Dolor sit ameteiusmod consectetur.',
                          likes: 6,
                        ),
                        _Reply(
                          avatarUrl: 'https://i.pravatar.cc/100?img=8',
                          name: 'Kristin Watson',
                          time: '12 minutes ago',
                          text: 'Dolor sit ameteiusmod consectetur.',
                          likes: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _CommentItem(
                      avatarUrl: 'https://i.pravatar.cc/100?img=50',
                      name: 'Ronald Richards',
                      time: '15 minutes ago',
                      text: 'Dolor sit ameteiusmod.',
                      likes: 0,
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14)),
                        child: const Text('Show more comments'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String time;
  final String text;
  final int likes;
  final List<_Reply>? replies;
  const _CommentItem({required this.avatarUrl, required this.name, required this.time, required this.text, required this.likes, this.replies});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(name, style: tt.titleSmall)),
                  Text(time, style: tt.bodySmall),
                ],
              ),
              const SizedBox(height: 6),
              Text(text, style: tt.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(SolarIconsOutline.heart, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Text('$likes', style: tt.bodyMedium),
                  const SizedBox(width: 12),
                  Text('Reply', style: tt.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
              if (replies != null && replies!.isNotEmpty) ...[
                const SizedBox(height: 12),
                // simple vertical line + replies column
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 16),
                    Container(width: 1, height: 80, color: Colors.grey.withOpacity(0.25)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: replies!.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReplyItem(reply: r),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Reply {
  final String avatarUrl;
  final String name;
  final String time;
  final String text;
  final int likes;
  _Reply({required this.avatarUrl, required this.name, required this.time, required this.text, required this.likes});
}

class _ReplyItem extends StatelessWidget {
  final _Reply reply;
  const _ReplyItem({required this.reply});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 14, backgroundImage: NetworkImage(reply.avatarUrl)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(reply.name, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                  Text(reply.time, style: tt.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              Text(reply.text, style: tt.bodySmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(SolarIconsOutline.heart, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Text('${reply.likes}', style: tt.bodySmall),
                  const SizedBox(width: 10),
                  Text('Reply', style: tt.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

