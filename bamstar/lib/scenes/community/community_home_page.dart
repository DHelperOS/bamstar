import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:bamstar/scenes/community/create_post_page.dart';
import 'package:bamstar/scenes/community/channel_explorer_page.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:choice/choice.dart';
import 'package:bamstar/scenes/community/community_constants.dart';

class CommunityHomePage extends StatefulWidget {
  const CommunityHomePage({super.key});

  @override
  State<CommunityHomePage> createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage> {
  static const _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  List<CommunityPost> _posts = <CommunityPost>[];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<HashtagChannel> _channels = const [];
  String? _selectedTag; // null = 전체

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMore && !_isLoading) {
          _fetchMore();
        }
      }
    });
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  Future<void> _loadInitial() async {
    _isLoading = true;
    _hasMore = true;
    try {
      final items = await CommunityRepository.instance.fetchFeed(
        filterTag: _selectedTag,
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _posts = items;
        _hasMore = items.length == _pageSize;
      });
    } catch (_) {
      // ignore errors for now
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final items = await CommunityRepository.instance.fetchFeed(
        filterTag: _selectedTag,
        limit: _pageSize,
        offset: _posts.length,
      );
      if (!mounted) return;
      setState(() {
        _posts.addAll(items);
        _hasMore = items.length == _pageSize;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadChannels() async {
    try {
      final res = await CommunityRepository.instance.fetchSubscribedChannels();
      if (!mounted) return;
      setState(() => _channels = res);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: cs.onSurface,
        elevation: 0,
        title: const Text('커뮤니티'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChannelExplorerPage()),
              );
              // 돌아오면 채널/피드 새로고침
              _loadChannels();
              _refresh();
            },
            icon: const Icon(SolarIconsOutline.map),
            tooltip: '채널 탐색',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
          if (created == true) {
            // Refresh after posting
            // ignore: use_build_context_synchronously
            _refresh();
          }
        },
        child: const Icon(SolarIconsOutline.chatRound),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ChannelChips(
                  channels: _channels,
                  selectedTag: _selectedTag,
                  onSelected: (tag) {
                    _selectedTag = tag;
                    // refresh paging controller on filter change
                    _loadInitial();
                  },
                ),
              ),
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Column(
                    children: List.generate(6, (_) => _PostSkeleton(cs: cs)),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index < _posts.length) {
                    final post = _posts[index];
                    return _PostHtmlCard(
                      post: post,
                      onTap: null,
                    );
                  }
                  // loading footer
                  if (_isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }, childCount: _posts.length + (_isLoadingMore ? 1 : 0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostHtmlCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  const _PostHtmlCard({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = _deriveTitle(post.content);
    final body = _deriveBody(post.content);
    // If body is empty but title is very long (DB content with no newline),
    // treat the title as body so it renders at the correct (14) size.
    String displayTitle = title;
    String displayBody = body;
    const int longThreshold = 80;
    if ((displayBody.isEmpty) && displayTitle.length > longThreshold) {
      displayBody = displayTitle;
      displayTitle = '';
    }
    final twoThumbs = post.imageUrls.length >= 2;

    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: CommunitySizes.avatarBase / 2 * 1.4,
                      backgroundColor: post.isAnonymous
                          ? cs.secondaryContainer
                          : null,
                      backgroundImage:
                          post.isAnonymous || post.authorAvatarUrl == null
                          ? null
                          : NetworkImage(post.authorAvatarUrl!),
                      child: post.isAnonymous
                          ? Icon(
                              SolarIconsOutline.incognito,
                              size: CommunitySizes.avatarBase * 0.9,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: tt.titleSmall?.copyWith(color: cs.onSurface),
                          ),
                          Text(
                            _timeAgo(post.createdAt),
                            style: tt.bodySmall?.copyWith(
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
              ),
              // Media section
              if (twoThumbs) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _Thumb(imageUrl: post.imageUrls[0])),
                      const SizedBox(width: 5),
                      Expanded(child: _Thumb(imageUrl: post.imageUrls[1])),
                    ],
                  ),
                ),
              ],
              // Title (only when short or explicitly provided)
              if (displayTitle.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Text(
                      displayTitle,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ),
                ),
              ],
              // Single large image when only one
              if (!twoThumbs && post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.imageUrls.first,
                      height: 202,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              // Body
              if (body.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  child: Text(
                    displayBody,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
              ],
              // Like row
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                child: Row(
                  children: [
                    const Icon(
                      SolarIconsOutline.heart,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(post.id % 50) + 5}',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      SolarIconsOutline.eye,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(post.id % 200) + 50}',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      SolarIconsOutline.chatRound,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.recentCommenterAvatarUrls.length}',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                    const Spacer(),
                    local.AvatarStack(
                      avatarUrls: post.recentCommenterAvatarUrls,
                      avatarSize: CommunitySizes.avatarBase,
                      overlapFactor: 0.5,
                    ),
                  ],
                ),
              ),
              // Comment input (themed)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '댓글 남기기',
                            hintStyle: tt.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        SolarIconsOutline.paperclip,
                        size: 21,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        SolarIconsOutline.arrowRight,
                        size: 24,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 익명 글 좌측 표시 바
    if (post.isAnonymous) {
      return Stack(
        children: [
          card,
          Positioned.fill(
            child: Row(
              children: [
                Container(
                  width: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.secondary,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 0),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      );
    }
    return card;
  }

  String _deriveTitle(String content) {
    final lines = content
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();
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

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return '방금 전';
    if (d.inHours < 1) return '${d.inMinutes}분 전';
    if (d.inDays < 1) return '${d.inHours}시간 전';
    return '${d.inDays}일 전';
  }
}

class _ChannelChips extends StatelessWidget {
  final List<HashtagChannel> channels;
  final String? selectedTag;
  final ValueChanged<String?> onSelected; // null = 전체
  const _ChannelChips({
    required this.channels,
    required this.selectedTag,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Use a sentinel id for the "전체" option so Choice (which expects a non-null
    // value) can represent it. Map the sentinel back to null when calling onSelected.
    const allId = '__ALL__';
    final currentValue = selectedTag ?? allId;

    // If there are no channels, keep original empty message layout.
    if (channels.isEmpty) {
      return SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '구독 채널이 없습니다. 우측 상단 🗺 아이콘으로 탐색해보세요.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: Choice<String>.inline(
        multiple: true,
        value: [currentValue],
        onChanged: (vals) {
          final val = vals.isEmpty ? null : vals.first;
          onSelected(val == allId ? null : val);
        },
        itemCount: channels.length + 1, // first item is '전체'
        itemBuilder: (state, i) {
          final id = i == 0 ? allId : channels[i - 1].name;
          final label = i == 0 ? '전체' : '#${channels[i - 1].name}';
          final isSelected = state.selected(id);
          final csLocal = Theme.of(context).colorScheme;
          return ChoiceChip(
            selected: isSelected,
            onSelected: state.onSelected(id),
            label: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? csLocal.onPrimaryContainer
                    : csLocal.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selectedColor: csLocal.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: csLocal.surface,
            side: BorderSide(
              color: csLocal.outline.withValues(alpha: 28 / 255),
              width: 1,
            ),
          );
        },
        listBuilder: ChoiceList.createWrapped(
          spacing: 8,
          runSpacing: 8,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String imageUrl;
  const _Thumb({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 101,
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _PostSkeleton extends StatelessWidget {
  final ColorScheme cs;
  const _PostSkeleton({required this.cs});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.surfaceContainerHighest,
                  radius: CommunitySizes.avatarBase / 2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 20,
              width: 220,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
