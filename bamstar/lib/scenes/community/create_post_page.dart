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

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  
  // Image handling
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];
  
  // Hashtag functionality
  Timer? _hashtagDebounce;
  OverlayEntry? _hashtagOverlay;
  final GlobalKey _textFieldKey = GlobalKey();
  
  // Animation controllers
  late AnimationController _profileAnimationController;
  late Animation<double> _profileFadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _textController.addListener(_onTextChanged);
  }

  void _setupAnimations() {
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _profileFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onTextChanged() {
    final text = _textController.text;
    final cursorPosition = _textController.selection.start;
    
    // Check for hashtag typing
    if (cursorPosition > 0 && text.substring(cursorPosition - 1, cursorPosition) == '#') {
      _showHashtagSuggestions();
    } else {
      _hideHashtagSuggestions();
    }
    
    setState(() {}); // Update Post button state
  }

  void _showHashtagSuggestions() {
    _hideHashtagSuggestions(); // Remove existing overlay
    
    // Get the position of the text input field
    final RenderBox? textFieldBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (textFieldBox == null) return;
    
    final textFieldOffset = textFieldBox.localToGlobal(Offset.zero);
    final textFieldHeight = textFieldBox.size.height;
    
    // Position suggestions right below the text input field
    final suggestionsTop = textFieldOffset.dy + textFieldHeight + 8; // 8px gap
    
    _hashtagOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        top: suggestionsTop,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _getPopularHashtags().length,
              itemBuilder: (context, index) {
                final hashtag = _getPopularHashtags()[index];
                return InkWell(
                  onTap: () => _insertHashtag(hashtag),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          SolarIconsOutline.hashtag,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hashtag,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Pretendard',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_hashtagOverlay!);
  }

  void _hideHashtagSuggestions() {
    _hashtagOverlay?.remove();
    _hashtagOverlay = null;
  }

  List<String> _getPopularHashtags() {
    return ['강남후기', '강남맛집', '일상', '데이트', '맛집추천', '카페'];
  }

  void _insertHashtag(String hashtag) {
    final currentText = _textController.text;
    final cursorPosition = _textController.selection.start;
    final newText = '${currentText.substring(0, cursorPosition)}$hashtag ${currentText.substring(cursorPosition)}';
    
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: cursorPosition + hashtag.length + 1,
    );
    
    _hideHashtagSuggestions();
  }

  void _toggleAnonymous() {
    setState(() {
      _isAnonymous = !_isAnonymous;
    });
    
    if (_isAnonymous) {
      _profileAnimationController.forward();
    } else {
      _profileAnimationController.reverse();
    }
  }

  Future<void> _pickImages() async {
    if (_isAnonymous) return; // Disabled in anonymous mode
    
    final picker = ImagePicker();
    try {
      final images = await picker.pickMultiImage(
        imageQuality: 85,
        limit: 4 - _selectedImages.length,
      );
      
      if (images.isEmpty) return;
      
      final List<Uint8List> newBytes = [];
      for (final image in images) {
        newBytes.add(await image.readAsBytes());
      }
      
      if (!mounted) return;
      
      setState(() {
        _selectedImages.addAll(images);
        _imageBytes.addAll(newBytes);
      });
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _imageBytes.removeAt(index);
    });
  }

  bool get _canPost {
    final text = _textController.text.trim();
    return text.isNotEmpty || _selectedImages.isNotEmpty;
  }

  Future<void> _submitPost() async {
    if (!_canPost || _isSubmitting) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty && !_isAnonymous) {
        uploadedImageUrls = await CommunityRepository.instance.uploadImages(
          files: _selectedImages,
        );
      }
      
      await CommunityRepository.instance.createPost(
        content: _textController.text.trim(),
        isAnonymous: _isAnonymous,
        imageUrls: uploadedImageUrls,
      );
      
      if (!mounted) return;
      Navigator.of(context).pop(true);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('로그인')
              ? '로그인이 필요합니다.'
              : '게시 중 오류가 발생했습니다. 다시 시도해주세요.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _profileAnimationController.dispose();
    _hashtagDebounce?.cancel();
    _hideHashtagSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildHeader(theme),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildAuthorProfileArea(theme),
                  _buildTextInputField(theme),
                  if (_selectedImages.isNotEmpty && !_isAnonymous)
                    _buildImageAttachmentArea(theme),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildFooterActionBar(theme),
    );
  }

  PreferredSizeWidget _buildHeader(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(SolarIconsOutline.closeCircle),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '새 글 작성',
        style: theme.textTheme.titleLarge?.copyWith(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: _canPost ? _submitPost : null,
                  style: TextButton.styleFrom(
                    backgroundColor: _canPost 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: _canPost 
                        ? Colors.white 
                        : theme.colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 8
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '등록',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAuthorProfileArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profile Picture with Cross-fade Animation
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                // Real profile picture
                AnimatedBuilder(
                  animation: _profileFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _isAnonymous ? 1 - _profileFadeAnimation.value : 1.0,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          SolarIconsOutline.userCircle,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
                // Anonymous icon
                AnimatedBuilder(
                  animation: _profileFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _isAnonymous ? _profileFadeAnimation.value : 0.0,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          SolarIconsOutline.incognito,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Name with Cross-fade Animation
          Expanded(
            child: Container(
              height: 24,
              alignment: Alignment.centerLeft,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Real name
                  AnimatedBuilder(
                    animation: _profileFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isAnonymous ? 1 - _profileFadeAnimation.value : 1.0,
                        child: Text(
                          '나의 닉네임', // This should come from user data
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  // Anonymous name
                  AnimatedBuilder(
                    animation: _profileFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isAnonymous ? _profileFadeAnimation.value : 0.0,
                        child: Text(
                          '익명의 스타',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField(ThemeData theme) {
    return Container(
      key: _textFieldKey,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _textController,
        maxLines: null,
        minLines: 8,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontFamily: 'Pretendard',
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: '어떤 이야기를 공유하고 싶으신가요?\n#해시태그로 다른 스타들과 연결해보세요!',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'Pretendard',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerLowest,
        ),
      ),
    );
  }

  Widget _buildImageAttachmentArea(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '첨부된 이미지',
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageBytes.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageBytes[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              SolarIconsOutline.closeCircle,
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
      ),
    );
  }

  Widget _buildFooterActionBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Anonymous Switch - Priority feature
          Row(
            children: [
              Switch(
                value: _isAnonymous,
                onChanged: (value) => _toggleAnonymous(),
                activeThumbColor: theme.colorScheme.primary,
                activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                inactiveThumbColor: theme.colorScheme.outline,
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 8),
              Text(
                '익명으로 글쓰기',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: _isAnonymous 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Image attachment button
          if (!_isAnonymous) ...[
            IconButton(
              onPressed: _selectedImages.length < 4 ? _pickImages : null,
              icon: Icon(
                SolarIconsOutline.galleryAdd,
                color: _selectedImages.length < 4
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}