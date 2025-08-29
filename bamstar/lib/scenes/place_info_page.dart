import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:kpostal/kpostal.dart';

import '../theme/app_text_styles.dart';
import '../utils/toast_helper.dart';

/// Place information page with multi-image picker and address search
class PlaceInfoPage extends StatefulWidget {
  const PlaceInfoPage({super.key});

  @override
  State<PlaceInfoPage> createState() => _PlaceInfoPageState();
}

class _PlaceInfoPageState extends State<PlaceInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Photo management with representative image selection
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _photos = <Uint8List>[];
  final List<String> _loadedImageUrls = <String>[];
  int _representativeImageIndex = -1; // -1 means no representative selected

  // Form controllers
  final TextEditingController _placeNameCtl = TextEditingController();
  final TextEditingController _addressCtl = TextEditingController();
  final TextEditingController _detailAddressCtl = TextEditingController();
  final TextEditingController _managerNameCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _snsHandleCtl = TextEditingController();
  final TextEditingController _introCtl = TextEditingController();

  // State variables
  String _selectedGender = '남';
  String _selectedSns = '카카오톡';
  bool _isLoading = false;

  // Operating hours data - 운영시간 관련 데이터
  List<String> _selectedOperatingDays = []; // 선택된 운영 요일들
  double _operatingStartHour = 9.0; // 운영 시작 시간 (시간 단위, 0-24)  
  double _operatingEndHour = 18.0; // 운영 종료 시간 (시간 단위, 0-24)
  
  // 요일 리스트
  final List<Map<String, String>> _weekDays = [
    {'value': 'monday', 'label': '월'},
    {'value': 'tuesday', 'label': '화'},
    {'value': 'wednesday', 'label': '수'},
    {'value': 'thursday', 'label': '목'},
    {'value': 'friday', 'label': '금'},
    {'value': 'saturday', 'label': '토'},
    {'value': 'sunday', 'label': '일'},
  ];

  // Address data - comprehensive storage for all address information
  String? _postCode; // 우편번호
  String? _roadAddress; // 도로명주소
  String? _jibunAddress; // 지번주소
  double? _latitude; // 위도
  double? _longitude; // 경도
  String? _kakaoLatitude; // 카카오 위도
  String? _kakaoLongitude; // 카카오 경도

  @override
  void initState() {
    super.initState();
    _phoneCtl.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    _placeNameCtl.dispose();
    _addressCtl.dispose();
    _detailAddressCtl.dispose();
    _managerNameCtl.dispose();
    _phoneCtl.dispose();
    _snsHandleCtl.dispose();
    _introCtl.dispose();
    super.dispose();
  }

  void _formatPhoneNumber() {
    String text = _phoneCtl.text.replaceAll('-', '');
    if (text.length >= 11) {
      text =
          '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7, 11)}';
    } else if (text.length >= 7) {
      text =
          '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}';
    } else if (text.length >= 3) {
      text = '${text.substring(0, 3)}-${text.substring(3)}';
    }

    if (text != _phoneCtl.text) {
      _phoneCtl.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isEmpty) return;

      for (final image in images) {
        if (_photos.length >= 10) break; // Limit to 10 images for places

        final bytes = await image.readAsBytes();
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
      if (_photos.length < 10) {
        setState(() => _photos.add(bytes));
      }
    } catch (e) {
      debugPrint('error picking camera image: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      // Adjust representative index if needed
      if (_representativeImageIndex == index) {
        _representativeImageIndex = -1;
      } else if (_representativeImageIndex > index) {
        _representativeImageIndex--;
      }
    });
  }

  void _setRepresentativeImage(int index) {
    setState(() {
      _representativeImageIndex = _representativeImageIndex == index
          ? -1
          : index;
    });

    if (_representativeImageIndex == index) {
      ToastHelper.success(context, '대표 이미지로 설정되었습니다');
    } else {
      ToastHelper.info(context, '대표 이미지 설정이 해제되었습니다');
    }
  }

  Future<void> _searchAddress() async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KpostalView(
            useLocalServer: false, // Use CDN for Daum Postcode API
            callback: (Kpostal result) {
              if (mounted) {
                setState(() {
                  // Store all address information for database
                  _postCode = result.postCode;
                  _roadAddress = result.address;
                  _jibunAddress = result.jibunAddress;
                  _latitude = result.latitude;
                  _longitude = result.longitude;
                  _kakaoLatitude = result.kakaoLatitude.toString();
                  _kakaoLongitude = result.kakaoLongitude.toString();

                  // Update UI display
                  _addressCtl.text = result.address;
                });
                ToastHelper.success(context, '주소가 입력되었습니다');
              }
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('address search error: $e');
      if (mounted) {
        ToastHelper.error(context, '주소 검색 중 오류가 발생했습니다');
      }
    }
  }

  Future<void> _savePlaceInfo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_photos.isEmpty && _loadedImageUrls.isEmpty) {
      ToastHelper.warning(context, '플레이스 사진을 최소 1장 추가해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement place info save logic
      // Log all collected address data for database storage
      debugPrint('=== Place Info Save Data ===');
      debugPrint('Place Name: ${_placeNameCtl.text}');
      debugPrint('Post Code: $_postCode');
      debugPrint('Road Address: $_roadAddress');
      debugPrint('Jibun Address: $_jibunAddress');
      debugPrint('Detail Address: ${_detailAddressCtl.text}');
      debugPrint('Latitude: $_latitude');
      debugPrint('Longitude: $_longitude');
      debugPrint('Kakao Latitude: $_kakaoLatitude');
      debugPrint('Kakao Longitude: $_kakaoLongitude');
      debugPrint('Manager: ${_managerNameCtl.text} ($_selectedGender)');
      debugPrint('Phone: ${_phoneCtl.text}');
      debugPrint('SNS: $_selectedSns - ${_snsHandleCtl.text}');
      debugPrint('Description: ${_introCtl.text}');
      debugPrint(
        'Photos: ${_photos.length} new, ${_loadedImageUrls.length} existing',
      );
      debugPrint('Representative Image Index: $_representativeImageIndex');

      await Future.delayed(const Duration(seconds: 2)); // Simulate save

      if (mounted) {
        ToastHelper.success(context, '플레이스 정보가 저장되었습니다');
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('save place info error: $e');
      if (mounted) {
        ToastHelper.error(context, '저장 중 오류가 발생했습니다');
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                SolarIconsBold.buildings,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '플레이스 정보',
                style: AppTextStyles.sectionTitle(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            SolarIconsOutline.camera,
            '매력적인 플레이스 사진을 업로드하고 대표 이미지를 선택하세요',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            SolarIconsOutline.mapPoint,
            '정확한 주소를 입력하여 스타들이 쉽게 찾을 수 있게 하세요',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            SolarIconsOutline.userCircle,
            '담당자 정보를 입력하여 원활한 소통이 가능하게 하세요',
          ),
        ],
      ),
    );
  }

  Widget _buildPlacePhotoSection() {
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
              Text('플레이스 사진', style: AppTextStyles.sectionTitle(context)),
              const SizedBox(width: 8),
              if (_representativeImageIndex >= 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        '대표',
                        style: AppTextStyles.captionText(context).copyWith(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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

          // Photo thumbnails with representative selection
          SizedBox(height: 100, child: _buildPhotoThumbnails()),
          const SizedBox(height: 8),

          Text(
            '최대 10장의 사진을 업로드할 수 있습니다. 대표 이미지를 선택하려면 사진의 왕관 아이콘을 탭하세요.',
            style: AppTextStyles.captionText(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnails() {
    final totalImageCount = _loadedImageUrls.length + _photos.length;

    if (totalImageCount == 0) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 100,
          height: 100,
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
            SolarIconsOutline.buildings,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: totalImageCount,
      itemBuilder: (context, index) {
        final isLoadedImage = index < _loadedImageUrls.length;
        final isRepresentative = _representativeImageIndex == index;

        return Container(
          margin: EdgeInsets.only(right: index == totalImageCount - 1 ? 0 : 12),
          child: Stack(
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: isRepresentative
                        ? Border.all(color: Colors.amber, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoadedImage
                      ? Image.network(
                          _loadedImageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              child: Icon(
                                Icons.error_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                size: 24,
                              ),
                            );
                          },
                        )
                      : Image.memory(
                          _photos[index - _loadedImageUrls.length],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              // Representative selection button (crown icon)
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: () => _setRepresentativeImage(index),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isRepresentative
                          ? Colors.amber
                          : Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.star,
                      size: 16,
                      color: isRepresentative ? Colors.white : Colors.grey[300],
                    ),
                  ),
                ),
              ),

              // Remove button
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => isLoadedImage
                      ? _removePhoto(index) // TODO: Handle loaded image removal
                      : _removePhoto(index - _loadedImageUrls.length),
                  child: Container(
                    width: 28,
                    height: 28,
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
                      size: 16,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceInfoForm() {
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
          Text('플레이스 정보', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 20),

          // Place name field
          Text('플레이스명', style: AppTextStyles.formLabel(context)),
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
              controller: _placeNameCtl,
              style: AppTextStyles.primaryText(context),
              decoration: InputDecoration(
                hintText: '플레이스 이름을 입력해주세요',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  SolarIconsOutline.buildings,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '플레이스명을 입력해주세요';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Address field with search button
          Text('주소', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
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
                  child: TextFormField(
                    controller: _addressCtl,
                    style: AppTextStyles.primaryText(context),
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: '주소 찾기 버튼을 눌러주세요',
                      hintStyle: AppTextStyles.secondaryText(context),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        SolarIconsOutline.mapPoint,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '주소를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _searchAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('주소 찾기'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detail address field
          Text('상세주소', style: AppTextStyles.formLabel(context)),
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
              controller: _detailAddressCtl,
              style: AppTextStyles.primaryText(context),
              decoration: InputDecoration(
                hintText: '동/호수, 건물명 등 상세주소를 입력해주세요',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  SolarIconsOutline.home,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerInfoForm() {
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
          Text('담당자 정보', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 20),

          // Manager name field
          Text('담당자명', style: AppTextStyles.formLabel(context)),
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
              controller: _managerNameCtl,
              style: AppTextStyles.primaryText(context),
              decoration: InputDecoration(
                hintText: '담당자 이름을 입력해주세요',
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '담당자명을 입력해주세요';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Phone field
          Text('연락처', style: AppTextStyles.formLabel(context)),
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
                hintText: '010-1234-5678',
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '연락처를 입력해주세요';
                }
                if (value.replaceAll('-', '').length < 10) {
                  return '올바른 연락처를 입력해주세요';
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
            segments: [
              ButtonSegment(
                value: '남',
                label: Text('남'),
                icon: const Icon(Icons.male),
              ),
              ButtonSegment(
                value: '여',
                label: Text('여'),
                icon: const Icon(Icons.female),
              ),
            ],
            selected: {_selectedGender},
            onSelectionChanged: (Set<String> newSelection) {
              if (newSelection.isNotEmpty) {
                setState(() => _selectedGender = newSelection.first);
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.onPrimary;
                }
                return null;
              }),
              iconColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.onPrimary;
                }
                return null;
              }),
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

  Widget _buildPlaceDescriptionForm() {
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
          Text('플레이스 소개', style: AppTextStyles.sectionTitle(context)),
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
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    '스타들에게 어필할 수 있는 플레이스만의 특별한 매력을 소개해보세요.\n(예: 분위기, 특별한 서비스, 추천 메뉴 등)',
                hintStyle: AppTextStyles.secondaryText(context),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '플레이스 소개를 입력해주세요';
                }
                if (value.trim().length < 10) {
                  return '10자 이상 입력해주세요';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // 운영시간 폼 - 기존 디자인과 동일한 스타일
  Widget _buildOperatingHoursForm() {
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
          Text('운영시간', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 20),

          // 운영 요일 선택
          Text('운영 요일', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 전체 선택 칩
              FilterChip(
                label: Text(
                  '전체',
                  style: AppTextStyles.chipLabel(context).copyWith(
                    color: _selectedOperatingDays.length == _weekDays.length
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                selected: _selectedOperatingDays.length == _weekDays.length,
                checkmarkColor: _selectedOperatingDays.length == _weekDays.length
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedOperatingDays = _weekDays.map((day) => day['value']!).toList();
                    } else {
                      _selectedOperatingDays.clear();
                    }
                  });
                },
              ),
              // 개별 요일 칩들
              ..._weekDays.map((day) => FilterChip(
                label: Text(
                  day['label']!,
                  style: AppTextStyles.chipLabel(context).copyWith(
                    color: _selectedOperatingDays.contains(day['value'])
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                selected: _selectedOperatingDays.contains(day['value']),
                checkmarkColor: _selectedOperatingDays.contains(day['value'])
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedOperatingDays.add(day['value']!);
                    } else {
                      _selectedOperatingDays.remove(day['value']);
                    }
                  });
                },
              )),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 운영 시간 설정
          Text('운영 시간', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 12),
          
          // 시간 슬라이더 (항상 보이는 툴팁, 옅은 회색)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
              valueIndicatorColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueIndicatorTextStyle: AppTextStyles.captionText(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: RangeSlider(
            values: RangeValues(_operatingStartHour, _operatingEndHour),
            min: 0,
            max: 24,
            divisions: 24,
            labels: RangeLabels(
              '${_operatingStartHour.round()}:00',
              '${_operatingEndHour.round()}:00',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _operatingStartHour = values.start;
                _operatingEndHour = values.end;
              });
            },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.captionText(context))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('플레이스 정보', style: AppTextStyles.dialogTitle(context)),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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

                        // Place Photos Section
                        _buildPlacePhotoSection(),
                        const SizedBox(height: 24),

                        // Place Info Form
                        _buildPlaceInfoForm(),
                        const SizedBox(height: 24),

                        // Manager Info Form
                        _buildManagerInfoForm(),
                        const SizedBox(height: 24),

                        // Place Description Form
                        _buildPlaceDescriptionForm(),
                        const SizedBox(height: 24),

                        // Operating Hours Form
                        _buildOperatingHoursForm(),
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
                        onTap: _isLoading ? null : _savePlaceInfo,
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
                                    '저장하기',
                                    style: AppTextStyles.buttonText(context)
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
