import 'package:flutter/material.dart';
import 'dart:async';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'dart:ui';
import 'package:bamstar/services/avatar_helper.dart';
// 'choice' package no longer needed here; chips are rendered manually.
import 'package:bamstar/services/user_service.dart' as us;
import 'package:bamstar/scenes/community/post_comment_page.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:skeletonizer/skeletonizer.dart';
// removed drop_down_search_field dependency: use plain TextField for search
import 'package:bamstar/scenes/community/create_post_page.dart';
import '../../utils/toast_helper.dart';
import 'package:bamstar/scenes/community/channel_explorer_page.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:bamstar/scenes/community/community_constants.dart';
import 'package:bamstar/scenes/community/widgets/post_actions_menu.dart';
// Typography import removed as it's not used in current design implementation
import '../../theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bamstar/services/cloudinary.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:delightful_toast/delight_toast.dart';

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
      backgroundColor: const Color(0xFFFFFFFF), // Clean white base from sample
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        forceMaterialTransparency: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x0A000000), // Subtle shadow for depth
        foregroundColor: const Color(0xFF1C252E), // High contrast text
        elevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1C252E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
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
                  if (mounted) {
                    try {
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                    } catch (_) {}
                  }
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
      floatingActionButton: null,
      floatingActionButtonLocation: null,
      body: Stack(
        children: [
          SafeArea(
            child: Container(
              constraints: const BoxConstraints.expand(),
              color: const Color(0xFFFFFFFF), // Sample's clean white background
              child: RefreshIndicator(
                color:
                    Colors.grey, // neutral spinner instead of primary (purple)
                backgroundColor: Colors.white,
                onRefresh: _refresh,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    // Suppress default glow (we already provide a neutral one globally)
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Search input (togglable) - moved above the tab bar so it appears
                      // visually above tabs as requested.
                      SliverToBoxAdapter(
                        child: AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Container(
                            margin: const EdgeInsets.only(
                              top: 16,
                              bottom: 12,
                              left: 16,
                              right: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(
                                0x0F919EAB,
                              ), // Subtle background
                              border: Border.all(
                                color: const Color(0x26919EAB),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              focusNode: _searchFocusNode,
                              controller: _searchController,
                              style: const TextStyle(
                                color: Color(0xFF1C252E),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: '게시물 내용으로 검색',
                                hintStyle: TextStyle(
                                  color: Color(0x80919EAB),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(
                                  SolarIconsOutline.magnifier,
                                  size: 18,
                                  color: Color(0xFF919EAB),
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
                                      : (i == 1
                                            ? SortMode.popular
                                            : SortMode.liked);
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
                                              size: (smallFont - 2).clamp(
                                                8.0,
                                                12.0,
                                              ),
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
                                          : csLocal.surface.withValues(
                                              alpha: 0.06,
                                            ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      labelStyle:
                                          AppTextStyles.chipLabel(
                                            context,
                                          ).copyWith(
                                            fontSize: smallFont,
                                            color: isSelected
                                                ? csLocal.onPrimary
                                                : csLocal.onSurface.withValues(
                                                    alpha: 0.8,
                                                  ),
                                          ),
                                      side: BorderSide(
                                        color: isSelected
                                            ? csLocal.primary
                                            : csLocal.outlineVariant.withValues(
                                                alpha: 0.06,
                                              ),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          crossFadeState: _showSort
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 260),
                        ),
                      ),
                      // Removed the empty-subscriptions helper message per request.
                      if (_isLoading)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Skeletonizer(
                              enabled: true,
                              child: _PostSkeleton(cs: cs),
                            ),
                            childCount: 6,
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
                              onDeleted: () {
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

                      // Empty state when no posts available
                      if (!_isLoading && _posts.isEmpty)
                        SliverToBoxAdapter(child: _EmptyStateWidget()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 고정 위치의 FloatingActionButton
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
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
              child: const Icon(SolarIconsOutline.pen),
            ),
          ),
        ],
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
  BuildContext context,
  String text,
  TextStyle? style,
  ColorScheme cs,
  ValueChanged<String>? onHashtagTap,
) {
  final tStyle = style ?? AppTextStyles.primaryText(context);
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
          padding: const EdgeInsets.only(right: 8, left: 2),
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0x26919EAB), // Sample's subtle background
              ),
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: 8,
                right: 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onHashtagTap == null ? null : () => onHashtagTap(tag),
                child: Text(
                  tag,
                  style: tagStyle.copyWith(
                    color: const Color(
                      0xFF1C252E,
                    ), // High contrast text from sample
                    fontSize: 12,
                    fontWeight: FontWeight.w600, // Sample's bold weight
                  ),
                ),
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
  final VoidCallback? onDeleted;
  const _PostHtmlCard({
    required this.post,
    this.onTap,
    this.onHashtagTap,
    this.onDeleted,
  });

  @override
  State<_PostHtmlCard> createState() => _PostHtmlCardState();
}

class _PostHtmlCardState extends State<_PostHtmlCard> {
  late CommunityPost post;
  bool _isLiking = false;
  // VisibilityDetector will manage per-card visibility; use a unique key per card
  bool _didIncrementView = false;
  // Comment input controller and posting state
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;
  // Inline reply state
  int? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  VoidCallback? _replyFocusListener;
  // Track liked comment ids locally for inline preview (optimistic UI).
  final Set<int> _likedCommentIds = {};
  final Map<int, int> _commentLikeCounts = {};
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  // Image picker for comments and replies
  List<XFile> _selectedImages = [];
  List<XFile> _selectedReplyImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    _commentsFuture = CommunityRepository.instance
        .fetchCommentsForPost(post.id, limit: 6)
        .then((comments) async {
          await _prefetchCommentAuthors(comments);
          // initialize like counts and liked ids for fetched comments
          try {
            final ids = comments
                .map((c) => (c['id'] as int?) ?? -1)
                .where((id) => id > 0)
                .toList();
            if (ids.isNotEmpty) {
              final counts = await CommunityRepository.instance
                  .getCommentLikeCounts(ids);
              final liked = await CommunityRepository.instance
                  .getUserLikedComments(ids);
              if (mounted) {
                setState(() {
                  for (final e in counts.entries) {
                    _commentLikeCounts[e.key] = e.value;
                  }
                  _likedCommentIds.addAll(liked);
                });
              }
            }
          } catch (_) {}
          return comments;
        });
    // hide inline reply when its focus is lost
    _replyFocusListener = () {
      if (!_replyFocusNode.hasFocus) {
        if (mounted) setState(() => _replyingToCommentId = null);
        try {
          _replyController.clear();
        } catch (_) {}
      }
    };
    _replyFocusNode.addListener(_replyFocusListener!);
    // schedule a post-frame visibility check
    // VisibilityDetector will trigger view increment when appropriate.
  }

  @override
  void dispose() {
    try {
      _commentController.dispose();
    } catch (_) {}
    try {
      if (_replyFocusListener != null)
        _replyFocusNode.removeListener(_replyFocusListener!);
    } catch (_) {}
    try {
      _replyController.dispose();
    } catch (_) {}
    try {
      _replyFocusNode.dispose();
    } catch (_) {}
    super.dispose();
  }

  // 댓글용 이미지 선택
  Future<void> _pickImagesForComment() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      if (mounted) {
        DelightToastBar(
          autoDismiss: true,
          animationDuration: const Duration(milliseconds: 300),
          snackbarDuration: const Duration(seconds: 5),
          builder: (context) => Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.dangerCircle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '이미지 선택 중 오류가 발생했습니다: $e',
                    style: AppTextStyles.primaryText(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).show(context);
      }
    }
  }

  // 답글용 이미지 선택
  Future<void> _pickImagesForReply() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedReplyImages = images;
        });
      }
    } catch (e) {
      if (mounted) {
        DelightToastBar(
          autoDismiss: true,
          animationDuration: const Duration(milliseconds: 300),
          snackbarDuration: const Duration(seconds: 5),
          builder: (context) => Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.dangerCircle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '이미지 선택 중 오류가 발생했습니다: $e',
                    style: AppTextStyles.primaryText(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).show(context);
      }
    }
  }

  // 선택된 이미지 삭제 (댓글용)
  void _removeImageFromComment(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 선택된 이미지 삭제 (답글용)
  void _removeImageFromReply(int index) {
    setState(() {
      _selectedReplyImages.removeAt(index);
    });
  }

  // 이미지들을 Cloudinary에 업로드하고 URL 리스트 반환
  Future<List<String>> _uploadImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];

    setState(() {
      _isUploadingImages = true;
    });

    try {
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        try {
          final bytes = await image.readAsBytes();
          final url = await CloudinaryService.instance.uploadImageFromBytes(
            bytes,
            fileName: image.name,
            folder: 'community/comments',
          );
          uploadedUrls.add(url);
        } catch (e) {
          if (mounted) {
            DelightToastBar(
              autoDismiss: true,
              animationDuration: const Duration(milliseconds: 300),
              snackbarDuration: const Duration(seconds: 5),
              builder: (context) => Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      SolarIconsOutline.dangerCircle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '이미지 업로드 실패: ${image.name}',
                        style: AppTextStyles.primaryText(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ).show(context);
          }
          // 개별 이미지 업로드 실패 시에도 다른 이미지들은 계속 업로드
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }

    return uploadedUrls;
  }

  Future<void> _submitComment() async {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    final text = _commentController.text.trim();
    // 텍스트가 비어있으면 이미지가 있어도 업로드 안됨
    if (text.isEmpty) {
      if (mounted) {
        DelightToastBar(
          autoDismiss: true,
          animationDuration: const Duration(milliseconds: 300),
          snackbarDuration: const Duration(seconds: 5),
          builder: (context) => Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.infoCircle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '댓글 내용을 입력해주세요.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).show(context);
      }
      return;
    }
    if (_isPostingComment) return;
    setState(() => _isPostingComment = true);

    try {
      // 이미지 업로드 (있는 경우)
      List<String> uploadedUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedUrls = await _uploadImages(_selectedImages);
        if (uploadedUrls.isEmpty && _selectedImages.isNotEmpty) {
          // 이미지 업로드가 모두 실패한 경우 - 텍스트가 있으면 텍스트만 게시
          if (text.isEmpty) {
            if (mounted) {
              DelightToastBar(
                autoDismiss: true,
                animationDuration: const Duration(milliseconds: 300),
                snackbarDuration: const Duration(seconds: 5),
                builder: (context) => Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SolarIconsOutline.infoCircle,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '이미지 업로드 실패. 텍스트를 입력해주세요.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).show(context);
            }
            return;
          } else {
            // 텍스트가 있으면 텍스트만 게시하고 계속 진행
            if (mounted) {
              DelightToastBar(
                autoDismiss: true,
                animationDuration: const Duration(milliseconds: 300),
                snackbarDuration: const Duration(seconds: 5),
                builder: (context) => Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SolarIconsOutline.infoCircle,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '이미지 업로드 실패. 텍스트만 게시합니다.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).show(context);
            }
          }
        }
      }

      // 댓글 생성 (업로드된 모든 이미지 URL을 댓글에 첨부)
      final success = await CommunityRepository.instance.createComment(
        postId: post.id,
        content: text,
        isAnonymous: false,
        imageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
      );

      if (success) {
        // 선택된 이미지들과 텍스트 초기화
        setState(() {
          _selectedImages.clear();
          _commentController.clear();
        });

        // refresh commenter avatars for this post and bump comment count
        try {
          final avatars = await CommunityRepository.instance
              .getPostCommenterAvatars(post.id, limit: 3);
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
              recentCommenterAvatarUrls: avatars,
              likesCount: post.likesCount,
              viewCount: post.viewCount,
              commentCount: post.commentCount + 1,
              isLiked: post.isLiked,
            );
          });
        } catch (_) {
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
              viewCount: post.viewCount,
              commentCount: post.commentCount + 1,
              isLiked: post.isLiked,
            );
          });
        }
        _commentController.clear();
        // refresh inline preview
        try {
          setState(() {
            _commentsFuture = CommunityRepository.instance
                .fetchCommentsForPost(post.id, limit: 2)
                .then((comments) async {
                  await _prefetchCommentAuthors(comments);
                  return comments;
                });
          });
        } catch (_) {}
      } else {
        // show error
        try {
          if (mounted) {
            DelightToastBar(
              autoDismiss: true,
              animationDuration: const Duration(milliseconds: 300),
              snackbarDuration: const Duration(seconds: 5),
              builder: (context) => Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      SolarIconsOutline.dangerCircle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '댓글 전송에 실패했습니다',
                        style: AppTextStyles.primaryText(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ).show(context);
          }
        } catch (_) {}
      }
    } catch (e) {
      // 이미지 업로드 또는 댓글 생성 중 오류 발생
      if (mounted) {
        DelightToastBar(
          builder: (context) => Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 60,
              bottom: 8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.dangerTriangle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '댓글 전송 중 오류가 발생했습니다: $e',
                    style: AppTextStyles.primaryText(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          autoDismiss: true,
        ).show(context);
      }
    }

    if (mounted) setState(() => _isPostingComment = false);
  }

  Future<void> _submitReply({required int parentCommentId}) async {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    final text = _replyController.text.trim();
    if (text.isEmpty && _selectedReplyImages.isEmpty) return;
    if (_isPostingComment) return;
    setState(() => _isPostingComment = true);

    try {
      // 이미지 업로드 (있는 경우)
      List<String> uploadedUrls = [];
      if (_selectedReplyImages.isNotEmpty) {
        uploadedUrls = await _uploadImages(_selectedReplyImages);
        if (uploadedUrls.isEmpty && _selectedReplyImages.isNotEmpty) {
          // 이미지 업로드가 모두 실패한 경우
          if (mounted) {
            DelightToastBar(
              builder: (context) => Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 60,
                  bottom: 8,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      SolarIconsBold.dangerTriangle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '이미지 업로드에 실패했습니다. 텍스트만 게시하시겠습니까?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              autoDismiss: true,
            ).show(context);
          }
          return;
        }
      }

      final success = await CommunityRepository.instance.createComment(
        postId: post.id,
        content: text,
        isAnonymous: false,
        parentCommentId: parentCommentId,
        imageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
      );

      if (success) {
        // 선택된 답글 이미지들과 텍스트 초기화
        setState(() {
          _selectedReplyImages.clear();
          _replyController.clear();
        });

        // optimistic bump
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
            viewCount: post.viewCount,
            commentCount: post.commentCount + 1,
            isLiked: post.isLiked,
          );
        });
        _replyController.clear();
        _replyingToCommentId = null;
        // refresh inline preview
        try {
          setState(() {
            _commentsFuture = CommunityRepository.instance
                .fetchCommentsForPost(post.id, limit: 6)
                .then((comments) async {
                  await _prefetchCommentAuthors(comments);
                  return comments;
                });
          });
        } catch (_) {}
      } else {
        try {
          if (mounted) {
            ToastHelper.error(context, '답글 전송에 실패했습니다');
          }
        } catch (_) {}
      }
    } catch (e) {
      // 이미지 업로드 또는 답글 생성 중 오류 발생
      if (mounted) {
        DelightToastBar(
          builder: (context) => Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 60,
              bottom: 8,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsBold.dangerTriangle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '답글 전송 중 오류가 발생했습니다: $e',
                    style: AppTextStyles.primaryText(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          autoDismiss: true,
        ).show(context);
      }
    }

    if (mounted) setState(() => _isPostingComment = false);
  }

  /// Build a simple one-level comment tree from a flat comments list.
  ///
  /// Strategy:
  /// - Index comments by id. If a comment has a `parent_comment_id` that
  ///   refers to another comment present in the fetched list, attach it as a
  ///   child of that parent. Otherwise treat it as a root-level comment.
  /// - This builds one nesting level which is sufficient for common
  ///   parent->reply rendering in the preview area.
  List<Map<String, dynamic>> _buildCommentTree(
    List<Map<String, dynamic>> comments,
  ) {
    final Map<int, Map<String, dynamic>> byId = {};
    for (final c in comments) {
      final id = (c['id'] as int?) ?? -1;
      if (id > 0) byId[id] = Map<String, dynamic>.from(c);
    }

    final Map<int, List<Map<String, dynamic>>> childMap = {};
    final List<Map<String, dynamic>> roots = [];

    for (final c in comments) {
      final pid = c['parent_comment_id'] as int?;
      if (pid != null && pid > 0 && byId.containsKey(pid)) {
        childMap.putIfAbsent(pid, () => []).add(Map<String, dynamic>.from(c));
      } else {
        // treat as root when parent absent or null
        roots.add(Map<String, dynamic>.from(c));
      }
    }

    // attach children list to each root (may be empty)
    for (final r in roots) {
      final rid = (r['id'] as int?) ?? -1;
      r['children'] = childMap[rid] ?? <Map<String, dynamic>>[];
    }

    return roots;
  }

  Widget _buildCommentRow(
    Map<String, dynamic> c,
    ColorScheme cs,
    TextTheme tt, {
    bool isReply = false,
  }) {
    final content = (c['content'] as String?) ?? '';
    final createdAt =
        DateTime.tryParse(c['created_at'] as String? ?? '') ?? DateTime.now();
    final isAnonymous = (c['is_anonymous'] as bool? ?? false);
    final authorId = c['author_id'] as String?;
    final fallbackName = (c['author_name'] as String?) ?? '스타';
    final fallbackAvatar = (c['author_avatar_url'] as String?) ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FutureBuilder<us.AppUser?>(
        future: _getAuthor(authorId),
        builder: (context, snap) {
          final user = snap.data;
          final authorName = isAnonymous
              ? '익명의 스타'
              : ((user != null && (user.nickname.isNotEmpty == true))
                    ? user.nickname
                    : fallbackName);

          String? candidateUrl;
          if (user != null) {
            final p = (user.data['profile_img'] as String?)?.trim();
            if (p != null && p.isNotEmpty) candidateUrl = p;
          }
          if ((candidateUrl == null || candidateUrl.isEmpty) &&
              fallbackAvatar.isNotEmpty)
            candidateUrl = fallbackAvatar;
          if (isAnonymous && (candidateUrl == null || candidateUrl.isEmpty))
            candidateUrl = null;

          ImageProvider? avatarImage;
          if (candidateUrl != null && candidateUrl.isNotEmpty) {
            avatarImage = avatarImageProviderFromUrl(
              candidateUrl,
              width: (CommunitySizes.avatarBase * 2.8).toInt(),
              height: (CommunitySizes.avatarBase * 2.8).toInt(),
            );
          }

          Widget avatarWidget;
          if (isAnonymous && avatarImage != null) {
            avatarWidget = SizedBox(
              width: CommunitySizes.avatarBase / 2 * 1.4 * 2,
              height: CommunitySizes.avatarBase / 2 * 1.4 * 2,
              child: ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Image(
                    image: avatarImage,
                    width: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                    height: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          } else if (isAnonymous && avatarImage == null) {
            avatarWidget = SizedBox(
              width: CommunitySizes.avatarBase / 2 * 1.4 * 2,
              height: CommunitySizes.avatarBase / 2 * 1.4 * 2,
              child: ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: CommunitySizes.avatarBase / 2 * 1.4 * 2,
                    height: CommunitySizes.avatarBase / 2 * 1.4 * 2,
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
          } else {
            avatarWidget = CircleAvatar(
              radius: CommunitySizes.avatarBase / 2,
              backgroundColor: isAnonymous ? cs.secondaryContainer : null,
              backgroundImage: avatarImage,
              child: (!isAnonymous && avatarImage == null)
                  ? Icon(Icons.person, size: 12, color: cs.onSurfaceVariant)
                  : null,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatarWidget,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                authorName,
                                style: tt.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _timeAgo(createdAt),
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(content, style: tt.bodyMedium),
                        // 댓글 이미지들 표시 (배열 지원)
                        if (c['image_url'] != null) ...[
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              List<String> imageUrls = [];

                              // image_url이 배열인지 단일 문자열인지 확인
                              if (c['image_url'] is List) {
                                imageUrls = (c['image_url'] as List)
                                    .map((e) => e.toString())
                                    .where((url) => url.isNotEmpty)
                                    .toList();
                              } else if (c['image_url'] is String &&
                                  c['image_url'].toString().isNotEmpty) {
                                imageUrls = [c['image_url'].toString()];
                              }

                              if (imageUrls.isEmpty)
                                return const SizedBox.shrink();

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: imageUrls.length == 1
                                          ? 1
                                          : 2,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                      childAspectRatio: imageUrls.length == 1
                                          ? 1.5
                                          : 1.0,
                                    ),
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showImageViewer(
                                        context,
                                        imageUrls,
                                        index,
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        height: imageUrls.length == 1
                                            ? 100
                                            : 80,
                                        child: Image.network(
                                          imageUrls[index],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: cs.surfaceContainer,
                                                  child: Center(
                                                    child: Icon(
                                                      SolarIconsOutline.gallery,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                      size: 20,
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final cid = (c['id'] as int?) ?? -1;
                                if (cid < 0) return;
                                setState(() {
                                  final current = _commentLikeCounts[cid] ?? 0;
                                  if (_likedCommentIds.contains(cid)) {
                                    _likedCommentIds.remove(cid);
                                    _commentLikeCounts[cid] = (current - 1)
                                        .clamp(0, 999999);
                                  } else {
                                    _likedCommentIds.add(cid);
                                    _commentLikeCounts[cid] = current + 1;
                                  }
                                });
                                try {
                                  if (_likedCommentIds.contains(cid)) {
                                    final ok = await CommunityRepository
                                        .instance
                                        .likeComment(commentId: cid);
                                    if (!ok) {
                                      setState(() {
                                        _likedCommentIds.remove(cid);
                                        _commentLikeCounts[cid] =
                                            (_commentLikeCounts[cid] ?? 1) - 1;
                                      });
                                    }
                                  } else {
                                    final ok = await CommunityRepository
                                        .instance
                                        .unlikeComment(commentId: cid);
                                    if (!ok) {
                                      setState(() {
                                        _likedCommentIds.add(cid);
                                        _commentLikeCounts[cid] =
                                            (_commentLikeCounts[cid] ?? 0) + 1;
                                      });
                                    }
                                  }
                                } catch (_) {
                                  setState(() {
                                    if (_likedCommentIds.contains(cid)) {
                                      _likedCommentIds.remove(cid);
                                      _commentLikeCounts[cid] =
                                          (_commentLikeCounts[cid] ?? 1) - 1;
                                    } else {
                                      _likedCommentIds.add(cid);
                                      _commentLikeCounts[cid] =
                                          (_commentLikeCounts[cid] ?? 0) + 1;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _likedCommentIds.contains(
                                            (c['id'] as int?) ?? -1,
                                          )
                                          ? SolarIconsBold.heart
                                          : SolarIconsOutline.heart,
                                      color:
                                          _likedCommentIds.contains(
                                            (c['id'] as int?) ?? -1,
                                          )
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_commentLikeCounts[(c['id'] as int?) ?? -1] ?? 0}',
                                      style: tt.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 편집 아이콘 (연필 모양) - 댓글에만 표시 (대댓글에는 없음)
                            if (!isReply) ...[
                              GestureDetector(
                                onTap: () {
                                  final cid = (c['id'] as int?) ?? -1;
                                  if (cid < 0) return;
                                  if (_replyingToCommentId == cid) {
                                    setState(() => _replyingToCommentId = null);
                                    _replyController.clear();
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    setState(() => _replyingToCommentId = cid);
                                    Future.delayed(
                                      const Duration(milliseconds: 50),
                                      () {
                                        if (mounted) {
                                          try {
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(_replyFocusNode);
                                          } catch (_) {}
                                        }
                                      },
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      SolarIconsOutline.pen,
                                      size: 14,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '댓글 쓰기',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            // 삭제 아이콘 (휴지통 모양) - 본인 댓글일 때만 표시 (댓글과 대댓글 모두)
                            if (authorId != null &&
                                Supabase.instance.client.auth.currentUser?.id ==
                                    authorId)
                              GestureDetector(
                                onTap: () async {
                                  // 삭제 확인 다이얼로그
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('댓글 삭제'),
                                      content: const Text('이 댓글을 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    final cid = (c['id'] as int?) ?? -1;
                                    if (cid < 0) return;

                                    try {
                                      await CommunityRepository.instance
                                          .deleteComment(
                                            commentId: cid,
                                            postId: post.id,
                                          );

                                      // 댓글 목록 새로고침
                                      setState(() {
                                        _commentsFuture = CommunityRepository
                                            .instance
                                            .fetchCommentsForPost(
                                              post.id,
                                              limit: 6,
                                            )
                                            .then((comments) async {
                                              await _prefetchCommentAuthors(
                                                comments,
                                              );
                                              try {
                                                final ids = comments
                                                    .map(
                                                      (c) =>
                                                          (c['id'] as int?) ??
                                                          -1,
                                                    )
                                                    .where((id) => id > 0)
                                                    .toList();
                                                if (ids.isNotEmpty) {
                                                  final counts =
                                                      await CommunityRepository
                                                          .instance
                                                          .getCommentLikeCounts(
                                                            ids,
                                                          );
                                                  final liked =
                                                      await CommunityRepository
                                                          .instance
                                                          .getUserLikedComments(
                                                            ids,
                                                          );
                                                  if (mounted) {
                                                    setState(() {
                                                      _commentLikeCounts
                                                          .clear();
                                                      _likedCommentIds.clear();
                                                      for (final e
                                                          in counts.entries) {
                                                        _commentLikeCounts[e
                                                                .key] =
                                                            e.value;
                                                      }
                                                      _likedCommentIds.addAll(
                                                        liked,
                                                      );
                                                    });
                                                  }
                                                }
                                              } catch (_) {}
                                              return comments;
                                            });
                                      });

                                      if (mounted) {
                                        DelightToastBar(
                                          autoDismiss: true,
                                          animationDuration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          snackbarDuration: const Duration(
                                            seconds: 5,
                                          ),
                                          builder: (context) => Container(
                                            margin: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 8,
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  SolarIconsOutline.checkCircle,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '댓글이 삭제되었습니다.',
                                                    style:
                                                        AppTextStyles.primaryText(
                                                          context,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).show(context);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        DelightToastBar(
                                          builder: (context) => Container(
                                            margin: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 8,
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  SolarIconsOutline
                                                      .dangerCircle,
                                                  color: Colors.red,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '댓글 삭제 중 오류가 발생했습니다: $e',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).show(context);
                                      }
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      SolarIconsOutline.trashBinMinimalistic,
                                      size: 14,
                                      color: Colors.red.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '삭제하기',
                                      style: tt.bodySmall?.copyWith(
                                        color: Colors.red.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ClipRect(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: -1.0,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child:
                      ((!isReply) &&
                          ((_replyingToCommentId ?? -1) ==
                              ((c['id'] as int?) ?? -1)))
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Container(
                              key: ValueKey('reply-input-${c['id']}'),
                              margin: const EdgeInsets.only(top: 8),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 답글용 선택된 이미지 섬네일 표시
                                  if (_selectedReplyImages.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      height: 60,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _selectedReplyImages.length,
                                        itemBuilder: (context, index) {
                                          final image =
                                              _selectedReplyImages[index];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: kIsWeb
                                                      ? Image.network(
                                                          image.path,
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  width: 60,
                                                                  height: 60,
                                                                  color: cs
                                                                      .surfaceContainerHighest,
                                                                  child: Icon(
                                                                    SolarIconsOutline
                                                                        .gallery,
                                                                    color: cs
                                                                        .onSurfaceVariant,
                                                                    size: 20,
                                                                  ),
                                                                );
                                                              },
                                                        )
                                                      : Image.file(
                                                          File(image.path),
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  width: 60,
                                                                  height: 60,
                                                                  color: cs
                                                                      .surfaceContainerHighest,
                                                                  child: Icon(
                                                                    SolarIconsOutline
                                                                        .gallery,
                                                                    color: cs
                                                                        .onSurfaceVariant,
                                                                    size: 20,
                                                                  ),
                                                                );
                                                              },
                                                        ),
                                                ),
                                                Positioned(
                                                  top: 2,
                                                  right: 2,
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        _removeImageFromReply(
                                                          index,
                                                        ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            3,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _replyController,
                                          focusNode: _replyFocusNode,
                                          textInputAction: TextInputAction.send,
                                          onSubmitted: (_) => _submitReply(
                                            parentCommentId:
                                                (c['id'] as int?) ?? -1,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '댓글 작성',
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
                                      GestureDetector(
                                        onTap: _pickImagesForReply,
                                        child: Icon(
                                          SolarIconsOutline.paperclip,
                                          size: 21,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _isUploadingImages
                                            ? null
                                            : () => _submitReply(
                                                parentCommentId:
                                                    (c['id'] as int?) ?? -1,
                                              ),
                                        child: _isUploadingImages
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.grey),
                                                ),
                                              )
                                            : Icon(
                                                SolarIconsOutline.arrowRight,
                                                size: 24,
                                                color: Colors.grey[500],
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Prefetch comment authors for the provided comments list and populate the
  /// top-level `_authorCache` so `_getAuthor` hits the cache and avoids
  /// individual network calls per comment.
  Future<void> _prefetchCommentAuthors(
    List<Map<String, dynamic>> comments,
  ) async {
    try {
      final ids = comments
          .map((c) => c['author_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .where((id) => !_authorCache.containsKey(id))
          .toList();
      if (ids.isEmpty) return;
      final client = Supabase.instance.client;
      final idsCsv = ids.map((s) => '"$s"').join(',');
      final res = await client
          .from('users')
          .select('*')
          .filter('id', 'in', '($idsCsv)');
      final List data = res as List? ?? [];
      for (final row in data) {
        try {
          final m = Map<String, dynamic>.from(row as Map);
          final u = us.AppUser.fromMap(m);
          _authorCache[u.id] = u;
        } catch (_) {
          // ignore malformed rows
        }
      }
      for (final id in ids) {
        if (!_authorCache.containsKey(id)) _authorCache[id] = null;
      }
    } catch (_) {
      // ignore errors; fallback to per-comment fetch
    }
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
    final hasImages = post.imageUrls.isNotEmpty;

    final _cardInner = Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Clean white background from sample
        borderRadius: BorderRadius.circular(10), // Sample's rounded corners
        border: Border.all(
          color: const Color(0x0F919EAB), // Subtle border
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // Very subtle shadow
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 4,
          ), // More generous padding
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
                    PostActionsMenu(
                      postId: post.id,
                      reportedUserId: post.isAnonymous ? null : post.authorId,
                      // 자기 자신의 게시물에 대해서는 신고/차단 메뉴 비활성화
                      onReport:
                          post.authorId != null &&
                              Supabase.instance.client.auth.currentUser?.id !=
                                  post.authorId
                          ? (reason) {
                              // 신고 처리는 PostActionsMenu에서 자동 처리
                            }
                          : null,
                      onBlock:
                          post.authorId != null &&
                              Supabase.instance.client.auth.currentUser?.id !=
                                  post.authorId
                          ? () {
                              // 차단 처리는 PostActionsMenu에서 자동 처리
                            }
                          : null,
                      // Show delete option only when current user is the author
                      showDelete:
                          post.authorId != null &&
                          Supabase.instance.client.auth.currentUser?.id ==
                              post.authorId,
                      onDelete:
                          post.authorId != null &&
                              Supabase.instance.client.auth.currentUser?.id ==
                                  post.authorId
                          ? () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('게시물 삭제'),
                                  content: const Text('이 게시물을 삭제하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        '삭제',
                                        style: AppTextStyles.buttonText(
                                          context,
                                        ).copyWith(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                try {
                                  final ok = await CommunityRepository.instance
                                      .deletePost(postId: post.id);
                                  if (ok) {
                                    // refresh the feed: remove post locally and trigger parent reload
                                    setState(() {
                                      // optimistic removal from UI
                                      // actual refresh handled by parent on its next refresh
                                      // Remove from local posts list if present
                                    });
                                    DelightToastBar(
                                      autoDismiss: true,
                                      animationDuration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      snackbarDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      builder: (context) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '게시물이 삭제되었습니다',
                                          style: AppTextStyles.primaryText(
                                            context,
                                          ).copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ).show(context);
                                    // trigger a refresh of the feed
                                    // notify parent to refresh the feed
                                    widget.onDeleted?.call();
                                  } else {
                                    DelightToastBar(
                                      autoDismiss: true,
                                      animationDuration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      snackbarDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      builder: (context) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '삭제에 실패했습니다',
                                          style: AppTextStyles.primaryText(
                                            context,
                                          ).copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ).show(context);
                                  }
                                } catch (e) {
                                  DelightToastBar(
                                    autoDismiss: true,
                                    animationDuration: const Duration(
                                      milliseconds: 260,
                                    ),
                                    snackbarDuration: const Duration(
                                      seconds: 3,
                                    ),
                                    builder: (context) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '삭제 중 오류가 발생했습니다: $e',
                                        style: AppTextStyles.primaryText(
                                          context,
                                        ).copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ).show(context);
                                }
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              // Media section (multi 이미지일 때: 댓글 썸네일 스타일, 1장일 때는 아래에서 Aspect 유지 렌더)
              if (twoThumbs) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    0,
                  ), // add extra top padding for visual breathing room
                  child: _PostImageGallery(
                    imageUrls: post.imageUrls,
                    onTap: (index) =>
                        _showImageViewer(context, post.imageUrls, index),
                    isGrid: true,
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
                      context,
                      displayTitle,
                      tt.bodyMedium?.copyWith(color: cs.onSurface),
                      cs,
                      widget.onHashtagTap,
                    ),
                  ),
                ),
              ],
              // Single image (원본 비율 유지) - Title 뒤에 위치 유지
              if (!twoThumbs && hasImages) ...[
                // minimal vertical gap to match comment layout
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _PostImageGallery(
                    imageUrls: post.imageUrls,
                    onTap: (index) =>
                        _showImageViewer(context, post.imageUrls, index),
                    isGrid: false,
                  ),
                ),
              ],
              // Body
              if (body.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  child: _buildContentWithHashtags(
                    context,
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
                    GestureDetector(
                      onTap: () {
                        // Open the dedicated comment page for this post as a modal when possible.
                        try {
                          WoltModalSheet.show(
                            context: context,
                            pageListBuilder: (modalContext) => [
                              PostCommentPage.woltPage(modalContext, post),
                            ],
                            modalTypeBuilder: (ctx) =>
                                WoltModalType.bottomSheet(),
                          );
                        } catch (_) {
                          // Fallback to Navigator if modal API isn't available or errors
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostCommentPage(post: post),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
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
                        ],
                      ),
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
                // add ~5px extra top padding so the input has a bit more space above it
                padding: const EdgeInsets.fromLTRB(24, 13, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 선택된 이미지 섬네일 표시
                    if (_selectedImages.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            final image = _selectedImages[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.network(
                                            image.path,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: cs
                                                        .surfaceContainerHighest,
                                                    child: Icon(
                                                      SolarIconsOutline.gallery,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Image.file(
                                            File(image.path),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: cs
                                                        .surfaceContainerHighest,
                                                    child: Icon(
                                                      SolarIconsOutline.gallery,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                  );
                                                },
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _removeImageFromComment(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    Container(
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
                              controller: _commentController,
                              onSubmitted: (_) => _submitComment(),
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
                          GestureDetector(
                            onTap: _pickImagesForComment,
                            child: Icon(
                              SolarIconsOutline.paperclip,
                              size: 21,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: (_isPostingComment || _isUploadingImages)
                                ? null
                                : _submitComment,
                            child: _isUploadingImages
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    SolarIconsOutline.arrowRight,
                                    size: 24,
                                    color: _isPostingComment
                                        ? Colors.grey[400]
                                        : Colors.grey[500],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Inline comments preview under the comment input (data-driven)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // do not open full comment modal when tapping preview area;
                    // just unfocus any inputs to allow dismissing keyboards.
                    FocusScope.of(context).unfocus();
                  },
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _commentsFuture,
                    builder: (context, snap) {
                      final comments = snap.data ?? [];
                      if (comments.isEmpty) return const SizedBox.shrink();
                      final roots = _buildCommentTree(comments);
                      // Build a flattened preview list (preserve parent->child order)
                      // but show at most 3 items total (including replies).
                      final List<Widget> previewItems = [];
                      int remaining = 3;
                      for (final root in roots) {
                        if (remaining <= 0) break;
                        previewItems.add(_buildCommentRow(root, cs, tt));
                        remaining -= 1;
                        if (remaining <= 0) break;
                        final rootChildren =
                            (root['children'] as List<Map<String, dynamic>>?) ??
                            [];
                        for (final child in rootChildren) {
                          if (remaining <= 0) break;
                          previewItems.add(
                            Padding(
                              padding: const EdgeInsets.only(left: 44, top: 8),
                              child: _buildCommentRow(
                                child,
                                cs,
                                tt,
                                isReply: true,
                              ),
                            ),
                          );
                          remaining -= 1;
                        }
                      }

                      return Column(
                        children: [
                          Column(children: previewItems),
                          GestureDetector(
                            onTap: () {
                              try {
                                WoltModalSheet.show(
                                  context: context,
                                  pageListBuilder: (modalContext) => [
                                    PostCommentPage.woltPage(
                                      modalContext,
                                      post,
                                    ),
                                  ],
                                  modalTypeBuilder: (ctx) =>
                                      WoltModalType.bottomSheet(),
                                );
                              } catch (_) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PostCommentPage(post: post),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '댓글 더보기',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Create a stacked card with a subtle top highlight to give a lit-top 3D effect
    final card = Stack(
      children: [
        _cardInner,
        // thin gradient at the top to simulate light hitting the top edge
        Positioned(
          left: 12,
          right: 12,
          top: 8,
          child: IgnorePointer(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white.withValues(alpha: 0.60)
                        : Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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

  void _showImageViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            _ImageViewerPage(imageUrls: imageUrls, initialIndex: initialIndex),
        fullscreenDialog: true,
      ),
    );
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
    // Build list of tabs with proper selected/unselected states
    final tabWidgets = <Widget>[
      Tab(
        child: _TabContent(text: '전체', isSelected: controller.index == 0),
      ),
      ...channels.asMap().entries.map((entry) {
        final index = entry.key + 1; // +1 because "전체" is at index 0
        final channel = entry.value;
        return Tab(
          child: _TabContent(
            text: '#${channel.name}',
            isSelected: controller.index == index,
          ),
        );
      }),
      // "+" tab for adding new channels
      Tab(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: cs.surfaceContainerHighest,
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            SolarIconsOutline.addCircle,
            size: 18,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    ];

    final tabsCount = tabWidgets.length;

    // If the provided controller already matches the tab count, build a
    // TabBar wired to that controller and wrap each tab child in an
    // AnimatedBuilder so the tab content rebuilds when selection changes.
    if (controller.length == tabsCount) {
      final activeTabBar = TabBar(
        controller: controller,
        isScrollable: true,
        // Reduce left/right padding to minimize extra spacing at the ends
        padding: const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
        // Make label padding tighter so each tab uses less horizontal space
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        indicatorPadding: EdgeInsets.zero,
        indicator:
            const BoxDecoration(), // No underline indicator - using container backgrounds
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        labelColor: const Color(0xFF1C252E), // High contrast from sample
        unselectedLabelColor: const Color(0xFF919EAB), // Muted color
        splashFactory: NoSplash.splashFactory, // Clean tap without ripple
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: tabWidgets.map((w) {
          // If the tab child is a Tab with _TabContent, wrap in AnimatedBuilder
          if (w is Tab) {
            return Tab(
              child: AnimatedBuilder(
                animation:
                    controller.animation ?? const AlwaysStoppedAnimation(0.0),
                builder: (context, _) {
                  // Re-evaluate selection state based on controller.index
                  final idx = tabWidgets.indexOf(w);
                  // For safety, clamp index
                  final safe = (idx < 0 || idx >= tabsCount) ? 0 : idx;
                  // If original child was a _TabContent, rebuild with updated isSelected
                  if (w.child is _TabContent) {
                    return _TabContent(
                      text: (w.child as _TabContent).text,
                      isSelected: controller.index == safe,
                    );
                  }
                  // fallback: non-null child
                  return w.child ?? const SizedBox.shrink();
                },
              ),
            );
          }
          return w;
        }).toList(),
        onTap: onTap,
      );

      return SizedBox(
        height: 56,
        child: Align(alignment: Alignment.centerLeft, child: activeTabBar),
      );
    }

    // Controller length mismatch: build using DefaultTabController and create
    // the TabBar inside a Builder so we can access the internal controller
    // (DefaultTabController.of(context)). Use AnimatedBuilder on that controller
    // to ensure tabs rebuild when selection changes.
    int initIndex = controller.index;
    if (initIndex < 0) initIndex = 0;
    if (initIndex > tabsCount - 1) initIndex = tabsCount - 1;

    return SizedBox(
      height: 56,
      child: DefaultTabController(
        length: tabsCount,
        initialIndex: initIndex,
        child: Builder(
          builder: (ctx) {
            final inner = DefaultTabController.of(ctx);
            final innerTabs = tabWidgets.map((w) {
              if (w is Tab) {
                return Tab(
                  child: AnimatedBuilder(
                    animation:
                        inner.animation ?? const AlwaysStoppedAnimation(0.0),
                    builder: (context, _) {
                      final idx = tabWidgets.indexOf(w);
                      final safe = (idx < 0 || idx >= tabsCount) ? 0 : idx;
                      if (w.child is _TabContent) {
                        return _TabContent(
                          text: (w.child as _TabContent).text,
                          isSelected: inner.index == safe,
                        );
                      }
                      return (w.child ?? const SizedBox.shrink());
                    },
                  ),
                );
              }
              return w;
            }).toList();

            final innerTabBar = TabBar(
              controller: inner,
              isScrollable: true,
              padding: const EdgeInsets.only(
                left: 12,
                right: 8,
                top: 10,
                bottom: 10,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              indicatorPadding: EdgeInsets.zero,
              indicator: const BoxDecoration(),
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF1C252E),
              unselectedLabelColor: const Color(0xFF919EAB),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: innerTabs,
              onTap: onTap,
            );

            return Align(alignment: Alignment.centerLeft, child: innerTabBar);
          },
        ),
      ),
    );
  }
}

/// 게시글 카드 내 이미지 갤러리.
/// isGrid=true 이면 다중(2개 이상) 이미지를 정사각형 썸네일 격자로, false 이면 단일 이미지를 원본 비율 유지하여 렌더.
class _PostImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final ValueChanged<int>? onTap;
  final bool isGrid; // true: multi grid, false: single with aspect
  const _PostImageGallery({
    required this.imageUrls,
    this.onTap,
    required this.isGrid,
  });

  @override
  State<_PostImageGallery> createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<_PostImageGallery> {
  final Map<String, double> _aspectCache = {};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    final singleMaxHeight = CommunitySizes.imageSingleMaxHeight;
    final thumbSize = CommunitySizes.imageThumbSize;
    final spacing = CommunitySizes.imageThumbSpacing;

    if (widget.isGrid) {
      final urls = widget.imageUrls.take(4).toList(); // 최대 4개 표시 (댓글 스타일)
      final rows = (urls.length / 2).ceil();
      final gridHeight = rows * thumbSize + (rows - 1) * spacing;
      // 댓글/대댓글 썸네일 레이아웃과 완전히 동일하게: 고정 100px 정사각 Wrap (2열 흐름)
      return SizedBox(
        height: gridHeight,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (int index = 0; index < urls.length; index++)
              SizedBox(
                width: thumbSize,
                height: thumbSize,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap == null
                        ? null
                        : () => widget.onTap!(index),
                    borderRadius: BorderRadius.circular(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        urls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: cs.surfaceContainer,
                          child: Icon(
                            SolarIconsOutline.gallery,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // 단일 이미지: 본래 비율 복원, 최대 높이 제한
    final url = widget.imageUrls.first;
    final aspect = _aspectCache[url];
    Widget content;
    if (aspect != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: singleMaxHeight),
        child: AspectRatio(
          aspectRatio: aspect,
          child: _buildSingle(url, aspect),
        ),
      );
    } else {
      content = FutureBuilder<double>(
        future: _resolveAspect(url),
        builder: (context, snap) {
          final ar = snap.data;
          if (ar != null) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: singleMaxHeight),
              child: AspectRatio(aspectRatio: ar, child: _buildSingle(url, ar)),
            );
          }
          // 로딩 중 placeholder (높이 비율)
          return Container(
            height: singleMaxHeight * 0.6,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap == null ? null : () => widget.onTap!(0),
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: content,
        ),
      ),
    );
  }

  Widget _buildSingle(String url, double aspect) {
    final cs = Theme.of(context).colorScheme;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(
        color: cs.surfaceContainer,
        child: Icon(
          SolarIconsOutline.gallery,
          color: cs.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }

  Future<double> _resolveAspect(String url) async {
    if (_aspectCache.containsKey(url)) return _aspectCache[url]!;
    final c = Completer<double>();
    final img = Image.network(url);
    final stream = img.image.resolve(const ImageConfiguration());
    late ImageStreamListener l;
    l = ImageStreamListener(
      (ImageInfo info, bool sync) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (w > 0 && h > 0) {
          final ar = w / h;
          _aspectCache[url] = ar;
          c.complete(ar);
        } else {
          c.complete(1.6); // fallback
        }
        stream.removeListener(l);
      },
      onError: (error, stack) {
        if (!c.isCompleted) c.complete(1.6);
        stream.removeListener(l);
      },
    );
    stream.addListener(l);
    return c.future;
  }
}

class _PostSkeleton extends StatelessWidget {
  final ColorScheme cs;
  const _PostSkeleton({required this.cs});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 8),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: Color.fromRGBO(0, 0, 0, 0.18),
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

class _ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImageViewerPage({required this.imageUrls, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 전체 화면을 차지하는 이미지 뷰어
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: cs.surfaceContainer,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  SolarIconsOutline.gallery,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '이미지를 불러올 수 없습니다',
                                  style: AppTextStyles.primaryText(
                                    context,
                                  ).copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // 상단 AppBar 영역
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: AppTextStyles.primaryText(
                  context,
                ).copyWith(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab content widget with proper selected/unselected states
class _TabContent extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _TabContent({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? cs
                  .primary // Selected: Primary color background
            : cs.surfaceContainerHighest, // Unselected: Gray background
        border: Border.all(
          color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.2),
          width: isSelected ? 0 : 1,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.chipLabel(context).copyWith(
          color: isSelected
              ? cs
                    .onPrimary // Selected: White text
              : cs.onSurfaceVariant, // Unselected: Gray text
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

/// Empty state widget shown when no posts are available
class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            SolarIconsOutline.documentText,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            '게시글이 없어요',
            style: AppTextStyles.sectionTitle(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Text(
            '처음으로 글을 남겨보세요!',
            style: AppTextStyles.secondaryText(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
