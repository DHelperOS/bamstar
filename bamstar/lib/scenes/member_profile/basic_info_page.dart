import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../theme/app_text_styles.dart';
import 'services/basic_info_service.dart';

/// Single-page basic info form with clean design matching edit_profile_modal
class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Photo management
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _photos = <Uint8List>[];
  final List<String> _loadedImageUrls = <String>[];  // Existing images from database

  // Form controllers
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _ageCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _snsHandleCtl = TextEditingController();
  final TextEditingController _introCtl = TextEditingController();

  // State variables
  String _selectedGender = '남';
  String _selectedSns = '카카오톡';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneCtl.addListener(_formatPhoneNumber);
    _loadBasicInfo();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _ageCtl.dispose();
    _phoneCtl.dispose();
    _snsHandleCtl.dispose();
    _introCtl.dispose();
    super.dispose();
  }


  void _formatPhoneNumber() {
    final text = _phoneCtl.text;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final formatted = _formatKoreanPhone(digits);

    if (formatted != text) {
      _phoneCtl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _formatKoreanPhone(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (digits.length <= 10) {
      if (digits.length == 10) {
        return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
      }
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  }

  bool get _isPhoneValid {
    final digits = _phoneCtl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;
    final mobileRegex = RegExp(r'^01\d{8,9}$');
    return mobileRegex.hasMatch(digits);
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> imgs = await _picker.pickMultiImage(imageQuality: 85);
      if (imgs.isEmpty) return;

      for (final img in imgs) {
        if (_photos.length >= 5) break;
        final bytes = await img.readAsBytes();
        setState(() => _photos.add(bytes));
      }
    } catch (e) {
      debugPrint('error picking images: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? img = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (img == null) return;

      final bytes = await img.readAsBytes();
      if (_photos.length < 5) {
        setState(() => _photos.add(bytes));
      }
    } catch (e) {
      debugPrint('error picking camera image: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  void _removeLoadedImage(int index) {
    setState(() {
      _loadedImageUrls.removeAt(index);
    });
  }

  Future<void> _loadBasicInfo() async {
    try {
      final basicInfo = await BasicInfoService.instance.loadBasicInfo();
      if (basicInfo != null && mounted) {
        setState(() {
          _nameCtl.text = basicInfo.realName ?? '';
          _ageCtl.text = basicInfo.age?.toString() ?? '';
          _phoneCtl.text = basicInfo.contactPhone ?? '';
          _selectedGender = basicInfo.gender ?? '남';
          _selectedSns = basicInfo.socialService ?? '카카오톡';
          _snsHandleCtl.text = basicInfo.socialHandle ?? '';
          _introCtl.text = basicInfo.bio ?? '';
          
          // Load existing images from database
          _loadedImageUrls.clear();
          _loadedImageUrls.addAll(basicInfo.profileImageUrls);
        });
      }
    } catch (e) {
      debugPrint('load basic info error: $e');
    }
  }

  Future<void> _saveBasicInfo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // Create BasicInfo object from form data
      final basicInfo = BasicInfo(
        realName: _nameCtl.text.trim().isEmpty ? null : _nameCtl.text.trim(),
        age: _ageCtl.text.trim().isEmpty ? null : int.tryParse(_ageCtl.text.trim()),
        gender: _selectedGender,
        contactPhone: _phoneCtl.text.trim().isEmpty ? null : _phoneCtl.text.trim(),
        socialService: _selectedSns.isEmpty ? null : _selectedSns,
        socialHandle: _snsHandleCtl.text.trim().isEmpty ? null : _snsHandleCtl.text.trim(),
        bio: _introCtl.text.trim().isEmpty ? null : _introCtl.text.trim(),
      );

      // Save to database
      final success = await BasicInfoService.instance.saveBasicInfo(basicInfo, _photos);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기본 정보가 저장되었습니다')));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장 중 오류가 발생했습니다')));
        }
      }
    } catch (e) {
      debugPrint('save basic info error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 중 오류가 발생했습니다')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header: icon and title arranged horizontally
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                SolarIconsOutline.infoCircle,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                '안내사항',
                style: AppTextStyles.formLabel(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(SolarIconsOutline.eye, '지원하신 곳에만 정보가 공개되니 안심하세요.'),
          const SizedBox(height: 6),
          _buildInfoRow(
            SolarIconsOutline.checkCircle,
            '진솔한 정보는 신뢰를 줘요. 사실대로만 적어주세요.',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(SolarIconsOutline.lock, '개인정보, 저희가 책임지고 안전하게 지킬게요.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('기본 정보', style: AppTextStyles.dialogTitle(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card Section
                      _buildInfoCard(),
                      const SizedBox(height: 24),

                      // Photos Section
                      _buildPhotoSection(),
                      const SizedBox(height: 32),

                      // Basic Info Form
                      _buildBasicInfoForm(),
                      const SizedBox(height: 24),

                      // Contact Info Form
                      _buildContactInfoForm(),
                      const SizedBox(height: 24),

                      // Introduction Form
                      _buildIntroductionForm(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Save Button
              Container(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isLoading ? null : _saveBasicInfo,
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: Center(
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  '저장',
                                  style: AppTextStyles.buttonText(context)
                                      .copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                ),
                        ),
                      ),
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

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('프로필 사진', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),

          // Camera/Gallery buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(
                    SolarIconsOutline.cameraMinimalistic,
                    size: 18,
                  ),
                  label: const Text('카메라'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(
                    SolarIconsOutline.galleryMinimalistic,
                    size: 18,
                  ),
                  label: const Text('앨범'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photo thumbnails
          SizedBox(height: 80, child: _buildPhotoThumbnails()),
          const SizedBox(height: 8),

          Text(
            '최대 5장의 사진을 업로드할 수 있습니다.',
            style: AppTextStyles.captionText(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.captionText(context))),
      ],
    );
  }

  Widget _buildPhotoThumbnails() {
    final totalImageCount = _loadedImageUrls.length + _photos.length;
    
    if (totalImageCount == 0) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Icon(
            SolarIconsOutline.userCircle,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: totalImageCount,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final isLoadedImage = index < _loadedImageUrls.length;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isLoadedImage
                  ? Image.network(
                      _loadedImageUrls[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Image.memory(
                      _photos[index - _loadedImageUrls.length],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => isLoadedImage ? _removeLoadedImage(index) : _removePhoto(index - _loadedImageUrls.length),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBasicInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('기본 정보', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 20),

          // Name field
          Text('이름', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _nameCtl,
              style: AppTextStyles.primaryText(context),
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  SolarIconsOutline.userCircle,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isEmpty) return null; // Optional field
                if (text.length < 2) return '이름은 2글자 이상 입력해주세요';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Age field
          Text('나이', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _ageCtl,
              style: AppTextStyles.primaryText(context),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '숫자만 입력',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  SolarIconsOutline.calendarMinimalistic,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isEmpty) return null; // Optional field
                final age = int.tryParse(text);
                if (age == null || age < 18 || age > 100) {
                  return '18세 이상 100세 이하의 나이를 입력해주세요';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Gender selection
          Text('성별', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '남', label: Text('남')),
              ButtonSegment(value: '여', label: Text('여')),
            ],
            selected: {_selectedGender},
            onSelectionChanged: (Set<String> newSelection) {
              if (newSelection.isNotEmpty) {
                setState(() => _selectedGender = newSelection.first);
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Theme.of(context).colorScheme.surfaceContainerHighest;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.onPrimary;
                }
                return Theme.of(context).colorScheme.onSurface;
              }),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('연락처 정보', style: AppTextStyles.sectionTitle(context)),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 20),

          // Phone field
          Text('휴대폰 번호', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _phoneCtl,
              style: AppTextStyles.primaryText(context),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '예: 010-1234-5678',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  SolarIconsOutline.phone,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.isEmpty) return null; // Optional field
                if (!_isPhoneValid) return '유효한 휴대폰 번호를 입력하세요';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // SNS fields
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SNS 서비스', style: AppTextStyles.formLabel(context)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSns,
                        items: const [
                          DropdownMenuItem(value: '카카오톡', child: Text('카카오톡')),
                          DropdownMenuItem(value: '텔레그램', child: Text('텔레그램')),
                          DropdownMenuItem(value: '라인', child: Text('라인')),
                          DropdownMenuItem(value: '인스타', child: Text('인스타')),
                          DropdownMenuItem(value: '페이스북', child: Text('페이스북')),
                          DropdownMenuItem(value: '틱톡', child: Text('틱톡')),
                          DropdownMenuItem(value: '', child: Text('선택 안함')),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedSns = v ?? '';
                            if (_selectedSns.isEmpty) {
                              _snsHandleCtl.clear();
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: AppTextStyles.primaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SNS 아이디', style: AppTextStyles.formLabel(context)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _selectedSns.isEmpty
                            ? Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.5)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _snsHandleCtl,
                        style: AppTextStyles.primaryText(context),
                        enabled: _selectedSns.isNotEmpty,
                        decoration: InputDecoration(
                          hintText: _selectedSns.isNotEmpty ? '아이디' : '미선택',
                          hintStyle: AppTextStyles.secondaryText(context),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            SolarIconsOutline.userCircle,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
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
    );
  }

  Widget _buildIntroductionForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('자기소개', style: AppTextStyles.sectionTitle(context)),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _introCtl,
              style: AppTextStyles.primaryText(context),
              maxLength: 140,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '취미, 관심사, 하고 싶은 것 등 자유롭게 적어주세요.',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: AppTextStyles.captionText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
