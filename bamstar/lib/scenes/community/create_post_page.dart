import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();
  bool _anonymous = false;
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  final List<XFile> _images = [];
  final List<Uint8List> _imageBytes = [];
  bool _submitting = false;

  // hashtag suggestions
  List<HashtagChannel> _suggestions = const [];
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTagFromInput() {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) {
      return;
    }
    final t = raw.startsWith('#') ? raw.substring(1) : raw;
    if (!_tags.contains(t)) {
      setState(() => _tags.add(t));
    }
    _tagController.clear();
    setState(() => _suggestions = const []);
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      return;
    }
    // append tags inline for server-side hashtag parsing trigger
    final suffix = _tags.map((t) => '#$t').join(' ');
    final full = suffix.isEmpty ? content : '$content\n\n$suffix';
    setState(() => _submitting = true);
    try {
      // Require login for posting
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('auth_required');
      }
      List<String> uploaded = [];
      if (_images.isNotEmpty) {
        uploaded = await CommunityRepository.instance.uploadImages(
          files: _images,
        );
      }
      await CommunityRepository.instance.createPost(
        content: full,
        isAnonymous: _anonymous,
        imageUrls: uploaded,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('auth_required')
                  ? '로그인이 필요합니다.'
                  : '게시 중 오류가 발생했습니다. 다시 시도해주세요.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final pics = await picker.pickMultiImage(imageQuality: 85);
      if (pics.isEmpty) {
        return;
      }
      final List<Uint8List> bytes = [];
      for (final x in pics) {
        bytes.add(await x.readAsBytes());
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _images.addAll(pics);
        _imageBytes.addAll(bytes);
      });
    } catch (_) {
      // Fallback single picker
      final one = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (one == null) {
        return;
      }
      final b = await one.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _images.add(one);
        _imageBytes.add(b);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('새 게시물 작성', style: tt.titleLarge?.copyWith(fontFamily: 'Pretendard')),
        backgroundColor: cs.surface,
        elevation: 0,
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: cs.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _controller,
                        maxLines: 10,
                        minLines: 5,
                        style: tt.bodyLarge?.copyWith(fontFamily: 'Pretendard', color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: '무엇이든 공유해보세요...\n(#태그 를 이용해 주제를 알려주세요)',
                          hintStyle: tt.bodyLarge?.copyWith(fontFamily: 'Pretendard', color: cs.onSurfaceVariant.withOpacity(0.7)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_imageBytes.isNotEmpty) ...[
                    Text('첨부된 이미지', style: tt.titleMedium?.copyWith(fontFamily: 'Pretendard', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildImagePreviews(),
                    const SizedBox(height: 24),
                  ],
                  Text('태그', style: tt.titleMedium?.copyWith(fontFamily: 'Pretendard', fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTagSection(cs, tt),
                  const SizedBox(height: 24),
                  _buildAnonymousSection(cs, tt),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(cs, tt),
        ],
      ),
      floatingActionButton: _submitting
          ? const FloatingActionButton(
              onPressed: null,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _submit,
              label: Text('게시하기', style: tt.labelLarge?.copyWith(fontFamily: 'Pretendard', fontWeight: FontWeight.bold)),
              icon: const Icon(SolarIconsOutline.pen),
            ),
    );
  }

  Widget _buildImagePreviews() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: _imageBytes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.memory(
                _imageBytes[i],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _imageBytes.removeAt(i);
                    _images.removeAt(i);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      SolarIconsOutline.closeCircle,
                      color: Colors.white,
                      size: 18,
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

  Widget _buildTagSection(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags
                .map(
                  (t) => Chip(
                    label: Text('#$t', style: tt.bodyMedium?.copyWith(fontFamily: 'Pretendard', color: cs.onSecondaryContainer)),
                    onDeleted: () => setState(() => _tags.remove(t)),
                    backgroundColor: cs.secondaryContainer.withOpacity(0.7),
                    side: BorderSide.none,
                    deleteIconColor: cs.onSecondaryContainer.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _tagController,
          onChanged: (v) {
            _debounce?.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 180),
              () async {
                final q = v.trim();
                if (q.isEmpty) {
                  if (mounted) setState(() => _suggestions = const []);
                  return;
                }
                final res = await CommunityRepository.instance
                    .searchHashtags(q, limit: 6);
                if (!mounted) return;
                setState(() => _suggestions = res);
              },
            );
          },
          onSubmitted: (_) => _addTagFromInput(),
          style: tt.bodyMedium?.copyWith(fontFamily: 'Pretendard'),
          decoration: InputDecoration(
            hintText: '#태그 추가',
            hintStyle: tt.bodyMedium?.copyWith(fontFamily: 'Pretendard', color: cs.onSurfaceVariant.withOpacity(0.7)),
            prefixIcon:
                const Icon(SolarIconsOutline.hashtag, color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(SolarIconsOutline.addCircle),
              onPressed: _addTagFromInput,
              color: cs.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .map(
                    (s) => ActionChip(
                      label: Text('#${s.name}', style: tt.bodyMedium?.copyWith(fontFamily: 'Pretendard')),
                      onPressed: () {
                        if (!_tags.contains(s.name)) {
                          setState(() => _tags.add(s.name));
                        }
                        _tagController.clear();
                        setState(() => _suggestions = const []);
                      },
                      backgroundColor: cs.secondaryContainer.withOpacity(0.4),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActionBar(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outline.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.tonal(
            onPressed: _pickImages,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: tt.labelLarge?.copyWith(fontFamily: 'Pretendard'),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(SolarIconsOutline.galleryAdd, size: 20),
                const SizedBox(width: 8),
                Text('이미지 추가 (${_imageBytes.length}/4)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymousSection(ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 0,
      color: _anonymous ? cs.primaryContainer.withOpacity(0.3) : cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _anonymous ? cs.primary.withOpacity(0.5) : cs.outline.withOpacity(0.2),
          width: _anonymous ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _anonymous ? SolarIconsBold.incognito : SolarIconsOutline.userCircle,
                  color: _anonymous ? cs.primary : cs.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _anonymous ? '익명으로 게시' : '본인 닉네임으로 게시',
                    style: tt.titleMedium?.copyWith(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.bold,
                      color: _anonymous ? cs.primary : cs.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v),
                  activeTrackColor: cs.primary.withOpacity(0.5),
                  activeColor: cs.primary,
                  inactiveThumbColor: cs.outline,
                  inactiveTrackColor: cs.surfaceContainer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _anonymous 
                  ? '• 닉네임과 프로필이 \'익명의 스타\'로 표시됩니다\n• 민감한 정보나 고민을 안전하게 공유할 수 있습니다'
                  : '• 본인의 닉네임과 프로필로 게시됩니다\n• 일상 이야기나 소셜 활동에 적합합니다',
              style: tt.bodySmall?.copyWith(
                fontFamily: 'Pretendard',
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
