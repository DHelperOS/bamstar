import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:kpostal/kpostal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_text_styles.dart';
import '../utils/toast_helper.dart';
import '../services/cloudinary.dart';
import '../services/area_mapping_service.dart';

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
  
  // Original data for change detection
  Map<String, dynamic>? _originalData;

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

  // Validation error messages
  String? _placeNameError;
  String? _addressError;
  String? _managerNameError;
  String? _phoneError;
  String? _introError;

  // Operating hours data - 운영시간 관련 데이터
  List<String> _selectedOperatingDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']; // 선택된 운영 요일들 (기본값: 전체)
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
    _loadPlaceInfo();
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
        if (_photos.length >= 5) break; // Limit to 5 images for places

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
      if (_photos.length < 5) {
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

  void _validateFields() {
    setState(() {
      _placeNameError = _placeNameCtl.text.trim().isEmpty 
          ? '플레이스명을 입력해주세요' 
          : null;
      
      _addressError = _addressCtl.text.trim().isEmpty 
          ? '주소를 입력해주세요' 
          : null;
      
      _managerNameError = _managerNameCtl.text.trim().isEmpty 
          ? '담당자명을 입력해주세요' 
          : null;
      
      _phoneError = _phoneCtl.text.trim().isEmpty 
          ? '연락처를 입력해주세요'
          : _phoneCtl.text.replaceAll('-', '').length < 10
              ? '올바른 연락처를 입력해주세요'
              : null;
      
      _introError = null; // Place intro is now optional
    });
  }

  bool _isFormValid() {
    _validateFields();
    return _placeNameError == null &&
           _addressError == null &&
           _managerNameError == null &&
           _phoneError == null;
           // _introError removed - intro is now optional
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
                  
                  // Clear address error if it exists
                  if (_addressError != null) {
                    _addressError = null;
                  }
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

  Future<void> _loadPlaceInfo() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        debugPrint('No authenticated user for loading place info');
        return;
      }

      debugPrint('Loading place info for user: ${currentUser.id}');
      
      final response = await supabase
          .from('place_profiles')
          .select('*')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('No place profile found for user: ${currentUser.id}');
        return;
      }

      debugPrint('Place profile loaded: ${response.toString()}');

      if (mounted) {
        setState(() {
          // Basic info
          _placeNameCtl.text = response['place_name'] ?? '';
          _addressCtl.text = response['address'] ?? '';
          _detailAddressCtl.text = response['detail_address'] ?? '';
          _managerNameCtl.text = response['manager_name'] ?? '';
          _phoneCtl.text = response['manager_phone'] ?? '';
          _snsHandleCtl.text = response['sns_handle'] ?? '';
          _introCtl.text = response['intro'] ?? '';

          // Gender and SNS type
          final managerGender = response['manager_gender'];
          if (managerGender == 'MALE') {
            _selectedGender = '남';
          } else if (managerGender == 'FEMALE') {
            _selectedGender = '여';
          }

          final snsType = response['sns_type'];
          if (snsType != null && snsType.isNotEmpty) {
            _selectedSns = snsType;
          }

          // Address data
          _postCode = response['postcode'];
          _roadAddress = response['road_address'];
          _jibunAddress = response['jibun_address'];
          _latitude = response['latitude']?.toDouble();
          _longitude = response['longitude']?.toDouble();

          // Operating hours
          final operatingHours = response['operating_hours'];
          if (operatingHours != null) {
            final hours = operatingHours as Map<String, dynamic>;
            _selectedOperatingDays = List<String>.from(hours['days'] ?? []);
            _operatingStartHour = (hours['start_hour'] ?? 9.0).toDouble();
            _operatingEndHour = (hours['end_hour'] ?? 18.0).toDouble();
          }

          // Profile images
          final imageUrls = response['profile_image_urls'];
          if (imageUrls != null) {
            _loadedImageUrls.clear();
            _loadedImageUrls.addAll(List<String>.from(imageUrls));
          }

          final representativeIndex = response['representative_image_index'];
          if (representativeIndex != null && representativeIndex >= 0) {
            _representativeImageIndex = representativeIndex as int;
          }
          
          // Store original data for change detection
          _originalData = Map<String, dynamic>.from(response);
        });

        debugPrint('Place info loaded successfully');
      }
    } catch (e) {
      debugPrint('Error loading place info: $e');
      if (mounted) {
        ToastHelper.error(context, '정보 불러오기 중 오류가 발생했습니다');
      }
    }
  }

  /// 현재 폼 데이터와 원본 데이터를 비교하여 변경 여부 확인
  bool _hasDataChanged() {
    if (_originalData == null) {
      // 원본 데이터가 없으면 새로운 데이터로 간주 (저장 필요)
      return true;
    }

    // 새로 추가된 사진이 있으면 변경됨
    if (_photos.isNotEmpty) {
      return true;
    }

    // 기존 이미지 목록 비교
    final originalImages = List<String>.from(_originalData!['profile_image_urls'] ?? []);
    if (originalImages.length != _loadedImageUrls.length || 
        !_listEquals(originalImages, _loadedImageUrls)) {
      return true;
    }

    // 대표 이미지 인덱스 비교
    final originalRepIndex = _originalData!['representative_image_index'] ?? 0;
    if (_representativeImageIndex != originalRepIndex) {
      return true;
    }

    // 텍스트 필드 비교
    if (_placeNameCtl.text.trim() != (_originalData!['place_name'] ?? '')) return true;
    if ((_roadAddress ?? _addressCtl.text.trim()) != (_originalData!['address'] ?? '')) return true;
    if (_detailAddressCtl.text.trim() != (_originalData!['detail_address'] ?? '')) return true;
    if (_managerNameCtl.text.trim() != (_originalData!['manager_name'] ?? '')) return true;
    if (_phoneCtl.text.trim() != (_originalData!['manager_phone'] ?? '')) return true;
    if (_snsHandleCtl.text.trim() != (_originalData!['sns_handle'] ?? '')) return true;
    if (_introCtl.text.trim() != (_originalData!['intro'] ?? '')) return true;

    // 성별 비교
    String originalGender = _originalData!['manager_gender'] ?? '';
    String currentGender = _selectedGender == '남' ? 'MALE' : 'FEMALE';
    if (currentGender != originalGender) return true;

    // SNS 타입 비교
    if (_selectedSns != (_originalData!['sns_type'] ?? '')) return true;

    // 운영 시간 비교
    final originalOperatingHours = _originalData!['operating_hours'] as Map<String, dynamic>?;
    if (originalOperatingHours != null) {
      final originalDays = List<String>.from(originalOperatingHours['days'] ?? []);
      final originalStartHour = (originalOperatingHours['start_hour'] ?? 9.0).toDouble();
      final originalEndHour = (originalOperatingHours['end_hour'] ?? 18.0).toDouble();
      
      if (!_listEquals(_selectedOperatingDays, originalDays)) return true;
      if (_operatingStartHour != originalStartHour) return true;
      if (_operatingEndHour != originalEndHour) return true;
    } else if (_selectedOperatingDays.isNotEmpty || _operatingStartHour != 9.0 || _operatingEndHour != 18.0) {
      return true;
    }

    return false;
  }

  /// 리스트 비교를 위한 헬퍼 메서드
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  Future<void> _savePlaceInfo() async {
    if (!_isFormValid()) return;
    
    // Check if there are any changes
    if (!_hasDataChanged()) {
      ToastHelper.info(context, '변경사항이 없습니다');
      return;
    }

    if (_photos.isEmpty && _loadedImageUrls.isEmpty) {
      ToastHelper.warning(context, '플레이스 사진을 최소 1장 추가해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        ToastHelper.error(context, '로그인이 필요합니다');
        return;
      }

      // 1. Upload images to Cloudinary if new photos exist
      List<String> imageUrls = List.from(_loadedImageUrls);
      
      if (_photos.isNotEmpty) {
        for (int i = 0; i < _photos.length; i++) {
          try {
            final imageUrl = await CloudinaryService.instance.uploadPostImage(
              _photos[i],
              fileName: '${currentUser.id}_place_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
              folder: 'places',
              publicId: '${currentUser.id}_place_${DateTime.now().millisecondsSinceEpoch}_$i',
            );
            imageUrls.add(imageUrl);
          } catch (e) {
            debugPrint('Image upload error: $e');
            // Continue with other images even if one fails
          }
        }
      }

      // 2. Determine representative image URL
      String? representativeImageUrl;
      if (_representativeImageIndex >= 0 && _representativeImageIndex < imageUrls.length) {
        representativeImageUrl = imageUrls[_representativeImageIndex];
      } else if (imageUrls.isNotEmpty) {
        representativeImageUrl = imageUrls.first; // Default to first image
      }

      // 3. Format operating hours data
      final operatingHours = {
        'days': _selectedOperatingDays,
        'start_hour': _operatingStartHour,
        'end_hour': _operatingEndHour,
      };

      // 4. Map address to area group
      int? areaGroupId;
      try {
        final addressToMap = _roadAddress ?? _addressCtl.text.trim();
        if (addressToMap.isNotEmpty) {
          areaGroupId = await AreaMappingService.instance.mapAddressToAreaGroup(addressToMap);
          if (areaGroupId != null) {
            final areaName = await AreaMappingService.instance.getAreaGroupName(areaGroupId);
            debugPrint('Mapped address "$addressToMap" to area group: $areaName (ID: $areaGroupId)');
          } else {
            debugPrint('No area group found for address: $addressToMap');
          }
        }
      } catch (e) {
        debugPrint('Error mapping address to area group: $e');
      }

      // 5. Prepare place profile data
      final placeData = {
        'user_id': currentUser.id,
        'place_name': _placeNameCtl.text.trim(),
        'address': _roadAddress ?? _addressCtl.text.trim(),
        'detail_address': _detailAddressCtl.text.trim(),
        'postcode': _postCode,
        'road_address': _roadAddress,
        'jibun_address': _jibunAddress,
        'latitude': _latitude,
        'longitude': _longitude,
        'area_group_id': areaGroupId,
        'manager_name': _managerNameCtl.text.trim(),
        'manager_gender': _selectedGender,
        'manager_phone': _phoneCtl.text.trim(),
        'sns_type': _selectedSns.isNotEmpty ? _selectedSns : null,
        'sns_handle': _snsHandleCtl.text.trim().isNotEmpty ? _snsHandleCtl.text.trim() : null,
        'intro': _introCtl.text.trim(),
        'profile_image_urls': imageUrls,
        'representative_image_index': _representativeImageIndex >= 0 ? _representativeImageIndex : 0,
        'operating_hours': operatingHours,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 6. Debug logging - 전송할 데이터 확인
      debugPrint('=== Place Profile Save Data ===');
      debugPrint('User ID: ${currentUser.id}');
      debugPrint('Place Name: ${_placeNameCtl.text.trim()}');
      debugPrint('Address: ${_roadAddress ?? _addressCtl.text.trim()}');
      debugPrint('Detail Address: ${_detailAddressCtl.text.trim()}');
      debugPrint('Postcode: $_postCode');
      debugPrint('Road Address: $_roadAddress');
      debugPrint('Jibun Address: $_jibunAddress');
      debugPrint('Coordinates: $_latitude, $_longitude');
      debugPrint('Area Group ID: $areaGroupId');
      debugPrint('Manager: ${_managerNameCtl.text.trim()} ($_selectedGender)');
      debugPrint('Phone: ${_phoneCtl.text.trim()}');
      debugPrint('SNS: $_selectedSns - ${_snsHandleCtl.text.trim()}');
      debugPrint('Intro: ${_introCtl.text.trim()}');
      debugPrint('Image URLs (${imageUrls.length}): $imageUrls');
      debugPrint('Representative Image Index: $_representativeImageIndex');
      debugPrint('Operating Hours: $operatingHours');
      debugPrint('Full Data Object: $placeData');
      
      // 7. Save to Supabase (upsert to handle both create and update)
      debugPrint('Attempting to save to place_profiles table...');
      final response = await supabase
          .from('place_profiles')
          .upsert(placeData, onConflict: 'user_id')
          .select()
          .single();

      debugPrint('Place saved successfully: ${response['user_id']}');
      
      // Update original data after successful save
      _originalData = Map<String, dynamic>.from(response);
      
      // Clear new photos since they're now saved
      _photos.clear();

      if (mounted) {
        ToastHelper.success(context, '플레이스 정보가 저장되었습니다');
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Save place info error: $e');
      if (mounted) {
        String errorMessage = '저장 중 오류가 발생했습니다';
        if (e.toString().contains('duplicate key')) {
          errorMessage = '이미 등록된 플레이스입니다';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 연결을 확인해주세요';
        }
        ToastHelper.error(context, errorMessage);
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
            '최대 5장의 사진을 업로드할 수 있습니다. 대표 이미지를 선택하려면 사진의 왕관 아이콘을 탭하세요.',
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
                color: _placeNameError != null 
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _placeNameCtl,
              style: AppTextStyles.primaryText(context),
              onChanged: (value) {
                if (_placeNameError != null) {
                  setState(() {
                    _placeNameError = value.trim().isEmpty ? '플레이스명을 입력해주세요' : null;
                  });
                }
              },
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
            ),
          ),
          _buildErrorMessage(_placeNameError),
          const SizedBox(height: 20),

          // Address field with search button
          Text('주소', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _addressError != null 
                          ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
          _buildErrorMessage(_addressError),
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
                color: _managerNameError != null 
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _managerNameCtl,
              style: AppTextStyles.primaryText(context),
              onChanged: (value) {
                if (_managerNameError != null) {
                  setState(() {
                    _managerNameError = value.trim().isEmpty ? '담당자명을 입력해주세요' : null;
                  });
                }
              },
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
            ),
          ),
          _buildErrorMessage(_managerNameError),
          const SizedBox(height: 20),

          // Phone field
          Text('연락처', style: AppTextStyles.formLabel(context)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _phoneError != null 
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _phoneCtl,
              style: AppTextStyles.primaryText(context),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (_phoneError != null) {
                  setState(() {
                    _phoneError = value.trim().isEmpty 
                        ? '연락처를 입력해주세요'
                        : value.replaceAll('-', '').length < 10
                            ? '올바른 연락처를 입력해주세요'
                            : null;
                  });
                }
              },
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
            ),
          ),
          _buildErrorMessage(_phoneError),
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
              // No validator - intro is now optional
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
                selectedColor: Theme.of(context).colorScheme.primary,
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
                selectedColor: Theme.of(context).colorScheme.primary,
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
          
          // 시간 슬라이더 (툴팁 항상 표시)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
              valueIndicatorColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              showValueIndicator: ShowValueIndicator.onDrag,
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

  Widget _buildErrorMessage(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        errorMessage,
        style: AppTextStyles.captionText(context).copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
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

                        // Operating Hours Form
                        _buildOperatingHoursForm(),
                        const SizedBox(height: 24),

                        // Place Description Form
                        _buildPlaceDescriptionForm(),
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
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                                    style: AppTextStyles.buttonText(context).copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary,
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
