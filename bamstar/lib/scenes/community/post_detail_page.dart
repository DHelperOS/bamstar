import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'dart:ui';

// 간단한 AspectRatio 캐시 (댓글 페이지와 동일한 로직을 가볍게 재구현)
final Map<String, double> _detailImageAspectCache = {};

class _DetailImageWithAspect extends StatefulWidget {
  final String url;
  final bool isSingle;
  final double maxHeight;
  const _DetailImageWithAspect({
    required this.url,
    this.isSingle = false,
    this.maxHeight = 260,
  });

  @override
  State<_DetailImageWithAspect> createState() => _DetailImageWithAspectState();
}

class _DetailImageWithAspectState extends State<_DetailImageWithAspect> {
  double? _aspect;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    if (_detailImageAspectCache.containsKey(widget.url)) {
      _aspect = _detailImageAspectCache[widget.url];
    } else {
      _resolve();
    }
  }

  void _resolve() {
    try {
      final provider = NetworkImage(widget.url);
      final stream = provider.resolve(const ImageConfiguration());
      _listener = ImageStreamListener((info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (w > 0 && h > 0) {
          final ar = w / h;
          _detailImageAspectCache[widget.url] = ar;
          if (mounted) setState(() => _aspect = ar);
        }
      }, onError: (_, __) {});
      stream.addListener(_listener!);
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      if (_listener != null) {
        final stream = NetworkImage(widget.url).resolve(const ImageConfiguration());
        stream.removeListener(_listener!);
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget img = Image.network(
      widget.url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: cs.surfaceContainerHighest,
        child: Icon(SolarIconsOutline.gallery, color: cs.onSurfaceVariant, size: 28),
      ),
    );

    if (widget.isSingle) {
      if (_aspect != null) {
        img = ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: AspectRatio(aspectRatio: _aspect!, child: img),
        );
      } else {
        img = SizedBox(height: widget.maxHeight * 0.55, child: img);
      }
    } else {
      img = AspectRatio(aspectRatio: 1, child: img);
    }
    return img;
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const _FullScreenImageViewer({required this.imageUrls, required this.initialIndex});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pc;
  int _index = 0;
  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pc = PageController(initialPage: _index);
  }
  @override
  void dispose() { _pc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_index + 1}/${widget.imageUrls.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: PageView.builder(
          controller: _pc,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, i) => InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.imageUrls[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(SolarIconsOutline.gallery, color: cs.onSurfaceVariant),
                ),
              ),
            ),
        ),
      ),
    );
  }
}

// Simple post detail page replacement. Keeps layout minimal and focused on
// the comment UI: top comment input (like community_home_page) and a
// vertically scrolling comment list with nested replies.

class CommunityPostDetailPage extends StatelessWidget {
  final String title;
  final String body;
  final List<String> imageUrls; // 게시물 본문 이미지들
  const CommunityPostDetailPage({
    super.key,
    required this.title,
    this.body = '',
    this.imageUrls = const [],
  });

  void _openViewer(BuildContext context, List<String> urls, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullScreenImageViewer(imageUrls: urls, initialIndex: index)),
    );
  }

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
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write a comment',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        style: tt.bodyMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(SolarIconsOutline.paperclip),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(SolarIconsOutline.arrowRight, size: 28),
                    ),
                  ],
                ),
              ),
            ),

            // Comments list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(title, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (body.isNotEmpty) Text(body, style: tt.bodyMedium),
                    if (body.isNotEmpty) const SizedBox(height: 16),
                    if (imageUrls.isNotEmpty) ...[
                      _buildImageGallery(context, imageUrls),
                      const SizedBox(height: 24),
                    ],
                    // (예시) 아래에 기존 더미 댓글 섹션 유지 - 필요 없다면 제거 가능
                    _CommentItem(
                      avatarUrl: 'https://i.pravatar.cc/100?img=32',
                      name: 'Esther Howard',
                      time: '25분 전',
                      text: '샘플 댓글입니다.',
                      likes: 18,
                    ),
                    const SizedBox(height: 12),
                    _CommentItem(
                      avatarUrl: 'https://i.pravatar.cc/100?img=12',
                      name: 'Jerome Bell',
                      time: '3분 전',
                      text: '샘플 댓글 두번째 입니다.',
                      likes: 2,
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

  Widget _buildImageGallery(BuildContext context, List<String> urls) {
    final cs = Theme.of(context).colorScheme;
    if (urls.length == 1) {
      final url = urls.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openViewer(context, urls, 0),
            child: _DetailImageWithAspect(url: url, isSingle: true, maxHeight: 320),
          ),
        ),
      );
    }
    // 다중 이미지: 2열 그리드 정사각형 썸네일
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: urls.length,
      itemBuilder: (_, i) {
        final u = urls[i];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openViewer(context, urls, i),
              child: _DetailImageWithAspect(url: u, isSingle: false, maxHeight: 140),
            ),
          ),
        );
      },
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
  const _CommentItem({
    required this.avatarUrl,
    required this.name,
    required this.time,
    required this.text,
    required this.likes,
    this.replies,
  });

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
                  const Icon(
                    SolarIconsOutline.heart,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text('$likes', style: tt.bodyMedium),
                  const SizedBox(width: 12),
                  Text(
                    'Reply',
                    style: tt.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              if (replies != null && replies!.isNotEmpty) ...[
                const SizedBox(height: 12),
                // simple vertical line + replies column
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 16),
                    Container(
                      width: 1,
                      height: 80,
                      color: Colors.grey.withValues(alpha: 0.25),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: replies!
                            .map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ReplyItem(reply: r),
                              ),
                            )
                            .toList(),
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
  _Reply({
    required this.avatarUrl,
    required this.name,
    required this.time,
    required this.text,
    required this.likes,
  });
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
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(reply.avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reply.name,
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    reply.time,
                    style: tt.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(reply.text, style: tt.bodySmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    SolarIconsOutline.heart,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text('${reply.likes}', style: tt.bodySmall),
                  const SizedBox(width: 10),
                  Text(
                    'Reply',
                    style: tt.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
