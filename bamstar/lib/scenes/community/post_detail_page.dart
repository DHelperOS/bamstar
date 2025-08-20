import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:bamstar/scenes/community/community_constants.dart';

class CommunityPostDetailPage extends StatelessWidget {
  final CommunityPost post;
  const CommunityPostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final title = _deriveTitle(post.content);
    final body = _deriveBody(post.content);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('커뮤니티')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              elevation: 0,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Header: avatar + name/company + trailing icon 45x45
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: CommunitySizes.avatarBase * 1.4,
                          backgroundImage: post.isAnonymous || post.authorAvatarUrl == null
                              ? null
                              : NetworkImage(post.authorAvatarUrl!),
                          backgroundColor: post.isAnonymous ? cs.secondaryContainer : null,
                          child: post.isAnonymous ? const Icon(SolarIconsOutline.incognito, size: 22) : null,
                        ),
                        const SizedBox(width: 10),
        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
          Text(post.authorName, style: tt.titleSmall?.copyWith(color: cs.onSurface)),
                              const SizedBox(height: 3),
          Text('Johnson & Johnson', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          height: 45,
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(SolarIconsOutline.menuDots),
                          ),
                        ),
                      ],
                    ),
                    // Two thumbnails row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Thumb(imageUrl: post.imageUrls.isNotEmpty ? post.imageUrls[0] : null),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: _Thumb(imageUrl: post.imageUrls.length > 1 ? post.imageUrls[1] : null),
                          ),
                        ],
                      ),
                    ),
                    // Title 34px width 340
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Text(
                        title.isEmpty ? ' ' : title,
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1.05),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Body paragraph
                    if (body.isNotEmpty)
                      Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(body, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                    ),
                    // Like row
                    Padding(
                      padding: const EdgeInsets.only(top: 20, right: 2),
                      child: Row(
                        children: [
                          const Icon(SolarIconsOutline.heart, color: Colors.red, size: 18),
                          const SizedBox(width: 6),
                          Text('34', style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                        ],
                      ),
                    ),
                    // Comment input
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.46), blurRadius: 2)],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Write a comment',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(SolarIconsOutline.paperclip, size: 21),
                          const SizedBox(width: 10),
                          const Icon(SolarIconsOutline.arrowRight, size: 28),
                        ],
                      ),
                    ),
                    // Comments block
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          _Comment(
                            avatarUrl: 'https://picsum.photos/seed/c1/44/44',
                            name: 'Mitchell',
                            time: '25 minutes ago',
                            text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod.',
                            likes: 18,
                          ),
                          const SizedBox(height: 10),
                          _Comment(
                            avatarUrl: 'https://picsum.photos/seed/c2/44/44',
                            name: 'Robert Fox',
                            time: '3 minutes ago',
                            text: 'Dolor sit ameteiusmod consectetur adipiscing elit.',
                            imageUrl: post.imageUrls.length > 2 ? post.imageUrls[2] : null,
                            likes: 2,
                            withInlineBox: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _deriveTitle(String content) {
  final lines = content.split('\n').where((e) => e.trim().isNotEmpty).toList();
  if (lines.isEmpty) return '';
  final first = lines.first.trim();
  if (first.length > 50) return first.substring(0, 50);
  return first;
}

String _deriveBody(String content) {
  final idx = content.indexOf('\n');
  if (idx <= 0) return '';
  return content.substring(idx + 1).trim();
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  const _Thumb({this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 101,
        child: imageUrl == null
            ? Container(color: Colors.grey[300])
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}

class _Comment extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String time;
  final String text;
  final String? imageUrl;
  final int likes;
  final bool withInlineBox;
  const _Comment({
    required this.avatarUrl,
    required this.name,
    required this.time,
    required this.text,
    this.imageUrl,
    required this.likes,
    this.withInlineBox = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        CircleAvatar(radius: CommunitySizes.avatarBase * 1.6, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: tt.titleSmall?.copyWith(color: cs.onSurface)),
                  const SizedBox(width: 13),
                  Text(time, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 3),
              Text(text, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
              if (imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl!, height: 192, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 2),
                child: Row(
                  children: [
                    const Icon(SolarIconsOutline.heart, color: Colors.red, size: 18),
                    const SizedBox(width: 6),
                    Text('18', style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                    const SizedBox(width: 10),
                    Text('Reply', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (withInlineBox) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: CommunitySizes.avatarBase * 1.6, backgroundImage: NetworkImage(avatarUrl)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.46), blurRadius: 2)],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Expanded(
                              child: Text('Write a comment', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                            ),
                            const SizedBox(width: 10),
                            const Icon(SolarIconsOutline.paperclip, size: 21),
                            const SizedBox(width: 10),
                            const Icon(SolarIconsOutline.arrowRight, size: 28),
                            const SizedBox(width: 8),
                          ],
                        ),
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
