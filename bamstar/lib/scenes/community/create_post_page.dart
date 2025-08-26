import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bamstar/services/community/community_repository.dart';
import 'package:bamstar/services/community/hashtag_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  // Core controllers
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final FocusNode _textFocusNode = FocusNode();

  // State management
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  // Image handling
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];

  // Hashtag functionality
  Timer? _hashtagDebounce;
  OverlayEntry? _hashtagOverlay;
  final GlobalKey _textFieldKey = GlobalKey();
  List<HashtagSuggestion> _currentSuggestions = [];
  bool _isLoadingSuggestions = false;

  // Animation controllers for smooth transitions
  late AnimationController _profileAnimationController;
  late AnimationController _screenAnimationController;
  late Animation<double> _profileFadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _textController.addListener(_onTextChanged);
    _textFocusNode.addListener(_onFocusChanged);

    // Screen entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenAnimationController.forward();
    });
  }

  void _setupAnimations() {
    // Profile cross-fade animation
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _profileFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _profileAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Screen slide-up animation
    _screenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _screenAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  void _onTextChanged() {
    final text = _textController.text;
    final cursorPosition = _textController.selection.start;

    // Hashtag detection
    if (cursorPosition > 0 &&
        text.substring(cursorPosition - 1, cursorPosition) == '#') {
      _showHashtagSuggestions();
    } else {
      _hideHashtagSuggestions();
    }

    setState(() {}); // Update Post button state
  }

  void _onFocusChanged() {
    if (!_textFocusNode.hasFocus) {
      _hideHashtagSuggestions();
    }
  }

  void _showHashtagSuggestions() {
    _hideHashtagSuggestions(); // Remove existing overlay

    final RenderBox? textFieldBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (textFieldBox == null) return;

    // Get text field position and calculate cursor position
    final textFieldOffset = textFieldBox.localToGlobal(Offset.zero);
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontFamily: 'Pretendard', height: 1.5);

    // Estimate cursor position based on text lines
    final text = _textController.text.substring(
      0,
      _textController.selection.start,
    );
    final lines = text.split('\n');
    final currentLineIndex = lines.length - 1;
    final lineHeight = (textStyle?.fontSize ?? 16) * (textStyle?.height ?? 1.5);

    // Calculate suggestion position near cursor
    final cursorY =
        textFieldOffset.dy + 24 + (currentLineIndex * lineHeight) + 40;
    final suggestionsTop = cursorY;

    // Start loading intelligent suggestions
    _loadSmartSuggestions();

    _hashtagOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        top: suggestionsTop,
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          shadowColor: Theme.of(
            context,
          ).colorScheme.shadow.withValues(alpha: 0.15),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.05),
              ),
            ),
            child: _buildSuggestionsContent(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_hashtagOverlay!);
  }

  /// Load intelligent hashtag suggestions based on content
  void _loadSmartSuggestions() {
    _hashtagDebounce?.cancel();
    _hashtagDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      
      setState(() => _isLoadingSuggestions = true);
      
      try {
        final suggestions = await HashtagService.instance.getSmartSuggestions(
          _textController.text,
        );
        
        if (mounted) {
          setState(() {
            _currentSuggestions = suggestions;
            _isLoadingSuggestions = false;
          });
          _updateHashtagOverlay();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
            // Fallback to popular hashtags
            _currentSuggestions = _getPopularHashtags()
                .map((tag) => HashtagSuggestion(
                      name: tag,
                      source: SuggestionSource.cached,
                      relevanceScore: 0.5,
                    ))
                .toList();
          });
          _updateHashtagOverlay();
        }
      }
    });
  }

  /// Update existing hashtag overlay with new content
  void _updateHashtagOverlay() {
    if (_hashtagOverlay != null) {
      _hashtagOverlay!.markNeedsBuild();
    }
  }

  /// Build suggestions content with loading states and smart recommendations
  Widget _buildSuggestionsContent() {
    if (_isLoadingSuggestions) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '추천 해시태그를 찾는 중...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Pretendard',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentSuggestions.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: Text(
          '추천할 해시태그가 없습니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Pretendard',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _currentSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _currentSuggestions[index];
        return _buildSuggestionItem(suggestion);
      },
    );
  }

  /// Build individual suggestion item with source indicators
  Widget _buildSuggestionItem(HashtagSuggestion suggestion) {
    final theme = Theme.of(context);
    
    // Get source color and icon
    Color sourceColor;
    IconData sourceIcon;
    String sourceLabel;
    
    switch (suggestion.source) {
      case SuggestionSource.contentBased:
        sourceColor = theme.colorScheme.primary;
        sourceIcon = SolarIconsOutline.magicStick;
        sourceLabel = '내용 기반';
        break;
      case SuggestionSource.trending:
        sourceColor = Colors.orange;
        sourceIcon = SolarIconsOutline.arrowUp;
        sourceLabel = '인기 상승';
        break;
      case SuggestionSource.personalized:
        sourceColor = Colors.purple;
        sourceIcon = SolarIconsOutline.userHeart;
        sourceLabel = '개인 맞춤';
        break;
      case SuggestionSource.cached:
        sourceColor = theme.colorScheme.outline;
        sourceIcon = SolarIconsOutline.hashtag;
        sourceLabel = '인기';
        break;
      case SuggestionSource.popularFallback:
        sourceColor = theme.colorScheme.outline;
        sourceIcon = SolarIconsOutline.hashtag;
        sourceLabel = '추천';
        break;
    }

    return InkWell(
      onTap: () => _insertHashtag(suggestion.name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Source indicator icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: sourceColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sourceIcon,
                size: 16,
                color: sourceColor,
              ),
            ),
            const SizedBox(width: 12),
            
            // Hashtag name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    sourceLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Pretendard',
                      color: sourceColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Relevance indicator
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: sourceColor.withValues(
                  alpha: suggestion.relevanceScore,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hideHashtagSuggestions() {
    _hashtagOverlay?.remove();
    _hashtagOverlay = null;
  }

  List<String> _getPopularHashtags() {
    return ['강남후기', '강남맛집', '일상', '데이트', '맛집추천', '카페', '여행', '취미'];
  }

  void _insertHashtag(String hashtag) {
    final currentText = _textController.text;
    final cursorPosition = _textController.selection.start;
    final newText =
        '${currentText.substring(0, cursorPosition)}$hashtag ${currentText.substring(cursorPosition)}';

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
  // Allow image picking regardless of anonymous mode
    final picker = ImagePicker();
    try {
      final images = await picker.pickMultiImage(
        imageQuality: 80,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지를 선택할 수 없습니다. 다시 시도해주세요.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
        // Upload images only for non-anonymous posts
        // TODO: Implement image upload functionality
        uploadedImageUrls = []; // Skip image upload for now
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
      String errorMessage = '게시 중 오류가 발생했습니다. 다시 시도해주세요.';
      
      if (e.toString().contains('로그인')) {
        errorMessage = '로그인이 필요합니다.';
      } else if (e.toString().contains('네트워크')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('권한')) {
        errorMessage = '게시 권한이 없습니다. 계정을 확인해주세요.';
      } else if (e.toString().contains('UnsafeImageException')) {
        errorMessage = '업로드하려는 이미지가 안전하지 않습니다. 다른 이미지를 선택해주세요.';
      } else if (e.toString().contains('Cloudinary')) {
        errorMessage = '이미지 업로드에 실패했습니다. 다시 시도해주세요.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
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
    _textFocusNode.dispose();
    _profileAnimationController.dispose();
    _screenAnimationController.dispose();
    _hashtagDebounce?.cancel();
    _hideHashtagSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAuthorProfileArea(),
                      _buildTextInputField(),
                      if (_selectedImages.isNotEmpty && !_isAnonymous)
                        _buildImageAttachmentArea(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: _buildFooterActionBar(),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              SolarIconsOutline.closeSquare,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              '새 글 작성',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Post button
          _isSubmitting
              ? Container(
                  width: 64,
                  height: 36,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _canPost ? _submitPost : null,
                  style: TextButton.styleFrom(
                    backgroundColor: _canPost
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                    foregroundColor: _canPost
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(64, 36),
                  ),
                  child: Text(
                    '등록',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAuthorProfileArea() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Picture with Cross-fade Animation
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              children: [
                // Real profile picture
                AnimatedBuilder(
                  animation: _profileFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _isAnonymous
                          ? 1 - _profileFadeAnimation.value
                          : 1.0,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primaryContainer,
                        ),
                        child: Icon(
                          SolarIconsOutline.userCircle,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 24,
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
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Icon(
                          SolarIconsOutline.ghost,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Name with Cross-fade Animation
          Expanded(
            child: Container(
              height: 28,
              alignment: Alignment.centerLeft,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Real name
                  AnimatedBuilder(
                    animation: _profileFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isAnonymous
                            ? 1 - _profileFadeAnimation.value
                            : 1.0,
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
                        opacity: _isAnonymous
                            ? _profileFadeAnimation.value
                            : 0.0,
                        child: Text(
                          '익명의 스타',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
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

  Widget _buildTextInputField() {
    final theme = Theme.of(context);

    return Container(
      key: _textFieldKey,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _textFocusNode,
        maxLines: null,
        minLines: 10,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontFamily: 'Pretendard',
          height: 1.5,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: '어떤 이야기를 공유하고 싶으신가요?\n#해시태그로 다른 스타들과 연결해보세요!',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'Pretendard',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(24),
        ),
      ),
    );
  }

  Widget _buildImageAttachmentArea() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '첨부된 이미지',
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageBytes.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < _imageBytes.length - 1 ? 12 : 0,
                  ),
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
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
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

  Widget _buildFooterActionBar() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Anonymous Switch - Priority feature
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleAnonymous,
                  child: Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _isAnonymous
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.1,
                              ),
                        width: 1,
                      ),
                      color: _isAnonymous
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: _isAnonymous
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isAnonymous
                              ? theme.colorScheme.primary.withValues(alpha: 0.9)
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.15,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                237,
                                236,
                                236,
                              ).withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '익명으로 글쓰기',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      color: _isAnonymous
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image attachment button (always visible)
          const SizedBox(width: 16),
          IconButton(
            onPressed: _selectedImages.length < 4 ? _pickImages : null,
            icon: Icon(
              SolarIconsOutline.galleryAdd,
              color: _selectedImages.length < 4
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
