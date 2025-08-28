import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'dart:ui';
import 'dart:async';
import 'package:bamstar/services/avatar_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:bamstar/scenes/community/widgets/avatar_stack.dart' as local;
import 'package:bamstar/scenes/community/community_constants.dart';
import 'package:bamstar/services/user_service.dart' as us;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/toast_helper.dart';
import 'package:bamstar/services/cloudinary.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
// Theme imports removed as they're not used in current design implementation

// Image layout constants for comments (match feed gallery)
final double _commentSingleMaxHeight = CommunitySizes.imageSingleMaxHeight;
final double _commentThumbSize = CommunitySizes.imageThumbSize;
final double _commentThumbSpacing = CommunitySizes.imageThumbSpacing;

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

// Aspect ratio cache and resolver for comment images (match feed behavior)
final Map<String, double> _commentAspectCache = {};

Future<double> _resolveCommentAspect(String url) async {
  if (_commentAspectCache.containsKey(url)) return _commentAspectCache[url]!;
  final c = Completer<double>();
  final img = Image.network(url);
  final stream = img.image.resolve(const ImageConfiguration());
  late ImageStreamListener l;
  l = ImageStreamListener((ImageInfo info, bool sync) {
    final w = info.image.width.toDouble();
    final h = info.image.height.toDouble();
    if (w > 0 && h > 0) {
      final ar = w / h;
      _commentAspectCache[url] = ar;
      c.complete(ar);
    } else {
      c.complete(1.6);
    }
    stream.removeListener(l);
  }, onError: (error, stack) {
    if (!c.isCompleted) c.complete(1.6);
    stream.removeListener(l);
  });
  stream.addListener(l);
  return c.future;
}

// Simple vertical dashed line used to indicate threaded replies.
class VerticalDashedLine extends StatelessWidget {
  final Color color;
  final double thickness;
  final double dashHeight;
  final double dashGap;
  const VerticalDashedLine({
    super.key,
    required this.color,
    this.thickness = 1.0,
    this.dashHeight = 4.0,
    this.dashGap = 4.0,
  });

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
      backgroundColor: Theme.of(modalContext).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      pageTitle: null,
      leadingNavBarWidget: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Text(
          '댓글',
          style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailingNavBarWidget: Container(
        margin: const EdgeInsets.only(right: 20.0),
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            Icons.close_rounded,
            size: 20,
            color: Theme.of(modalContext).colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            try {
              FocusScope.of(modalContext).unfocus();
            } catch (_) {}
            Navigator.of(modalContext).pop();
          },
        ),
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

  State<PostCommentPage> createState() => _PostCommentPageState();
}

class _PostCommentPageState extends State<PostCommentPage> {
  final TextEditingController _commentCtl = TextEditingController();

  int? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  final Set<int> _likedCommentIds = {};
  final Map<int, int> _commentLikeCounts = {};

  // 이미지 업로드 관련 필드들
  List<XFile> _selectedImages = [];
  List<XFile> _selectedReplyImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImages = false;

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

  /// Build a one-level comment tree from flat list (same strategy as
  /// community_home_page.dart).
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
        roots.add(Map<String, dynamic>.from(c));
      }
    }

    for (final r in roots) {
      final rid = (r['id'] as int?) ?? -1;
      r['children'] = childMap[rid] ?? <Map<String, dynamic>>[];
    }

    return roots;
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
        ToastHelper.error(context, '댓글 전송에 실패했습니다');
      } catch (_) {}
    }
  }

  Widget _buildCommentRow(
    Map<String, dynamic> c,
    TextTheme tt,
    ColorScheme cs, {
    bool isReply = false,
  }) {
    final isAnon = (c['is_anonymous'] as bool?) ?? false;
    final authorId = c['author_id'] as String?;
    final fallbackName = (c['author_name'] as String?) ?? '스타';
    final fallbackAvatar = (c['author_avatar_url'] as String?) ?? '';
    final content = (c['content'] as String?) ?? '';
    final createdAt =
        DateTime.tryParse(c['created_at'] as String? ?? '') ?? DateTime.now();

    // 이미지 참고 깨끔한 카드 디자인
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 32 : 0,
        bottom: 8,
        top: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<us.AppUser?>(
          future: _getAuthor(authorId),
          builder: (context, snap) {
          final user = snap.data;

          // Debug: log comment metadata when building the row
          try {
            debugPrint(
              '[post_comment] building row id=${c['id']} parent=${c['parent_comment_id']}',
            );
          } catch (_) {}

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

                                if (imageUrls.isEmpty) return const SizedBox.shrink();

                                // Single image: preserve intrinsic aspect ratio with max height
                                if (imageUrls.length == 1) {
                                  final url = imageUrls.first;
                                  return GestureDetector(
                                    onTap: () => _showImageViewer(context, imageUrls, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: _commentSingleMaxHeight,
                                        ),
                                        child: FutureBuilder<double>(
                                          future: _resolveCommentAspect(url),
                                          builder: (context, snap) {
                                            final ar = snap.data ?? 1.6;
                                            return AspectRatio(
                                              aspectRatio: ar,
                                              child: Image.network(
                                                url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: cs.surfaceContainer,
                                                    child: Center(
                                                      child: Icon(
                                                        SolarIconsOutline.gallery,
                                                        color: cs.onSurfaceVariant,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Multi-image: fixed square thumbnails using Wrap
                                return SizedBox(
                                  height: ((_commentThumbSize) * ((imageUrls.length / 2).ceil())) + (_commentThumbSpacing * (((imageUrls.length / 2).ceil() - 1).clamp(0, 10))),
                                  child: Wrap(
                                    spacing: _commentThumbSpacing,
                                    runSpacing: _commentThumbSpacing,
                                    children: List.generate(imageUrls.length, (index) {
                                      final url = imageUrls[index];
                                      return GestureDetector(
                                        onTap: () => _showImageViewer(context, imageUrls, index),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: _commentThumbSize,
                                            height: _commentThumbSize,
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: cs.surfaceContainer,
                                                  child: Center(
                                                    child: Icon(
                                                      SolarIconsOutline.gallery,
                                                      color: cs.onSurfaceVariant,
                                                      size: 20,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                          ],
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
                                        final cur =
                                            _commentLikeCounts[cid] ?? 0;
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
                                                  (_commentLikeCounts[cid] ??
                                                      1) -
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
                                                  (_commentLikeCounts[cid] ??
                                                      0) +
                                                  1;
                                            });
                                          }
                                        }
                                      } catch (_) {}
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
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
                                  if (!isReply)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        final cid = (c['id'] as int?) ?? -1;
                                        if (cid < 0) return;
                                        debugPrint(
                                          '[post_comment] reply press cid=$cid',
                                        );
                                        setState(() {
                                          _replyingToCommentId =
                                              _replyingToCommentId == cid
                                              ? null
                                              : cid;
                                        });
                                        debugPrint(
                                          '[post_comment] replyingTo=$_replyingToCommentId after setState',
                                        );
                                        if (mounted &&
                                            _replyingToCommentId == cid) {
                                          Future.microtask(() {
                                            debugPrint(
                                              '[post_comment] requesting focus for reply cid=$cid',
                                            );
                                            if (mounted)
                                              _replyFocusNode.requestFocus();
                                          });
                                        } else {
                                          try {
                                            _replyFocusNode.unfocus();
                                          } catch (_) {}
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: cs.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '댓글 쓰기',
                                            style: tt.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // 댓글 삭제 버튼 추가 (내가 작성한 댓글인 경우에만)
                                  Builder(
                                    builder: (context) {
                                      final currentUserId = Supabase
                                          .instance
                                          .client
                                          .auth
                                          .currentUser
                                          ?.id;
                                      final commentAuthorId =
                                          c['author_id'] as String?;
                                      final isMyComment =
                                          currentUserId != null &&
                                          commentAuthorId != null &&
                                          currentUserId == commentAuthorId;

                                      if (!isMyComment)
                                        return const SizedBox.shrink();

                                      return Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                    horizontal: 4,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            onPressed: () {
                                              final cid =
                                                  (c['id'] as int?) ?? -1;
                                              if (cid < 0) return;

                                              // 삭제 확인 다이얼로그 표시
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('댓글 삭제'),
                                                  content: const Text(
                                                    '이 댓글을 삭제하시겠습니까?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                      child: const Text('취소'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        // TODO: 댓글 삭제 API 호출
                                                        // await _deleteComment(cid);
                                                        ToastHelper.success(context, '댓글이 삭제되었습니다');
                                                      },
                                                      child: const Text('삭제'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  SolarIconsOutline
                                                      .trashBinTrash,
                                                  size: 14,
                                                  color: Colors.red[400],
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '삭제',
                                                  style: tt.bodySmall?.copyWith(
                                                    color: Colors.red[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              ClipRect(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, anim) =>
                                      SizeTransition(
                                        sizeFactor: anim,
                                        axisAlignment: -1.0,
                                        child: FadeTransition(
                                          opacity: anim,
                                          child: child,
                                        ),
                                      ),
                                  child:
                                      ((_replyingToCommentId ?? -1) ==
                                          ((c['id'] as int?) ?? -1))
                                      ? GestureDetector(
                                          key: ValueKey(
                                            'reply-input-${c['id']}',
                                          ),
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {}, // prevent tap-through
                                          onPanDown: (_) {
                                            // 외부 영역 탭 시 unfocus
                                            if (_replyFocusNode.hasFocus) {
                                              _replyFocusNode.unfocus();
                                              setState(
                                                () =>
                                                    _replyingToCommentId = null,
                                              );
                                            }
                                          },
                                          child: Builder(
                                            builder: (ctx) {
                                              debugPrint(
                                                '[post_comment] building reply-input for cid=${c['id']} (replying=$_replyingToCommentId)',
                                              );
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: cs.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: cs.outline
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    // Reply images preview
                                                    if (_selectedReplyImages
                                                        .isNotEmpty)
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        height: 60,
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              _selectedReplyImages
                                                                  .length,
                                                          itemBuilder: (context, index) {
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    right: 6,
                                                                  ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          6,
                                                                        ),
                                                                    child: Image.file(
                                                                      File(
                                                                        _selectedReplyImages[index]
                                                                            .path,
                                                                      ),
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      fit: BoxFit
                                                                          .cover,
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
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              2,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.black.withValues(
                                                                            alpha:
                                                                                0.7,
                                                                          ),
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child: const Icon(
                                                                          SolarIconsOutline
                                                                              .trashBinTrash,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              12,
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
                                                    // Reply input row
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 24,
                                                            child: TextField(
                                                              controller:
                                                                  _replyController,
                                                              focusNode:
                                                                  _replyFocusNode,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .send,
                                                              onSubmitted: (_) =>
                                                                  _submitReply(
                                                                    parentId:
                                                                        (c['id']
                                                                            as int?) ??
                                                                        -1,
                                                                  ),
                                                              decoration: InputDecoration(
                                                                hintText:
                                                                    '답글 작성',
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                border: OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Image attach button for reply
                                                        GestureDetector(
                                                          onTap:
                                                              _pickImagesForReply,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 4,
                                                                ),
                                                            child: Icon(
                                                              SolarIconsOutline
                                                                  .paperclip,
                                                              size: 16,
                                                              color: Colors
                                                                  .grey[500],
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(
                                                                minWidth: 28,
                                                                minHeight: 28,
                                                              ),
                                                          onPressed: () =>
                                                              _submitReply(
                                                                parentId:
                                                                    (c['id']
                                                                        as int?) ??
                                                                    -1,
                                                              ),
                                                          icon: Icon(
                                                            Icons.send,
                                                            size: 18,
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
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

  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Keep a normal widget build (fallback) so this page can also be
    // pushed via Navigator. For WoltModalSheet usage, use the
    // static helper `PostCommentPage.woltPage` below.
    return SafeArea(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            try {
              FocusScope.of(context).unfocus();
            } catch (_) {}
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: const Icon(SolarIconsOutline.arrowLeft, size: 20),
              onPressed: () {
                try {
                  FocusScope.of(context).unfocus();
                } catch (_) {}
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: Text('댓글', style: tt.titleLarge),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              try {
                FocusScope.of(context).unfocus();
              } catch (_) {}
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                children: [
                  // recent interactors avatar stack
                  FutureBuilder<List<String>>(
                    future: CommunityRepository.instance
                        .getPostCommenterAvatars(widget.post.id, limit: 3),
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
                          return Skeletonizer(
                            enabled: true,
                            child: ListView.separated(
                              itemCount: 6,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: CommunitySizes.avatarBase / 2,
                                      backgroundColor:
                                          cs.surfaceContainerHighest,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 12,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 14,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            height: 14,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.6,
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                        if (comments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('댓글이 없습니다', style: tt.bodyMedium),
                            ),
                          );
                        }
                        final roots = _buildCommentTree(comments);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTapDown: (_) {
                              try {
                                FocusScope.of(context).unfocus();
                                if (mounted)
                                  setState(() => _replyingToCommentId = null);
                              } catch (_) {}
                            },
                            child: ListView.builder(
                              itemCount: roots.length + 1,
                              itemBuilder: (context, index) {
                                if (index == roots.length) {
                                  return const SizedBox.shrink();
                                }
                                final root = roots[index];
                                final children =
                                    (root['children']
                                        as List<Map<String, dynamic>>?) ??
                                    <Map<String, dynamic>>[];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCommentRow(
                                      root,
                                      tt,
                                      cs,
                                      isReply: false,
                                    ),
                                    for (final ch in children)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 56.0,
                                        ),
                                        child: _buildCommentRow(
                                          ch,
                                          tt,
                                          cs,
                                          isReply: true,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // bottom input removed per request
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // 댓글 작성 모달 열기
              WoltModalSheet.show(
                context: context,
                pageListBuilder: (modalCtx) => [
                  WoltModalSheetPage(
                    backgroundColor: Theme.of(modalCtx).colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    pageTitle: null,
                    leadingNavBarWidget: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        '댓글 쓰기',
                        style: Theme.of(modalCtx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailingNavBarWidget: Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ),
                    child: Container(
                      color: Theme.of(modalCtx).colorScheme.surface,
                      height: MediaQuery.of(modalCtx).size.height * 0.7,
                      child: _PostCommentModalChild(post: widget.post),
                    ),
                  ),
                ],
              );
            },
            child: const Icon(SolarIconsOutline.pen),
          ),
        ),
      ),
    );
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
        // 최대 4개까지만 선택 가능
        final remainingSlots = 4 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          DelightToastBar(
            builder: (context) => ToastCard(
              color: Theme.of(context).colorScheme.primary,
              leading: const Icon(
                SolarIconsOutline.infoCircle,
                size: 28,
                color: Colors.white,
              ),
              title: Text(
                '최대 4개까지만 선택할 수 있습니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            position: DelightSnackbarPosition.top,
            autoDismiss: true,
            snackbarDuration: const Duration(seconds: 3),
          ).show(context);
        }
      }
    } catch (e) {
      DelightToastBar(
        builder: (context) => ToastCard(
          color: Theme.of(context).colorScheme.primary,
          leading: const Icon(
            SolarIconsOutline.dangerCircle,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            '이미지 선택 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
      ).show(context);
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
        // 최대 4개까지만 선택 가능
        final remainingSlots = 4 - _selectedReplyImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        setState(() {
          _selectedReplyImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          DelightToastBar(
            builder: (context) => ToastCard(
              color: Theme.of(context).colorScheme.primary,
              leading: const Icon(
                SolarIconsOutline.infoCircle,
                size: 28,
                color: Colors.white,
              ),
              title: Text(
                '최대 4개까지만 선택할 수 있습니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            position: DelightSnackbarPosition.top,
            autoDismiss: true,
            snackbarDuration: const Duration(seconds: 3),
          ).show(context);
        }
      }
    } catch (e) {
      DelightToastBar(
        builder: (context) => ToastCard(
          color: Theme.of(context).colorScheme.primary,
          leading: const Icon(
            SolarIconsOutline.dangerCircle,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            '이미지 선택 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  // 댓글용 이미지 제거
  void _removeImageFromComment(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 답글용 이미지 제거
  void _removeImageFromReply(int index) {
    setState(() {
      _selectedReplyImages.removeAt(index);
    });
  }

  // 이미지 업로드
  Future<List<String>> _uploadImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];

    for (final image in images) {
      try {
        final bytes = await image.readAsBytes();
        final url = await CloudinaryService.instance.uploadImageFromBytes(
          bytes,
          fileName: image.name,
          folder: 'comments',
        );
        uploadedUrls.add(url);
      } catch (e) {
        // 개별 이미지 업로드 실패는 무시하고 계속 진행
        continue;
      }
    }

    return uploadedUrls;
  }

  // 댓글 작성 제출
  Future<void> _submitComment() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    // 기본 댓글 제출 로직
    try {
      final success = await CommunityRepository.instance.createComment(
        postId: widget.post.id,
        content: text,
        isAnonymous: false,
        imageUrls: [],
      );
      if (success) {
        _commentCtl.clear();
        _reload();
      }
    } catch (e) {
      // 오류 처리
    }
  }

  // 이미지 뷰어 표시 함수
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

  void dispose() {
    try {
      _commentCtl.dispose();
    } catch (_) {}
    try {
      _replyController.dispose();
    } catch (_) {}
    try {
      _replyFocusNode.dispose();
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
  const _PostCommentModalChild({super.key, required this.post});

  State<_PostCommentModalChild> createState() => _PostCommentModalChildState();
}

class _PostCommentModalChildState extends State<_PostCommentModalChild> {
  final TextEditingController _commentCtl = TextEditingController();

  int? _replyingToCommentId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  final Set<int> _likedCommentIds = {};
  final Map<int, int> _commentLikeCounts = {};

  // 이미지 업로드 관련 필드들
  List<XFile> _selectedImages = [];
  List<XFile> _selectedReplyImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImages = false;

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
        roots.add(Map<String, dynamic>.from(c));
      }
    }

    for (final r in roots) {
      final rid = (r['id'] as int?) ?? -1;
      r['children'] = childMap[rid] ?? <Map<String, dynamic>>[];
    }

    return roots;
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
        ToastHelper.error(context, '댓글 전송에 실패했습니다');
      } catch (_) {}
    }
  }

  Widget _buildCommentRow(
    Map<String, dynamic> c,
    TextTheme tt,
    ColorScheme cs, {
    bool isReply = false,
  }) {
    final isAnon = (c['is_anonymous'] as bool?) ?? false;
    final authorId = c['author_id'] as String?;
    final fallbackName = (c['author_name'] as String?) ?? '스타';
    final fallbackAvatar = (c['author_avatar_url'] as String?) ?? '';
    final content = (c['content'] as String?) ?? '';
    final createdAt =
        DateTime.tryParse(c['created_at'] as String? ?? '') ?? DateTime.now();

    // 이미지 참고 깨끔한 카드 디자인
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 32 : 0,
        bottom: 8,
        top: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
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

                                if (imageUrls.isEmpty) return const SizedBox.shrink();

                                if (imageUrls.length == 1) {
                                  final url = imageUrls.first;
                                  return GestureDetector(
                                    onTap: () => _showImageViewer(context, imageUrls, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                        child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: _commentSingleMaxHeight,
                                        ),
                                        child: FutureBuilder<double>(
                                          future: _resolveCommentAspect(url),
                                          builder: (context, snap) {
                                            final ar = snap.data ?? 1.6;
                                            return AspectRatio(
                                              aspectRatio: ar,
                                              child: Image.network(
                                                url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: cs.surfaceContainer,
                                                    child: Center(
                                                      child: Icon(
                                                        SolarIconsOutline.gallery,
                                                        color: cs.onSurfaceVariant,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  height: ((_commentThumbSize) * ((imageUrls.length / 2).ceil())) + (_commentThumbSpacing * (((imageUrls.length / 2).ceil() - 1).clamp(0, 10))),
                                  child: Wrap(
                                    spacing: _commentThumbSpacing,
                                    runSpacing: _commentThumbSpacing,
                                    children: List.generate(imageUrls.length, (index) {
                                      final url = imageUrls[index];
                                      return GestureDetector(
                                        onTap: () => _showImageViewer(context, imageUrls, index),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: _commentThumbSize,
                                            height: _commentThumbSize,
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: cs.surfaceContainer,
                                                  child: Center(
                                                    child: Icon(
                                                      SolarIconsOutline.gallery,
                                                      color: cs.onSurfaceVariant,
                                                      size: 20,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                          ],
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
                                        final cur =
                                            _commentLikeCounts[cid] ?? 0;
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
                                                  (_commentLikeCounts[cid] ??
                                                      1) -
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
                                                  (_commentLikeCounts[cid] ??
                                                      0) +
                                                  1;
                                            });
                                          }
                                        }
                                      } catch (_) {
                                        setState(() {
                                          if (_likedCommentIds.contains(cid)) {
                                            _likedCommentIds.remove(cid);
                                            _commentLikeCounts[cid] =
                                                (_commentLikeCounts[cid] ?? 1) -
                                                1;
                                          } else {
                                            _likedCommentIds.add(cid);
                                            _commentLikeCounts[cid] =
                                                (_commentLikeCounts[cid] ?? 0) +
                                                1;
                                          }
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
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
                                  if (!isReply)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        final cid = (c['id'] as int?) ?? -1;
                                        if (cid < 0) return;
                                        debugPrint(
                                          '[post_comment_modal] reply press cid=$cid',
                                        );
                                        setState(() {
                                          _replyingToCommentId =
                                              _replyingToCommentId == cid
                                              ? null
                                              : cid;
                                        });
                                        debugPrint(
                                          '[post_comment_modal] replyingTo=$_replyingToCommentId after setState',
                                        );
                                        if (mounted &&
                                            _replyingToCommentId == cid) {
                                          Future.microtask(() {
                                            debugPrint(
                                              '[post_comment_modal] requesting focus for reply cid=$cid',
                                            );
                                            if (mounted)
                                              _replyFocusNode.requestFocus();
                                          });
                                        } else {
                                          try {
                                            _replyFocusNode.unfocus();
                                          } catch (_) {}
                                        }
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: cs.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '댓글 쓰기',
                                            style: tt.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // 댓글 삭제 버튼 추가 (내가 작성한 댓글인 경우에만)
                                  Builder(
                                    builder: (context) {
                                      final currentUserId = Supabase
                                          .instance
                                          .client
                                          .auth
                                          .currentUser
                                          ?.id;
                                      final commentAuthorId =
                                          c['author_id'] as String?;
                                      final isMyComment =
                                          currentUserId != null &&
                                          commentAuthorId != null &&
                                          currentUserId == commentAuthorId;

                                      if (!isMyComment)
                                        return const SizedBox.shrink();

                                      return Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                    horizontal: 4,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            onPressed: () {
                                              final cid =
                                                  (c['id'] as int?) ?? -1;
                                              if (cid < 0) return;

                                              // 삭제 확인 다이얼로그 표시
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('댓글 삭제'),
                                                  content: const Text(
                                                    '이 댓글을 삭제하시겠습니까?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                      child: const Text('취소'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        // TODO: 댓글 삭제 API 호출
                                                        // await _deleteComment(cid);
                                                        ToastHelper.success(context, '댓글이 삭제되었습니다');
                                                      },
                                                      child: const Text('삭제'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  SolarIconsOutline
                                                      .trashBinTrash,
                                                  size: 14,
                                                  color: Colors.red[400],
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '삭제',
                                                  style: tt.bodySmall?.copyWith(
                                                    color: Colors.red[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, anim) =>
                                    SizeTransition(
                                      sizeFactor: anim,
                                      axisAlignment: -1.0,
                                      child: FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                    ),
                                child:
                                    (!isReply &&
                                        _replyingToCommentId ==
                                            (c['id'] as int?))
                                    ? Container(
                                        key: ValueKey(
                                          'reply-input-modal-${c['id']}',
                                        ),
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cs.surface,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: cs.outline.withValues(
                                              alpha: 0.08,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 24,
                                                child: TextField(
                                                  controller: _replyController,
                                                  focusNode: _replyFocusNode,
                                                  textInputAction:
                                                      TextInputAction.send,
                                                  onSubmitted: (_) =>
                                                      _submitReply(
                                                        parentId:
                                                            (c['id'] as int?) ??
                                                            -1,
                                                      ),
                                                  decoration: InputDecoration(
                                                    hintText: '답글 작성',
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // file attach icon (match community_home_page style)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: GestureDetector(
                                                onTap: _pickImagesForReply,
                                                child: Icon(
                                                  SolarIconsOutline.paperclip,
                                                  size: 21,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                              onPressed: () => _submitReply(
                                                parentId:
                                                    (c['id'] as int?) ?? -1,
                                              ),
                                              icon: Icon(
                                                Icons.send,
                                                size: 18,
                                                color: Colors.grey[500],
                                              ),
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

  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
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
                final roots = _buildCommentTree(comments);
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (_) {
                    try {
                      FocusScope.of(context).unfocus();
                      if (mounted) setState(() => _replyingToCommentId = null);
                    } catch (_) {}
                  },
                  child: ListView.builder(
                    itemCount: roots.length,
                    itemBuilder: (context, index) {
                      final root = roots[index];
                      final children =
                          (root['children'] as List<Map<String, dynamic>>?) ??
                          <Map<String, dynamic>>[];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCommentRow(root, tt, cs, isReply: false),
                          for (final ch in children)
                            Padding(
                              padding: const EdgeInsets.only(left: 56.0),
                              child: _buildCommentRow(
                                ch,
                                tt,
                                cs,
                                isReply: true,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // 댓글 입력 UI (community_home_page 스타일)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: cs.surface,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Column(
                children: [
                  // Image preview section for modal
                  if (_selectedImages.isNotEmpty)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_selectedImages[index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImageFromComment(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.7,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        SolarIconsOutline.trashBinTrash,
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
                  // Input container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: TextFormField(
                              controller: _commentCtl,
                              onFieldSubmitted: (_) => _submitComment(),
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              decoration: const InputDecoration.collapsed(
                                hintText: '댓글 남기기',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            debugPrint(
                              '[_PostCommentModalChildState] Paperclip button tapped!',
                            );
                            _pickImagesForComment();
                          },
                          child: Icon(
                            SolarIconsOutline.paperclip,
                            size: 21,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: (_isUploadingImages) ? null : _submitComment,
                          child: _isUploadingImages
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  SolarIconsOutline.arrowRight,
                                  size: 21,
                                  color:
                                      (_commentCtl.text.trim().isEmpty &&
                                          _selectedImages.isEmpty)
                                      ? Colors.grey[400]
                                      : cs.primary,
                                ),
                        ),
                        const SizedBox(width: 8),
                      ],
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

  // 댓글용 이미지 선택
  Future<void> _pickImagesForComment() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // 최대 4개까지만 선택 가능
        final remainingSlots = 4 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          DelightToastBar(
            builder: (context) => ToastCard(
              color: Theme.of(context).colorScheme.primary,
              leading: const Icon(
                SolarIconsOutline.infoCircle,
                size: 28,
                color: Colors.white,
              ),
              title: Text(
                '최대 4개까지만 선택할 수 있습니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            position: DelightSnackbarPosition.top,
            autoDismiss: true,
            snackbarDuration: const Duration(seconds: 3),
          ).show(context);
        }
      }
    } catch (e) {
      DelightToastBar(
        builder: (context) => ToastCard(
          color: Theme.of(context).colorScheme.primary,
          leading: const Icon(
            SolarIconsOutline.dangerCircle,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            '이미지 선택 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
      ).show(context);
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
        // 최대 4개까지만 선택 가능
        final remainingSlots = 4 - _selectedReplyImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        setState(() {
          _selectedReplyImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          DelightToastBar(
            builder: (context) => ToastCard(
              color: Theme.of(context).colorScheme.primary,
              leading: const Icon(
                SolarIconsOutline.infoCircle,
                size: 28,
                color: Colors.white,
              ),
              title: Text(
                '최대 4개까지만 선택할 수 있습니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            position: DelightSnackbarPosition.top,
            autoDismiss: true,
            snackbarDuration: const Duration(seconds: 3),
          ).show(context);
        }
      }
    } catch (e) {
      DelightToastBar(
        builder: (context) => ToastCard(
          color: Theme.of(context).colorScheme.primary,
          leading: const Icon(
            SolarIconsOutline.dangerCircle,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            '이미지 선택 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
      ).show(context);
    }
  }

  // 댓글용 이미지 제거
  void _removeImageFromComment(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 답글용 이미지 제거
  void _removeImageFromReply(int index) {
    setState(() {
      _selectedReplyImages.removeAt(index);
    });
  }

  // 이미지 업로드
  Future<List<String>> _uploadImages(List<XFile> images) async {
    final List<String> uploadedUrls = [];

    for (final image in images) {
      try {
        final bytes = await image.readAsBytes();
        final url = await CloudinaryService.instance.uploadImageFromBytes(
          bytes,
          fileName: image.name,
          folder: 'comments',
        );
        uploadedUrls.add(url);
      } catch (e) {
        // 개별 이미지 업로드 실패는 무시하고 계속 진행
        continue;
      }
    }

    return uploadedUrls;
  }

  // 댓글 작성 제출
  Future<void> _submitComment() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    setState(() {
      _isUploadingImages = true;
    });

    try {
      // 이미지 업로드
      List<String> uploadedUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedUrls = await _uploadImages(_selectedImages);
      }

      final success = await CommunityRepository.instance.createComment(
        postId: widget.post.id,
        content: text,
        isAnonymous: false,
        imageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
      );

      if (success) {
        _commentCtl.clear();
        setState(() {
          _selectedImages.clear();
        });
        _reload();

        DelightToastBar(
          builder: (context) => ToastCard(
            color: Theme.of(context).colorScheme.primary,
            leading: const Icon(
              SolarIconsOutline.checkCircle,
              size: 28,
              color: Colors.white,
            ),
            title: Text(
              '댓글이 등록되었습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          position: DelightSnackbarPosition.top,
          autoDismiss: true,
          snackbarDuration: const Duration(seconds: 2),
        ).show(context);
      }
    } catch (e) {
      DelightToastBar(
        builder: (context) => ToastCard(
          color: Theme.of(context).colorScheme.primary,
          leading: const Icon(
            SolarIconsOutline.dangerCircle,
            size: 28,
            color: Colors.white,
          ),
          title: Text(
            '댓글 등록 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
      ).show(context);
    } finally {
      setState(() {
        _isUploadingImages = false;
      });
    }
  }

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  // 이미지 뷰어 표시 함수
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

// 이미지 뷰어 페이지
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // 이미지 뷰어를 닫을 때 키보드 포커스를 제거
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                                    style: TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
