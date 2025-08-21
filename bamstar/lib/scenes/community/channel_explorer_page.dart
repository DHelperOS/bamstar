import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:bamstar/widgets/pull_refresh_indicator.dart';

class ChannelExplorerPage extends StatefulWidget {
  const ChannelExplorerPage({super.key});

  @override
  State<ChannelExplorerPage> createState() => _ChannelExplorerPageState();
}

class _ChannelExplorerPageState extends State<ChannelExplorerPage> {
  List<HashtagChannel> _channels = const [];
  String _q = '';
  bool _loading = false;
  List<String> _categories = const ['전체'];
  int _selectedCategoryIndex = 0;
  // pull-to-refresh state
  double _pullPixels = 0.0; // current overscroll pixels (>= 0)
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await CommunityRepository.instance.fetchAllHashtags(
      query: _q,
      limit: 24,
    );
    if (!mounted) return;
    setState(() {
      _channels = res;
      _loading = false;
      // Build categories from channels (null => '기타'), add '전체' at index 0
      final set = <String>{};
      for (final c in _channels) {
        set.add((c.category ?? '기타'));
      }
      final list = set.toList()..sort();
      final newCats = ['📂 전체', ...list];
      _categories = newCats;
      if (_selectedCategoryIndex >= _categories.length) {
        _selectedCategoryIndex = 0;
      }
    });

    // Note: live subscriber counts removed; UI uses c.subscriberCount only

    // subscribed tab was removed per request; no need to fetch subscribed channels here
  }

  // Handle actual refresh action
  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    try {
      await _load();
      // small delay for UX polish
      await Future.delayed(const Duration(milliseconds: 200));
    } finally {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _pullPixels = 0.0;
      });
    }
  }

  // Track pull extent from scroll notifications
  bool _onScrollNotification(ScrollNotification n) {
    // Only track when not actively showing skeletons
    if (_loading) return false;
    // Handle different notification types so this works across platforms
    if (n is OverscrollNotification) {
      // OverscrollNotification.overscroll is positive when dragging past the edge
      // On some platforms the sign/behavior differs; treat any overscroll as pull when extentBefore==0
      if (n.metrics.extentBefore <= 0) {
        final overscroll = n.overscroll.abs();
        final next = (_pullPixels + overscroll).clamp(0.0, 200.0);
        setState(() => _pullPixels = next);
      }
    } else if (n is ScrollUpdateNotification) {
      // Some platforms report negative metrics.pixels while dragging; handle that too
      final metrics = n.metrics;
      if (metrics.pixels <= 0 && metrics.extentBefore <= 0) {
        final overscrollFromPixels = (-metrics.pixels).clamp(0.0, 200.0);
        setState(() => _pullPixels = overscrollFromPixels);
      } else {
        if (_pullPixels != 0) setState(() => _pullPixels = 0.0);
      }
    } else if (n is ScrollEndNotification) {
      // scroll ended; leave handling to caller (caller checks _pullPixels threshold)
      // no-op here
    }
    return false; // allow others (RefreshIndicator) to also receive
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String? selectedCat =
        (_selectedCategoryIndex <= 0 ||
            _selectedCategoryIndex >= _categories.length)
        ? null
        : _categories[_selectedCategoryIndex];
    final filtered = selectedCat == null
        ? _channels
        : _channels.where((c) => (c.category ?? '기타') == selectedCat).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('채널 탐색'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(SolarIconsOutline.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '채널 검색 (#없이 입력)',
                prefixIcon: Icon(SolarIconsOutline.magnifier),
              ),
              onChanged: (v) {
                setState(() => _q = v.trim());
                _load();
              },
            ),
          ),
          // Category TabBar
          DefaultTabController(
            length: _categories.length,
            initialIndex:
                (_selectedCategoryIndex >= 0 &&
                    _selectedCategoryIndex < _categories.length)
                ? _selectedCategoryIndex
                : 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                // reduced horizontal padding to make tabs tighter
                padding: const EdgeInsets.symmetric(horizontal: 4),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabAlignment: TabAlignment.start,
                // show primary-colored underline for the selected tab
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: cs.primary, width: 2),
                  insets: const EdgeInsets.symmetric(horizontal: 6),
                ),
                dividerColor: Colors.transparent,
                labelColor: cs.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
                onTap: (i) => setState(() => _selectedCategoryIndex = i),
                tabs: _categories.map((c) => Tab(text: c)).toList(),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Custom scroll handling: NotificationListener will track overscroll
                NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    // track pull amount
                    final handled = _onScrollNotification(n);
                    // if the scroll ended and user pulled enough, trigger refresh
                    if (n is ScrollEndNotification) {
                      // User released the drag; trigger refresh only if pulled sufficiently
                      if (!_refreshing && _pullPixels > 64) {
                        _handleRefresh();
                      } else {
                        // reset small pulls for UX
                        if (_pullPixels > 0 && _pullPixels <= 64) {
                          setState(() => _pullPixels = 0.0);
                        }
                      }
                    }
                    return handled;
                  },
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      // increase aspect ratio to make cards shorter (less tall)
                      // increase denominator to make tiles slightly taller
                      // this avoids the RenderFlex overflow when card vertical spacing increased
                      childAspectRatio: 3 / 2.0,
                    ),
                    itemCount: _loading ? 6 : filtered.length,
                    itemBuilder: (context, i) {
                      if (_loading) return const _ChannelCardSkeleton();
                      final c = filtered[i];
                      return _ChannelCard(key: ValueKey(c.id), channel: c);
                    },
                  ),
                ),
                // Custom indicator overlay (app icon spinning + sparkles)
                Positioned(
                  top: 4,
                  left: 0,
                  right: 0,
                  height: 72,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      // require a slightly larger pull to avoid tiny flicker
                      opacity: (_refreshing || _pullPixels > 12) ? 1 : 0,
                      child: Center(
                        child: AppPullRefreshIndicator(
                          progress: (_pullPixels / 80.0).clamp(0.0, 1.5),
                          spinning: _refreshing,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatefulWidget {
  final HashtagChannel channel;
  const _ChannelCard({super.key, required this.channel});
  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

// Simple skeleton placeholder for a channel card
class _ChannelCardSkeleton extends StatelessWidget {
  const _ChannelCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final placeholder = theme.brightness == Brightness.dark
        ? cs.surfaceContainer
        : cs.surfaceContainerLowest;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      color: placeholder,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        // slightly larger card padding for better breathing room
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // left icon + count placeholder
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Skeleton.replace(
                      width: 16,
                      height: 16,
                      child: Container(color: placeholder),
                    ),
                    const SizedBox(height: 6),
                    Skeleton.replace(
                      width: 24,
                      height: 10,
                      child: Container(color: placeholder),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Skeleton.replace(
                    height: 18,
                    child: Container(color: placeholder),
                  ),
                ),
                const SizedBox(width: 6),
                Skeleton.replace(
                  width: 22,
                  height: 22,
                  child: Container(color: placeholder),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Skeleton.replace(height: 12, child: Container(color: placeholder)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Skeleton.replace(
                width: 48,
                height: 28,
                child: Container(color: placeholder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelCardState extends State<_ChannelCard> {
  bool _subscribed = false;
  final JustTheController _tooltip = JustTheController();
  // Note: using model's subscriberCount (c.subscriberCount) only

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(covariant _ChannelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the channel changed (e.g., tab/category switched), re-check subscription
    if (oldWidget.channel.id != widget.channel.id) {
      _check();
    }
  }

  Future<void> _check() async {
    final ok = await CommunityRepository.instance.isSubscribed(
      hashtagId: widget.channel.id,
    );
    if (!mounted) return;
    setState(() {
      _subscribed = ok;
    });
  }

  Future<bool> _toggle() async {
    bool ok;
    if (_subscribed) {
      ok = await CommunityRepository.instance.unsubscribeFromChannel(
        hashtagId: widget.channel.id,
      );
    } else {
      ok = await CommunityRepository.instance.subscribeToChannel(
        hashtagId: widget.channel.id,
      );
    }
    if (!mounted) return false;
    setState(() {
      if (ok) {
        _subscribed = !_subscribed;
      }
    });
    return ok;
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '오래 전';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    // show weeks for up to ~4 weeks
    final weeks = (diff.inDays / 7).floor();
    if (weeks >= 1 && weeks < 5) return '${weeks}주일 전';
    // older: show full date
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.channel;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cs.onSurface.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      color: cs.surface,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.30),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        // slightly larger padding inside cards to match updated spacing
        padding: const EdgeInsets.fromLTRB(16, 6, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with name+info on the right (icon+count moved to bottom-left)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '#${c.name}',
                    // use headlineSmall as h4 equivalent but reduced size
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                JustTheTooltip(
                  controller: _tooltip,
                  preferredDirection: AxisDirection.down,
                  isModal: false,
                  backgroundColor: cs.primary,
                  margin: const EdgeInsets.only(left: 4),
                  content: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        (c.description?.isNotEmpty == true)
                            ? c.description!
                            : '설명이 없습니다.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    // slightly reduce icon visual size/hit constraints
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    icon: const Icon(SolarIconsOutline.infoCircle, size: 18),
                    color: cs.primary,
                    onPressed: () => _tooltip.showTooltip(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            // Stats: each number right-aligned next to its label
            Row(
              children: [
                // 게시글 수 (label left, number right)
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '게시글 수',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${c.postCount}',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 구독자 수 (label left, number right)
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '구독자 수',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${c.subscriberCount}',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row: icon+count on left, subscribe button on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // show last used time on the left with a clock icon (e.g. '12분 전')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SolarIconsOutline.calendarMinimalistic,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimeAgo(c.lastUsedAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // subscribe toggle using LoadSwitch (compact)
                _AsyncToggleSwitch(
                  value: _subscribed,
                  width: 52,
                  height: 26,
                  onTap: () async {
                    await _toggle();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Lightweight async toggle switch without spinner; disables during async.
class _AsyncToggleSwitch extends StatefulWidget {
  final bool value;
  final Future<void> Function() onTap;
  final double width;
  final double height;

  const _AsyncToggleSwitch({
    required this.value,
    required this.onTap,
    this.width = 52,
    this.height = 26,
  });

  @override
  State<_AsyncToggleSwitch> createState() => _AsyncToggleSwitchState();
}

class _AsyncToggleSwitchState extends State<_AsyncToggleSwitch> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOn = widget.value;
    final trackColor = isOn
        ? cs.primary
        : cs.onSurface.withValues(alpha: 0.04); // very pale gray when OFF
    final borderColor = isOn
        ? cs.primary.withValues(alpha: 0.0)
        : cs.outlineVariant.withValues(
            alpha: 0.08,
          ); // slightly lighter outline when OFF
    final thumbBorderColor = isOn
        ? Colors.transparent
        : cs.outlineVariant.withValues(
            alpha: 0.16,
          ); // slightly lighter thumb outline when OFF

    return AbsorbPointer(
      absorbing: _loading,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _loading ? 0.6 : 1.0,
        child: GestureDetector(
          onTap: () async {
            if (_loading) return;
            setState(() => _loading = true);
            try {
              await widget.onTap();
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final thumbSize = constraints.maxHeight - 6; // padding*2
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          alignment: isOn
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: thumbBorderColor,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
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
          ),
        ),
      ),
    );
  }
}

// _PullRefreshIndicator and _SparkleDot removed; use AppPullRefreshIndicator from widgets
