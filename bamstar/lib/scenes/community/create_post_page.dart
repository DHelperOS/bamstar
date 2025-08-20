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
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: const Text('게시'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitting ? null : _submit,
        child: _submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(SolarIconsOutline.checkCircle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '무엇이든 공유해보세요... (#태그 자동 인식)',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_imageBytes.isNotEmpty) ...[
              SizedBox(
                height: 86,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageBytes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.memory(
                          _imageBytes[i],
                          width: 120,
                          height: 86,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(SolarIconsOutline.closeCircle),
                          onPressed: () => setState(() {
                            _imageBytes.removeAt(i);
                            _images.removeAt(i);
                          }),
                          color: cs.surface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags
                  .map(
                    (t) => Chip(
                      label: Text('#$t'),
                      onDeleted: () => setState(() => _tags.remove(t)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onChanged: (v) {
                      _debounce?.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 180),
                        () async {
                          final q = v.trim();
                          if (q.isEmpty) {
                            if (mounted)
                              setState(() => _suggestions = const []);
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
                    decoration: const InputDecoration(
                      hintText: '#태그 추가',
                      prefixIcon: Icon(SolarIconsOutline.hashtagSquare),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _addTagFromInput,
                  child: const Text('추가'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _pickImages,
                  icon: const Icon(SolarIconsOutline.paperclip),
                  tooltip: '이미지 추가',
                ),
              ],
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestions
                      .map(
                        (s) => ActionChip(
                          label: Text('#${s.name}'),
                          onPressed: () {
                            if (!_tags.contains(s.name)) {
                              setState(() => _tags.add(s.name));
                            }
                            _tagController.clear();
                            setState(() => _suggestions = const []);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('익명으로 게시'),
                const SizedBox(width: 8),
                Switch(
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v),
                ),
                const SizedBox(width: 12),
                Icon(
                  _anonymous
                      ? SolarIconsBold.incognito
                      : SolarIconsOutline.userCircle,
                  color: cs.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
