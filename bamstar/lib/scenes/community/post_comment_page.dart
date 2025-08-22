import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'dart:ui';
import 'package:bamstar/services/avatar_helper.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:bamstar/scenes/community/community_constants.dart';
import 'package:bamstar/services/user_service.dart' as us;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

// Simple in-memory cache for author lookups to avoid refetching repeatedly.
final Map<String, us.AppUser?> _authorCache = {};

Future<us.AppUser?> _getAuthor(String? id) async {
  if (id == null) return null;
  if (_authorCache.containsKey(id)) return _authorCache[id];
  try {
    debugPrint('[post_comment] _getAuthor: fetching user id=$id');
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
        '[post_comment] _getAuthor: fetched user id=${u.id} nickname=${u.nickname}',
      );
      _authorCache[id] = u;
      return u;
    }
  } catch (_) {}
  _authorCache[id] = null;
  debugPrint('[post_comment] _getAuthor: no user found for id=$id');
  return null;
}

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
      } catch (_) {}
    }
    for (final id in ids) {
      if (!_authorCache.containsKey(id)) _authorCache[id] = null;
    }
  } catch (_) {}
}

// Simple vertical dashed line used to indicate threaded replies.
class VerticalDashedLine extends StatelessWidget {
  final Color color;
  final double thickness;
  final double dashHeight;
  final double dashGap;
  const VerticalDashedLine({
    Key? key,
    required this.color,
    this.thickness = 1.0,
    this.dashHeight = 4.0,
    this.dashGap = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(thickness, constraints.maxHeight),
          painter: _VerticalDashedLinePainter(
            color: color,
            thickness: thickness,
            dashHeight: dashHeight,
            dashGap: dashGap,
          ),
        );
      },
    );
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashHeight;
  final double dashGap;
  _VerticalDashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashHeight,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;
    double y = 0;
    while (y < size.height) {
      final end = (y + dashHeight).clamp(0.0, size.height);
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, end),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// This page is designed to be shown inside a WoltModalSheet as a page.
// It displays recent comments for a post and a top input to create a comment.
class PostCommentPage extends StatefulWidget {
  final CommunityPost post;
  const PostCommentPage({super.key, required this.post});

  /// Helper that builds a `WoltModalSheetPage` for this comment UI so callers
  /// can include it in `WoltModalSheet.show(pageListBuilder: ...)`.
  static WoltModalSheetPage woltPage(
    BuildContext modalContext,
    CommunityPost post,
  ) {
    return WoltModalSheetPage(
      pageTitle: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          '댓글',
          style: Theme.of(
            modalContext,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      leadingNavBarWidget: IconButton(
        visualDensity: VisualDensity.compact,
        icon: const Icon(SolarIconsOutline.arrowLeft, size: 20),
        onPressed: () => Navigator.of(modalContext).pop(),
      ),
      trailingNavBarWidget: IconButton(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        icon: const Icon(SolarIconsOutline.closeCircle, size: 20),
        onPressed: () => Navigator.of(modalContext).pop(),
      ),
      // Use a modal-specific child (no Scaffold) to avoid nesting a full
      // Scaffold inside the WoltModalSheet page which can hide content.
      child: Builder(
        builder: (ctx) {
          return _PostCommentModalChild(post: post);
        },
      ),
    );
  }

  @override
  State<PostCommentPage> createState() => _PostCommentPageState();
}

class _PostCommentPageState extends State<PostCommentPage> {
  final TextEditingController _commentCtl = TextEditingController();
  bool _isPosting = false;
  int? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  final Set<int> _likedCommentIds = {};
  final Map<int, int> _commentLikeCounts = {};

  @override
  void initState() {
    super.initState();
    _commentsFuture = CommunityRepository.instance
        .fetchCommentsForPost(widget.post.id, limit: 50)
        .then((comments) async {
          await _prefetchCommentAuthors(comments);
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
              if (mounted)
                setState(() {
                  _commentLikeCounts.addAll(counts);
                  _likedCommentIds.addAll(liked);
                });
            }
          } catch (_) {}
          return comments;
        });
    // reply focus listener: hide reply input on focus loss
    _replyFocusNode.addListener(() {
      if (!_replyFocusNode.hasFocus && mounted) {
        setState(() {
          _replyingToCommentId = null;
        });
        try {
          _replyController.clear();
        } catch (_) {}
      }
    });
  }

  void _reload() {
    setState(() {
      _commentsFuture = CommunityRepository.instance
          .fetchCommentsForPost(widget.post.id, limit: 50)
          .then((comments) async {
            await _prefetchCommentAuthors(comments);
            return comments;
          });
    });
  }

  Future<void> _submitReply({required int parentId}) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final ok = await CommunityRepository.instance.createComment(
      postId: widget.post.id,
      content: text,
      parentCommentId: parentId,
      isAnonymous: false,
    );
    if (ok) {
      try {
        _replyController.clear();
      } catch (_) {}
      try {
        _replyFocusNode.unfocus();
      } catch (_) {}
      _reload();
    } else {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('댓글 전송에 실패했습니다')));
      } catch (_) {}
    }
  }

  Future<void> _submit() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    if (_isPosting) return;
    setState(() => _isPosting = true);
    final ok = await CommunityRepository.instance.createComment(
      postId: widget.post.id,
      content: text,
      isAnonymous: false,
    );
    if (ok) {
      _commentCtl.clear();
      _reload();
    } else {
      try {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('댓글 전송에 실패했습니다')));
      } catch (_) {}
    }
    if (mounted) setState(() => _isPosting = false);
  }

  Widget _buildCommentRow(
    Map<String, dynamic> c,
    TextTheme tt,
    ColorScheme cs,
  ) {
    final isAnon = (c['is_anonymous'] as bool?) ?? false;
    final authorId = c['author_id'] as String?;
    final fallbackName = (c['author_name'] as String?) ?? '스타';
    final fallbackAvatar = (c['author_avatar_url'] as String?) ?? '';
    final content = (c['content'] as String?) ?? '';
    final createdAt =
        DateTime.tryParse(c['created_at'] as String? ?? '') ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FutureBuilder<us.AppUser?>(
        future: _getAuthor(authorId),
        builder: (context, snap) {
          final user = snap.data;

          final authorName = isAnon
              ? '익명의 스타'
              : ((user != null && (user.nickname.isNotEmpty))
                    ? user.nickname
                    : fallbackName);

          String? candidateUrl;
          if (user != null) {
            final p = (user.data['profile_img'] as String?)?.trim();
            if (p != null && p.isNotEmpty) candidateUrl = p;
          }
          if ((candidateUrl == null || candidateUrl.isEmpty) &&
              fallbackAvatar.isNotEmpty) {
            candidateUrl = fallbackAvatar;
          }
          if (isAnon && (candidateUrl == null || candidateUrl.isEmpty)) {
            candidateUrl = null;
          }

          ImageProvider? avatarImage;
          if (candidateUrl != null && candidateUrl.isNotEmpty) {
            avatarImage = avatarImageProviderFromUrl(
              candidateUrl,
              width: 72,
              height: 72,
            );
          }

          Widget avatarWidget;
          if (isAnon && avatarImage != null) {
            avatarWidget = SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Image(
                    image: avatarImage,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          } else if (isAnon && avatarImage == null) {
            avatarWidget = SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 36,
                    height: 36,
                    color: cs.secondaryContainer,
                    child: Center(
                      child: Icon(
                        SolarIconsOutline.incognito,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            avatarWidget = CircleAvatar(
              radius: 18,
              backgroundColor: isAnon ? cs.secondaryContainer : null,
              backgroundImage: avatarImage,
              child: (!isAnon && avatarImage == null)
                  ? Icon(Icons.person, size: 18, color: cs.onSurfaceVariant)
                  : null,
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: avatar + optional thread line for replies
              Column(children: [avatarWidget]),
              const SizedBox(width: 12),
              // Thread and content: thread line sits on the left edge of content
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(authorName, style: tt.titleSmall),
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
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final cid = (c['id'] as int?) ?? -1;
                                      if (cid < 0) return;
                                      setState(() {
                                        final cur = _commentLikeCounts[cid] ?? 0;
                                        if (_likedCommentIds.contains(cid)) {
                                          _likedCommentIds.remove(cid);
                                          _commentLikeCounts[cid] = (cur - 1)
                                              .clamp(0, 999999);
                                        } else {
                                          _likedCommentIds.add(cid);
                                          _commentLikeCounts[cid] = cur + 1;
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
                                                  (_commentLikeCounts[cid] ?? 1) -
                                                  1;
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
                                                  (_commentLikeCounts[cid] ?? 0) +
                                                  1;
                                            });
                                          }
                                        }
                                      } catch (_) {}
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
                                  // Only allow replies to top-level comments
                                  GestureDetector(
                                    onTap: () {
                                      final cid = (c['id'] as int?) ?? -1;
                                      if (cid < 0) return;
                                      // if this comment is itself a reply, don't open reply
                                      if ((c['parent_comment_id'] as int?) != null) return;
                                      debugPrint('[post_comment] reply tap cid=$cid');
                                      setState(() {
                                        _replyingToCommentId =
                                            _replyingToCommentId == cid ? null : cid;
                                      });
                                      if (_replyingToCommentId == cid) {
                                        Future.delayed(const Duration(milliseconds: 50), () {
                                          if (mounted) _replyFocusNode.requestFocus();
                                        });
                                      } else {
                                        _replyFocusNode.unfocus();
                                      }
                                    },
                                    child: Text(
                                      '댓글 쓰기',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: _replyingToCommentId == (c['id'] as int?)
                                    ? Padding(
                                        key: ValueKey('reply-input-${c['id']}'),
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _replyController,
                                                focusNode: _replyFocusNode,
                                                decoration: const InputDecoration(
                                                  hintText: '답글을 작성하세요',
                                                ),
                                                textInputAction: TextInputAction.send,
                                                onSubmitted: (_) => _submitReply(parentId: (c['id'] as int?) ?? -1),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () => _submitReply(parentId: (c['id'] as int?) ?? -1),
                                              icon: const Icon(Icons.send),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Keep a normal widget build (fallback) so this page can also be
    // pushed via Navigator. For WoltModalSheet usage, use the
    // static helper `PostCommentPage.woltPage` below.
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: const Icon(SolarIconsOutline.arrowLeft, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('댓글', style: tt.titleLarge),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              // recent interactors avatar stack
              FutureBuilder<List<String>>(
                future: CommunityRepository.instance.getPostCommenterAvatars(
                  widget.post.id,
                  limit: 3,
                ),
                builder: (context, snap) {
                  final avatars = snap.data ?? [];
                  if (avatars.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: local.AvatarStack(
                        avatarUrls: avatars,
                        avatarSize: CommunitySizes.avatarBase,
                        overlapFactor: 0.5,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _commentsFuture,
                  builder: (context, snap) {
                    final comments = snap.data ?? [];
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('댓글이 없습니다', style: tt.bodyMedium),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: ListView.builder(
                        itemCount: comments.length + 1,
                        itemBuilder: (context, index) {
                          if (index == comments.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: cs.outline.withOpacity(0.3),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 6,
                                      ),
                                    ),
                                    child: const Text(
                                      'Show more comments',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          final c = comments[index];
                          return _buildCommentRow(c, tt, cs);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              Expanded(
                child: Transform.scale(
                  scale: 0.7,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtl,
                            decoration: const InputDecoration.collapsed(
                              hintText: '댓글 내용을 작성해주세요',
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isPosting ? null : _submit,
                          icon: Icon(
                            Icons.send,
                            color: _isPosting
                                ? cs.onSurfaceVariant
                                : cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _commentCtl.dispose();
    } catch (_) {}
    super.dispose();
  }
}

// Modal-only content widget used inside WoltModalSheet pages. This is a
// compact, self-contained copy of the comment list + bottom input used by
// `PostCommentPage`, but without an AppBar/Scaffold so it renders correctly
// inside the modal container.
class _PostCommentModalChild extends StatefulWidget {
  final CommunityPost post;
  const _PostCommentModalChild({Key? key, required this.post})
    : super(key: key);

  @override
  State<_PostCommentModalChild> createState() => _PostCommentModalChildState();
}

class _PostCommentModalChildState extends State<_PostCommentModalChild> {
  final TextEditingController _commentCtl = TextEditingController();
  bool _isPosting = false;
  int? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  final Set<int> _likedCommentIds = {};
  final Map<int, int> _commentLikeCounts = {};

  @override
  void initState() {
    super.initState();
    _commentsFuture = CommunityRepository.instance
        .fetchCommentsForPost(widget.post.id, limit: 50)
        .then((comments) async {
          await _prefetchCommentAuthors(comments);
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
              if (mounted)
                setState(() {
                  _commentLikeCounts.addAll(counts);
                  _likedCommentIds.addAll(liked);
                });
            }
          } catch (_) {}
          return comments;
        });
    _replyFocusNode.addListener(() {
      if (!_replyFocusNode.hasFocus && mounted) {
        setState(() {
          _replyingToCommentId = null;
        });
        try {
          _replyController.clear();
        } catch (_) {}
      }
    });
  }

  void _reload() {
    setState(() {
      _commentsFuture = CommunityRepository.instance
          .fetchCommentsForPost(widget.post.id, limit: 50)
          .then((comments) async {
            await _prefetchCommentAuthors(comments);
            return comments;
          });
    });
  }

  Future<void> _submitReply({required int parentId}) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final ok = await CommunityRepository.instance.createComment(
      postId: widget.post.id,
      content: text,
      parentCommentId: parentId,
      isAnonymous: false,
    );
    if (ok) {
      try {
        _replyController.clear();
      } catch (_) {}
      try {
        _replyFocusNode.unfocus();
      } catch (_) {}
      _reload();
    } else {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('댓글 전송에 실패했습니다')));
      } catch (_) {}
    }
  }

  Future<void> _submit() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    if (_isPosting) return;
    setState(() => _isPosting = true);
    final ok = await CommunityRepository.instance.createComment(
      postId: widget.post.id,
      content: text,
      isAnonymous: false,
    );
    if (ok) {
      _commentCtl.clear();
      _reload();
    } else {
      try {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('댓글 전송에 실패했습니다')));
      } catch (_) {}
    }
    if (mounted) setState(() => _isPosting = false);
  }

  Widget _buildCommentRow(
    Map<String, dynamic> c,
    TextTheme tt,
    ColorScheme cs,
  ) {
    final isAnon = (c['is_anonymous'] as bool?) ?? false;
    final authorId = c['author_id'] as String?;
    final fallbackName = (c['author_name'] as String?) ?? '스타';
    final fallbackAvatar = (c['author_avatar_url'] as String?) ?? '';
    final content = (c['content'] as String?) ?? '';
    final createdAt =
        DateTime.tryParse(c['created_at'] as String? ?? '') ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FutureBuilder<us.AppUser?>(
        future: _getAuthor(authorId),
        builder: (context, snap) {
          final user = snap.data;

          final authorName = isAnon
              ? '익명의 스타'
              : ((user != null && (user.nickname.isNotEmpty))
                    ? user.nickname
                    : fallbackName);

          String? candidateUrl;
          if (user != null) {
            final p = (user.data['profile_img'] as String?)?.trim();
            if (p != null && p.isNotEmpty) candidateUrl = p;
          }
          if ((candidateUrl == null || candidateUrl.isEmpty) &&
              fallbackAvatar.isNotEmpty) {
            candidateUrl = fallbackAvatar;
          }
          if (isAnon && (candidateUrl == null || candidateUrl.isEmpty)) {
            candidateUrl = null;
          }

          ImageProvider? avatarImage;
          if (candidateUrl != null && candidateUrl.isNotEmpty) {
            avatarImage = avatarImageProviderFromUrl(
              candidateUrl,
              width: 72,
              height: 72,
            );
          }

          Widget avatarWidget;
          if (isAnon && avatarImage != null) {
            avatarWidget = SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Image(
                    image: avatarImage,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          } else if (isAnon && avatarImage == null) {
            avatarWidget = SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 36,
                    height: 36,
                    color: cs.secondaryContainer,
                    child: Center(
                      child: Icon(
                        SolarIconsOutline.incognito,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            avatarWidget = CircleAvatar(
              radius: 18,
              backgroundColor: isAnon ? cs.secondaryContainer : null,
              backgroundImage: avatarImage,
              child: (!isAnon && avatarImage == null)
                  ? Icon(Icons.person, size: 18, color: cs.onSurfaceVariant)
                  : null,
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [avatarWidget]),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(authorName, style: tt.titleSmall),
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
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final cid = (c['id'] as int?) ?? -1;
                                      if (cid < 0) return;
                                      setState(() {
                                        final cur = _commentLikeCounts[cid] ?? 0;
                                        if (_likedCommentIds.contains(cid)) {
                                          _likedCommentIds.remove(cid);
                                          _commentLikeCounts[cid] = (cur - 1)
                                              .clamp(0, 999999);
                                        } else {
                                          _likedCommentIds.add(cid);
                                          _commentLikeCounts[cid] = cur + 1;
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
                                                  (_commentLikeCounts[cid] ?? 1) -
                                                  1;
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
                                                  (_commentLikeCounts[cid] ?? 0) +
                                                  1;
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
                                  GestureDetector(
                                    onTap: () {
                                      final cid = (c['id'] as int?) ?? -1;
                                      if (cid < 0) return;
                                      if ((c['parent_comment_id'] as int?) != null) return;
                                      debugPrint('[post_comment_modal] reply tap cid=$cid');
                                      setState(() {
                                        _replyingToCommentId =
                                            _replyingToCommentId == cid ? null : cid;
                                      });
                                      if (_replyingToCommentId == cid) {
                                        Future.delayed(const Duration(milliseconds: 50), () {
                                          if (mounted) _replyFocusNode.requestFocus();
                                        });
                                      } else {
                                        _replyFocusNode.unfocus();
                                      }
                                    },
                                    child: Text(
                                      '댓글 쓰기',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: _replyingToCommentId == (c['id'] as int?)
                                    ? Padding(
                                        key: ValueKey('reply-input-modal-${c['id']}'),
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _replyController,
                                                focusNode: _replyFocusNode,
                                                decoration: const InputDecoration(
                                                  hintText: '답글을 작성하세요',
                                                ),
                                                textInputAction: TextInputAction.send,
                                                onSubmitted: (_) => _submitReply(parentId: (c['id'] as int?) ?? -1),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () => _submitReply(parentId: (c['id'] as int?) ?? -1),
                                              icon: const Icon(Icons.send),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _commentsFuture,
              builder: (context, snap) {
                final comments = snap.data ?? [];
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (comments.isEmpty) {
                  return Center(child: Text('댓글이 없습니다', style: tt.bodyMedium));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return _buildCommentRow(c, tt, cs);
                  },
                );
              },
            ),
          ),
          // Bottom input (sticky)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: Transform.scale(
                      scale: 0.7,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.06),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentCtl,
                                decoration: const InputDecoration.collapsed(
                                  hintText: '댓글 내용을 작성해주세요',
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _submit(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: IconButton(
                                onPressed: _isPosting ? null : _submit,
                                icon: Icon(Icons.send, color: cs.onPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      _commentCtl.dispose();
    } catch (_) {}
    super.dispose();
  }
}
