import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'dart:ui';
import 'package:bamstar/services/avatar_helper.dart';
// 'choice' package no longer needed here; chips are rendered manually.
import 'package:bamstar/services/user_service.dart' as us;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:visibility_detector/visibility_detector.dart';
// removed drop_down_search_field dependency: use plain TextField for search
import 'package:bamstar/scenes/community/create_post_page.dart';
import 'package:bamstar/scenes/community/channel_explorer_page.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:bamstar/scenes/community/community_constants.dart';

class CommunityHomePage extends StatefulWidget {
  const CommunityHomePage({super.key});

  @override
  State<CommunityHomePage> createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage>
    with SingleTickerProviderStateMixin {
  static const _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  List<CommunityPost> _posts = <CommunityPost>[];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<HashtagChannel> _channels = const [];
  String? _selectedTag;
  bool _hasMore = true;
  final JustTheController _tooltipController = JustTheController();
  // Search field (toggled by AppBar search button)
  bool _showSearch = false;
  bool _showSort = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _contentQuery;
  late TabController _tabController;
  int _selectedTabIndex = 0; // 0은 "전체"를 의미
  bool _tabControllerInitialized = false;
  SortMode _selectedSort = SortMode.latest;

  int get _totalTabCount => 1 + _channels.length + 1; // "전체" + 채널들 + "+"

  // Sort window for popularity/likes (1 week)
  static final Duration _oneWeek = const Duration(days: 7);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 채널 개수 + "전체" + "+" 탭으로 TabController 초기화
    _tabController = TabController(
      length: 2, // 기본적으로 "전체" + "+"로 시작 (채널은 로드 후 갱신)
      vsync: this,
      initialIndex: 0, // "전체"가 기본 선택
    );
    _tabControllerInitialized = true;
    _loadChannels();
    _loadInitial();
    // update UI when search text changes so suffixIcon (clear) shows/hides
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    // Auto-show tooltip after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // show with a tiny delay to ensure layout is ready
      Future.delayed(const Duration(milliseconds: 50), () {
        _tooltipController.showTooltip();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // TabController가 초기화되었고 아직 dispose되지 않았다면 dispose
    if (_tabControllerInitialized) {
      try {
        _tabController.dispose();
      } catch (_) {
        // 이미 dispose된 경우 무시
      }
    }
    // dispose search controller and focus node
    try {
      _searchController.dispose();
    } catch (_) {}
    try {
      _searchFocusNode.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _fetchMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _posts = [];
      _hasMore = true;
    });
    try {
      final items = await CommunityRepository.instance.fetchFeed(
        filterTag: _selectedTag,
        contentQuery: _contentQuery,
        limit: _pageSize,
        sortMode: _selectedSort,
        window: (_selectedSort == SortMode.latest) ? null : _oneWeek,
        offset: 0,
      );
      _posts = items;
      _hasMore = items.length == _pageSize;
      await _prefetchAuthors(items);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final items = await CommunityRepository.instance.fetchFeed(
        filterTag: _selectedTag,
        contentQuery: _contentQuery,
        limit: _pageSize,
        offset: _posts.length,
        sortMode: _selectedSort,
        window: (_selectedSort == SortMode.latest) ? null : _oneWeek,
      );
      _posts = List.of(_posts)..addAll(items);
      _hasMore = items.length == _pageSize;
      await _prefetchAuthors(items);
      if (mounted) setState(() {});
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onTabChanged(int index) {
    // If the '+' tab was tapped, navigate to ChannelExplorer.
    if (index == _totalTabCount - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChannelExplorerPage()),
      );
      return;
    }

    // Defensive guards: ignore invalid indices.
    if (index < 0) return;

    if (index == 0) {
      // "전체"
      setState(() {
        _selectedTabIndex = 0;
        _selectedTag = null;
        _contentQuery = null;
      });
      _loadInitial();
      return;
    }

    final chanIdx = index - 1;
    if (chanIdx >= 0 && chanIdx < _channels.length) {
      setState(() {
        _selectedTabIndex = index;
        _selectedTag = _channels[chanIdx].name;
        _contentQuery = null;
      });
      _loadInitial();
      return;
    }

    // Index didn't match any valid tab (race condition), ignore.
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  Future<void> _loadChannels() async {
    try {
      final res = await CommunityRepository.instance.fetchSubscribedChannels();
      if (!mounted) return;
      setState(() {
        _channels = res;
        // 채널이 변경되면 TabController를 완전히 재생성
        _recreateTabController();
      });
    } catch (_) {
      // ignore
    }
  }

  void _recreateTabController() {
    if (_tabControllerInitialized) {
      final oldController = _tabController;
      // 새로운 TabController 생성
      // Ensure length is at least 1 (there is always the "전체" tab)
      final newLength = _totalTabCount <= 0 ? 1 : _totalTabCount;
      // Safely clamp the selected index to [0, newLength - 1]
      int newIndex = _selectedTabIndex;
      final maxIndex = newLength - 1;
      if (newIndex < 0) newIndex = 0;
      if (newIndex > maxIndex) newIndex = maxIndex;

      _tabController = TabController(
        length: newLength,
        vsync: this,
        initialIndex: newIndex,
      );
      // 다음 프레임에서 이전 컨트롤러 dispose
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          oldController.dispose();
        } catch (_) {
          // 이미 dispose된 경우 무시
        }
      });
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
        actions: <Widget>[
          JustTheTooltip(
            controller: _tooltipController,
            preferredDirection: AxisDirection.down,
            isModal: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            tailLength: 10,
            tailBaseWidth: 14,
            margin: const EdgeInsets.only(right: 8),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  '채널을 구독하고'
                  '\n 스타들과 소통해요 ',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChannelExplorerPage(),
                  ),
                );
                _loadChannels();
                _refresh();
              },
              icon: const Icon(SolarIconsOutline.pin),
              tooltip: '채널 탐색',
            ),
          ),
          IconButton(
            onPressed: () {
              final next = !_showSearch;
              setState(() => _showSearch = next);
              if (next) {
                Future.delayed(const Duration(milliseconds: 50), () {
                  try {
                    FocusScope.of(context).requestFocus(_searchFocusNode);
                  } catch (_) {}
                });
              }
            },
            icon: const Icon(SolarIconsOutline.magnifier),
            tooltip: '검색',
          ),
          IconButton(
            onPressed: () {
              final next = !_showSort;
              setState(() => _showSort = next);
            },
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 12),
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
            controller: _scrollController,
            slivers: [
              // Search input (togglable) - moved above the tab bar so it appears
              // visually above tabs as requested.
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              focusNode: _searchFocusNode,
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: '게시물 내용으로 검색',
                                prefixIcon: const Icon(
                                  SolarIconsOutline.magnifier,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isEmpty
                                    ? null
                                    : IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        icon: const Icon(Icons.clear, size: 16),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _contentQuery = null;
                                          });
                                        },
                                      ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(
                                    color: cs.outlineVariant.withValues(
                                      alpha: 0.12,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(
                                    color: cs.outlineVariant.withValues(
                                      alpha: 0.10,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                filled: true,
                                fillColor: cs.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (v) {
                                final text = v.trim();
                                setState(() {
                                  _contentQuery = text.isEmpty ? null : text;
                                  _selectedTag = null;
                                  _selectedTabIndex = 0;
                                  _showSearch = false;
                                });
                                FocusScope.of(context).unfocus();
                                _loadInitial();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // search button sized to match input height
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              final text = _searchController.text.trim();
                              setState(() {
                                _contentQuery = text.isEmpty ? null : text;
                                _selectedTag = null;
                                _selectedTabIndex = 0;
                                _showSearch = false;
                              });
                              FocusScope.of(context).unfocus();
                              _loadInitial();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              elevation: 0,
                            ),
                            child: const Text('검색'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _showSearch
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                ),
              ),
              // Tab bar moved below search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _ChannelTabBar(
                    controller: _tabController,
                    channels: _channels,
                    onTap: _onTabChanged,
                  ),
                ),
              ),
              // Sort choice chips: 최신 순(default), 인기 순(주간 댓글수), 좋아요 순(주간 좋아요수)
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(3, (i) {
                          final labels = ['최신 순', '인기 순', '좋아요순'];
                          final csLocal = Theme.of(context).colorScheme;
                          final double smallFont = 12.0;
                          final SortMode mode = (i == 0)
                              ? SortMode.latest
                              : (i == 1 ? SortMode.popular : SortMode.liked);
                          final bool isSelected = _selectedSort == mode;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              selected: false,
                              onSelected: (_) {
                                if (mode != _selectedSort) {
                                  setState(() {
                                    _selectedSort = mode;
                                  });
                                  _loadInitial();
                                }
                              },
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    Icon(
                                      Icons.check,
                                      size: (smallFont - 2).clamp(8.0, 12.0),
                                      color: csLocal.onPrimary,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(labels[i]),
                                ],
                              ),
                              selectedColor: csLocal.primary,
                              backgroundColor: isSelected
                                  ? csLocal.primary
                                  : csLocal.surface.withValues(alpha: 0.06),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              labelStyle: TextStyle(
                                fontSize: smallFont,
                                color: isSelected
                                    ? csLocal.onPrimary
                                    : csLocal.onSurface.withOpacity(0.8),
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? csLocal.primary
                                    : csLocal.outlineVariant.withValues(alpha: 0.06),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  crossFadeState: _showSort ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                ),
              ),
              // Removed the empty-subscriptions helper message per request.
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
                      onHashtagTap: (tag) {
                        // parent handles hashtag taps: set as content query and reload
                        setState(() {
                          _contentQuery = tag;
                          _selectedTag = null;
                          _selectedTabIndex = 0;
                          _showSearch = false;
                        });
                        _searchController.text = tag;
                        _loadInitial();
                      },
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

// Simple in-memory cache for author lookups to avoid refetching repeatedly.
final Map<String, us.AppUser?> _authorCache = {};

Future<us.AppUser?> _getAuthor(String? id) async {
  if (id == null) return null;
  if (_authorCache.containsKey(id)) return _authorCache[id];
  try {
    debugPrint('[community] _getAuthor: fetching user id=$id');
    final client = Supabase.instance.client;
    final res = await client
        .from('users')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    if (res != null) {
      final row = Map<String, dynamic>.from(res as Map);
      final u = us.AppUser.fromMap(row);
      debugPrint(
        '[community] _getAuthor: fetched user id=${u.id} nickname=${u.nickname}',
      );
      _authorCache[id] = u;
      return u;
    }
  } catch (_) {
    // ignore
  }
  _authorCache[id] = null;
  debugPrint('[community] _getAuthor: no user found for id=$id');
  return null;
}

/// Batch prefetch authors for a list of posts. Populates the top-level
/// `_authorCache` to avoid repeated single-row queries per card.
Future<void> _prefetchAuthors(List<CommunityPost> posts) async {
  try {
    final ids = posts
        .map((p) => p.authorId)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .where((id) => !_authorCache.containsKey(id))
        .toList();
    if (ids.isEmpty) return;
    debugPrint('[community] _prefetchAuthors: will fetch ids=${ids.join(',')}');
    final client = Supabase.instance.client;
    final idsCsv = ids.map((s) => '"$s"').join(',');
    final res = await client
        .from('users')
        .select('*')
        .filter('id', 'in', '($idsCsv)');
    final List data = res as List? ?? [];
    debugPrint('[community] _prefetchAuthors: fetched ${data.length} rows');
    for (final row in data) {
      try {
        final m = Map<String, dynamic>.from(row as Map);
        final u = us.AppUser.fromMap(m);
        _authorCache[u.id] = u;
      } catch (_) {
        // ignore malformed rows
      }
    }
    // mark missing ids as null to avoid requerying
    for (final id in ids) {
      if (!_authorCache.containsKey(id)) _authorCache[id] = null;
    }
  } catch (_) {
    // ignore network errors
  }
}

// Build a widget that renders text and turns hashtags into subtle tappable chips
Widget _buildContentWithHashtags(
  String text,
  TextStyle? style,
  ColorScheme cs,
  ValueChanged<String>? onHashtagTap,
) {
  final tStyle = style ?? const TextStyle();
  final regex = RegExp(r'(#[^\s#]+)');
  final parts = <InlineSpan>[];
  int lastEnd = 0;
  for (final match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      parts.add(
        TextSpan(text: text.substring(lastEnd, match.start), style: tStyle),
      );
    }
    final tag = match.group(0)!;

    // make chips slightly larger than before for readability while staying subtle
    final double baseFont = tStyle.fontSize ?? 14.0;
    final tagStyle = tStyle.copyWith(
      fontSize: (baseFont - 2).clamp(11.0, baseFont),
      color: cs.onSurface, // clearer on the surface
      fontWeight: FontWeight.normal,
    );

    parts.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.only(right: 6, left: 2),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onHashtagTap == null ? null : () => onHashtagTap(tag),
              splashFactory: InkRipple.splashFactory,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(tag, style: tagStyle),
              ),
            ),
          ),
        ),
      ),
    );

    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    parts.add(TextSpan(text: text.substring(lastEnd), style: tStyle));
  }

  return RichText(
    text: TextSpan(children: parts, style: tStyle),
  );
}

class _PostHtmlCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final ValueChanged<String>? onHashtagTap;
  const _PostHtmlCard({required this.post, this.onTap, this.onHashtagTap});

  @override
  State<_PostHtmlCard> createState() => _PostHtmlCardState();
}

class _PostHtmlCardState extends State<_PostHtmlCard> {
  late CommunityPost post;
  bool _isLiking = false;
  // VisibilityDetector will manage per-card visibility; use a unique key per card
  bool _didIncrementView = false;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    // schedule a post-frame visibility check
    // VisibilityDetector will trigger view increment when appropriate.
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() => _isLiking = true);
    final wasLiked = post.isLiked;
    final oldLikes = post.likesCount;
    // optimistic update
    setState(
      () => post = CommunityPost(
        id: post.id,
        content: post.content,
        isAnonymous: post.isAnonymous,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatarUrl: post.authorAvatarUrl,
        imageUrls: post.imageUrls,
        createdAt: post.createdAt,
        hashtags: post.hashtags,
        recentCommenterAvatarUrls: post.recentCommenterAvatarUrls,
        likesCount: wasLiked ? (post.likesCount - 1) : (post.likesCount + 1),
        viewCount: post.viewCount,
        commentCount: post.commentCount,
        isLiked: !wasLiked,
      ),
    );

    bool success;
    if (!wasLiked) {
      success = await CommunityRepository.instance.likePost(postId: post.id);
    } else {
      success = await CommunityRepository.instance.unlikePost(postId: post.id);
    }

    if (!success) {
      // rollback
      setState(
        () => post = CommunityPost(
          id: post.id,
          content: post.content,
          isAnonymous: post.isAnonymous,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatarUrl: post.authorAvatarUrl,
          imageUrls: post.imageUrls,
          createdAt: post.createdAt,
          hashtags: post.hashtags,
          recentCommenterAvatarUrls: post.recentCommenterAvatarUrls,
          likesCount: oldLikes,
          viewCount: post.viewCount,
          commentCount: post.commentCount,
          isLiked: wasLiked,
        ),
      );
    }

    if (mounted) setState(() => _isLiking = false);
  }

  // Visibility is handled by VisibilityDetector per-card below.

  @override
  void didUpdateWidget(covariant _PostHtmlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if the parent supplied a new post, adopt it
    if (widget.post.id != post.id) {
      post = widget.post;
      // reset per-card increment flag for the new post
      _didIncrementView = false;
    }
  }

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
                    FutureBuilder<us.AppUser?>(
                      future: _getAuthor(post.authorId),
                      builder: (context, snap) {
                        final user = snap.data;
                        // Determine an ImageProvider for the avatar. Prefer user's
                        // stored profile image when available; otherwise fallback to
                        // the post.authorAvatarUrl. For anonymous posts we still
                        // want a network image (seeded placeholder) so the UI can
                        // render it blurred instead of replacing with an icon.
                        String? candidateUrl;
                        if (user != null) {
                          final p = (user.data['profile_img'] as String?)
                              ?.trim();
                          if (p != null && p.isNotEmpty) candidateUrl = p;
                        }
                        candidateUrl ??= post.authorAvatarUrl;
                        // For anonymous posts we avoid fetching external placeholder
                        // images (picsum) because they can fail or be blocked.
                        // Instead, if no avatar URL is available we will render a
                        // locally colored circle with an icon and blur it so the
                        // UI still conveys anonymity without network requests.
                        if (post.isAnonymous &&
                            (candidateUrl == null || candidateUrl.isEmpty)) {
                          candidateUrl =
                              null; // explicit: do not fetch external placeholder
                        }

                        ImageProvider? avatarImage;
                        if (candidateUrl != null && candidateUrl.isNotEmpty) {
                          // Use centralized helper which handles Cloudinary and
                          // network images uniformly.
                          avatarImage = avatarImageProviderFromUrl(
                            candidateUrl,
                            width: (CommunitySizes.avatarBase * 2.8).toInt(),
                            height: (CommunitySizes.avatarBase * 2.8).toInt(),
                          );
                        }

                        // If anonymous and we have an image, render it blurred.
                        if (post.isAnonymous && avatarImage != null) {
                          return SizedBox(
                            width: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                            height: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                            child: ClipOval(
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 8,
                                  sigmaY: 8,
                                ),
                                child: Image(
                                  image: avatarImage,
                                  width:
                                      CommunitySizes.avatarBase / 2 * 1.4 * 2,
                                  height:
                                      CommunitySizes.avatarBase / 2 * 1.4 * 2,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }

                        // If anonymous and no remote image is available, render a
                        // locally colored circle with an icon and blur it. This
                        // avoids external mock network calls while keeping the
                        // anonymized visual treatment.
                        if (post.isAnonymous && avatarImage == null) {
                          return SizedBox(
                            width: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                            height: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                            child: ClipOval(
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 8,
                                  sigmaY: 8,
                                ),
                                child: Container(
                                  width:
                                      CommunitySizes.avatarBase / 2 * 1.4 * 2,
                                  height:
                                      CommunitySizes.avatarBase / 2 * 1.4 * 2,
                                  color: cs.secondaryContainer,
                                  child: Center(
                                    child: Icon(
                                      SolarIconsOutline.incognito,
                                      size: CommunitySizes.avatarBase * 0.9,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Fallback: non-anonymous or image available — use CircleAvatar
                        return CircleAvatar(
                          radius: CommunitySizes.avatarBase / 2 * 1.4,
                          backgroundColor: post.isAnonymous
                              ? cs.secondaryContainer
                              : null,
                          backgroundImage: avatarImage,
                          child: (!post.isAnonymous && avatarImage == null)
                              ? null
                              : (post.isAnonymous && avatarImage == null
                                    ? null
                                    : null),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<us.AppUser?>(
                            future: _getAuthor(post.authorId),
                            builder: (context, snap) {
                              final user = snap.data;
                              final name = post.isAnonymous
                                  ? post.authorName
                                  : (user?.nickname.isNotEmpty == true
                                        ? user!.nickname
                                        : post.authorName);
                              return Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: tt.titleSmall?.copyWith(
                                        color: cs.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (post.isAnonymous) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: cs.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '익명',
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
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
                    child: _buildContentWithHashtags(
                      displayTitle,
                      tt.bodyMedium?.copyWith(color: cs.onSurface),
                      cs,
                      widget.onHashtagTap,
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
                  child: _buildContentWithHashtags(
                    displayBody,
                    tt.bodyMedium?.copyWith(color: cs.onSurface),
                    cs,
                    widget.onHashtagTap,
                  ),
                ),
              ],
              // Like row
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked
                                ? SolarIconsBold.heart
                                : SolarIconsOutline.heart,
                            size: 18,
                            color: post.isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.likesCount}',
                            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      SolarIconsOutline.eye,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.viewCount}',
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
                      '${post.commentCount}',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                    const Spacer(),
                    if (post.recentCommenterAvatarUrls.isNotEmpty)
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
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        SolarIconsOutline.arrowRight,
                        size: 24,
                        color: Colors.grey[500],
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

    // Wrap card in VisibilityDetector to increment view once when >=50% visible.
    final vdKey = Key('post-vd-${post.id}');
    final wrapped = VisibilityDetector(
      key: vdKey,
      onVisibilityChanged: (info) {
        final visibleFraction = info.visibleFraction; // 0.0 ~ 1.0
        if (!_didIncrementView && visibleFraction >= 0.5) {
          _didIncrementView = true;
          // Schedule forget to avoid modifying internal VisibilityDetector map during iteration
          Future.microtask(
            () => VisibilityDetectorController.instance.forget(vdKey),
          );
          CommunityRepository.instance
              .incrementPostView(post.id)
              .then((newCount) {
                if (newCount != null && mounted) {
                  setState(() {
                    post = CommunityPost(
                      id: post.id,
                      content: post.content,
                      isAnonymous: post.isAnonymous,
                      authorId: post.authorId,
                      authorName: post.authorName,
                      authorAvatarUrl: post.authorAvatarUrl,
                      imageUrls: post.imageUrls,
                      createdAt: post.createdAt,
                      hashtags: post.hashtags,
                      recentCommenterAvatarUrls: post.recentCommenterAvatarUrls,
                      likesCount: post.likesCount,
                      viewCount: newCount,
                      commentCount: post.commentCount,
                      isLiked: post.isLiked,
                    );
                  });
                }
              })
              .catchError((_) {
                // On failure, do not reset _didIncrementView to avoid duplicate attempts in flaky network
              });
        }
      },
      child: card,
    );
    // Left indicator removed per design request — always return the card as-is
    return wrapped;
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

class _ChannelTabBar extends StatelessWidget {
  final TabController controller;
  final List<HashtagChannel> channels;
  final ValueChanged<int> onTap;

  const _ChannelTabBar({
    required this.controller,
    required this.channels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Build list of tabs ("전체" + channels)
    final tabWidgets = <Widget>[
      const Tab(text: '전체'),
      ...channels.map((channel) => Tab(text: '#${channel.name}')),
      // "+" tab as circular icon
      Tab(
        child: Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.primary, width: 0.7),
          ),
          child: Center(child: Icon(Icons.add, size: 9, color: cs.primary)),
        ),
      ),
    ];

    final tabsCount = tabWidgets.length;

    // If the provided controller already matches the number of tabs, use it.
    // Otherwise wrap TabBar with a DefaultTabController to avoid assertion
    // failures during controller length changes.
    final tabBar = TabBar(
      controller: (controller.length == tabsCount) ? controller : null,
      isScrollable: true,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.only(left: 8, right: 8),
      indicatorPadding: EdgeInsets.zero,
      // show primary-colored underline for the selected tab
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: cs.primary, width: 2),
        insets: const EdgeInsets.symmetric(horizontal: 12),
      ),
      dividerColor: Colors.transparent,
      tabAlignment: TabAlignment.start,
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
      // indicatorColor is ignored when 'indicator' is provided, keep clean
      labelStyle: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: tt.bodyMedium?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      tabs: tabWidgets,
      onTap: onTap,
    );

    if (controller.length == tabsCount) {
      return SizedBox(
        height: 46,
        child: Align(alignment: Alignment.centerLeft, child: tabBar),
      );
    }

    // Controller length mismatch: create a DefaultTabController for this
    // build so TabBar has a matching controller. Use a safe initialIndex
    // clamped into range.
    int initIndex = controller.index;
    if (initIndex < 0) initIndex = 0;
    if (initIndex > tabsCount - 1) initIndex = tabsCount - 1;

    return SizedBox(
      height: 46,
      child: DefaultTabController(
        length: tabsCount,
        initialIndex: initIndex,
        child: Align(alignment: Alignment.centerLeft, child: tabBar),
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
