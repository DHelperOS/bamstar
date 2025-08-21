import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:bamstar/scenes/community/community_constants.dart';
import 'package:bamstar/services/community/community_repository.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: CommunitySizes.avatarBase / 2,
                  backgroundColor: post.isAnonymous
                      ? cs.secondaryContainer
                      : Colors.transparent,
                  backgroundImage:
                      post.isAnonymous || post.authorAvatarUrl == null
                      ? null
                      : NetworkImage(post.authorAvatarUrl!),
                  child: post.isAnonymous
                      ? Icon(SolarIconsOutline.incognito, size: CommunitySizes.avatarBase * 0.9)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(SolarIconsOutline.menuDots),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrls.first,
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                FutureBuilder<List<String>>(
                  future: CommunityRepository.instance.getPostCommenterAvatars(post.id, limit: 3),
                  builder: (context, snap) {
                    final avatars = (snap.hasData && (snap.data?.isNotEmpty == true))
                        ? snap.data!
                        : post.recentCommenterAvatarUrls;
                    return local.AvatarStack(
                      avatarUrls: avatars,
                      // default to centralized community size
                      avatarSize: CommunitySizes.avatarBase,
                      overlapFactor: 0.5,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '활성 댓글',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(SolarIconsOutline.chatRound),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(SolarIconsOutline.share),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(SolarIconsOutline.bookmark),
                ),
              ],
            ),
            if (post.isAnonymous)
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: cs.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return '방금 전';
    if (d.inHours < 1) return '${d.inMinutes}분 전';
    if (d.inDays < 1) return '${d.inHours}시간 전';
    return '${d.inDays}일 전';
  }
}
