import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:bamstar/services/avatar_helper.dart';
import 'package:bamstar/services/image_helper.dart';
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
            // Avatar: if anonymous, show blurred avatar (if available) or placeholder with incognito icon
            SizedBox(
              width: CommunitySizes.avatarBase,
              height: CommunitySizes.avatarBase,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!post.isAnonymous && post.authorAvatarUrl != null)
                    CircleAvatar(
                      radius: CommunitySizes.avatarBase / 2,
                      backgroundImage: avatarImageProviderFromUrl(post.authorAvatarUrl, width: (CommunitySizes.avatarBase).toInt(), height: (CommunitySizes.avatarBase).toInt()),
                    ),
                  if (post.isAnonymous && post.authorAvatarUrl != null)
                    // show blurred avatar image when anonymous
                    ClipOval(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Image(
                          image: avatarImageProviderFromUrl(post.authorAvatarUrl, width: (CommunitySizes.avatarBase).toInt(), height: (CommunitySizes.avatarBase).toInt()),
                          width: CommunitySizes.avatarBase,
                          height: CommunitySizes.avatarBase,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (post.isAnonymous && post.authorAvatarUrl == null)
                    // Show a seeded placeholder image and blur it instead of an icon
                    ClipOval(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Image.network(
                          'https://picsum.photos/seed/anon${post.id}/100/100',
                          width: CommunitySizes.avatarBase,
                          height: CommunitySizes.avatarBase,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.isAnonymous ? '익명의 스타' : post.authorName,
                                  style: Theme.of(context).textTheme.labelLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (post.isAnonymous) ...[
                                const SizedBox(width: 8),
                                Container(
                                  constraints: const BoxConstraints(minWidth: 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: cs.primary, width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('익명', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ],
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
                child: CloudinaryImage(
                  post.imageUrls.first,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: Container(color: Colors.grey[300], height: 180),
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
            // anonymous indicator bar removed per design request
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
