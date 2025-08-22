import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 기존 Settings에서 Navigator.push(basicInfoSheetRoute()) 로 호출하는 진입점 유지
Route<void> basicInfoSheetRoute() {
  return PageRouteBuilder<void>(
    opaque: false,
    barrierColor: Colors.black54,
    pageBuilder: (context, _, __) => const _BasicInfoWoltEntry(),
  );
}

// Theme extension: 공통 입력 테두리/엣지용 회색을 앱 전역에서 재사용하기 위해
// ThemeData에 편의 getter를 추가합니다. 앞으로 입력 컴포넌트는
// Theme.of(context).inputGrey 를 사용하면 됩니다.
extension _AppThemeExt on ThemeData {
  Color get inputGrey => Colors.grey.shade300;
}

class _BasicInfoWoltEntry extends StatefulWidget {
  const _BasicInfoWoltEntry();

  @override
  State<_BasicInfoWoltEntry> createState() => _BasicInfoWoltEntryState();
}

class _BasicInfoWoltEntryState extends State<_BasicInfoWoltEntry> {
  // 상태: 사진, 닉네임, 소개, 선호
  final ImagePicker _picker = ImagePicker();
  // 최대 5장까지 사진을 보관합니다.
  final List<Uint8List> _photos = <Uint8List>[];
  // 모달 라우트 트리에서 변화 감지를 위해 간단한 tick notifier 사용
  final ValueNotifier<int> _photosTick = ValueNotifier<int>(0);
  final TextEditingController _introCtl = TextEditingController();
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _snsHandleCtl = TextEditingController();
  final TextEditingController _ageCtl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  // 연락처 SNS 선택 (카카오톡 기본)
  final ValueNotifier<String> _snsN = ValueNotifier<String>('카카오톡');
  // gender state synchronized into modal via ValueNotifier to ensure
  // the modal page rebuilds when the value changes.
  final ValueNotifier<String> _genderN = ValueNotifier<String>('남');
  // notify when any form field changes so modal widgets can rebuild
  final ValueNotifier<int> _formTick = ValueNotifier<int>(0);
  // 총 페이지 수 (사진, 이름/나이/성별, 연락처, 소개)
  static const int _kTotalPages = 4;

  @override
  void initState() {
    super.initState();
    // 기본값 남으로 초기화 (ValueNotifier already initialized)
    // bump form tick when gender changes so modal children rebuild
    _genderN.addListener(() {
      if (mounted) _formTick.value++;
    });
    // listen to controller changes and focus changes to catch autofill/edits
    _nameCtl.addListener(() {
      if (mounted) _formTick.value++;
    });
    _ageCtl.addListener(() {
      if (mounted) _formTick.value++;
    });
    _nameFocus.addListener(() {
      if (mounted) _formTick.value++;
    });
    _ageFocus.addListener(() {
      if (mounted) _formTick.value++;
    });
    // 연락처 폼 변화 감지 + 자동 하이픈 포맷
    _phoneCtl.addListener(() {
      if (!mounted) return;
      final raw = _phoneCtl.text;
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      final formatted = _formatKoreanPhone(digits);
      if (formatted != raw) {
        // replace text while moving cursor to the end (simple but reliable)
        _phoneCtl.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      _formTick.value++;
    });
    // SNS 핸들 입력 변화 감지
    _snsHandleCtl.addListener(() {
      if (mounted) _formTick.value++;
    });
    _snsN.addListener(() {
      if (mounted) _formTick.value++;
    });
    // SharedPreferences 아바타 대체 로드
    _loadAvatarFallback();
  }

  bool get _isNameAgeGenderValid {
    final nameOk = _nameCtl.text.trim().isNotEmpty;
    final age = int.tryParse(_ageCtl.text.trim());
    final ageOk = age != null && age > 0 && age <= 120;
    final genderOk = _genderN.value == '남' || _genderN.value == '여';
    return nameOk && ageOk && genderOk;
  }

  Future<void> _pickFromGallery() async {
    try {
      // 다중 선택 허용
      final List<XFile> imgs = await _picker.pickMultiImage(imageQuality: 85);
      if (imgs.isEmpty) return;
      for (final img in imgs) {
        if (_photos.length >= 5) break; // 최대 개수 제한
        final bytes = await img.readAsBytes();
        if (!mounted) return;
        debugPrint('picked gallery image: ${bytes.length} bytes');
        _photos.add(bytes);
      }
      // notify listeners to rebuild thumbnails
      _photosTick.value++;
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
      if (!mounted) return;
      if (_photos.length < 5) {
        _photos.add(bytes);
        _photosTick.value++;
      }
    } catch (e) {
      debugPrint('error picking camera image: $e');
    }
  }

  bool _sheetOpened = false;

  Future<void> _loadAvatarFallback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final b64 = prefs.getString('avatar_b64');
      if (!mounted || b64 == null || b64.isEmpty) return;
      final bytes = base64Decode(b64);
      if (!mounted) return;
      if (_photos.isEmpty && bytes.isNotEmpty) {
        setState(() => _photos.add(bytes));
        _photosTick.value++;
      }
    } catch (e) {
      debugPrint('avatar fallback load error: $e');
    }
  }

  bool get _isPhoneValid {
    final digits = _phoneCtl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;
    // 한국 휴대폰: 01로 시작, 총 10~11자리 (예: 01012345678, 0111234567)
    final mobileSimple = RegExp(r'^01\d{8,9}$');
    return mobileSimple.hasMatch(digits);
  }

  String _formatKoreanPhone(String digits) {
    // digits: only numeric characters
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (digits.length <= 10) {
      if (digits.length == 10) {
        // 3-3-4
        return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
      }
      // 3-4-4 (11 digits)
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    // longer: fall back to grouping after 3-4-...
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  }

  // 페이지: 연락처 입력 (휴대폰 필수, SNS 선택사항)
  WoltModalSheetPage _pageContact(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return WoltModalSheetPage(
      pageTitle: Padding(
        padding: const EdgeInsets.all(_kPad),
        child: Text(
          '빠른 연락을 위해 정보를 남겨주세요.(선택)',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leadingNavBarWidget: IconButton(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        icon: const Icon(SolarIconsOutline.arrowLeft, size: 20),
        onPressed: WoltModalSheet.of(modalSheetContext).showPrevious,
      ),
      trailingNavBarWidget: _buildTrailingWithProgress(
        modalSheetContext,
        current: 3,
        total: _kTotalPages,
      ),
      stickyActionBar: ValueListenableBuilder<int>(
        valueListenable: _formTick,
        builder: (context, _, __) => Padding(
          padding: const EdgeInsets.all(_kPad),
          child: ElevatedButton(
            onPressed: (_phoneCtl.text.trim().isEmpty || _isPhoneValid)
                ? WoltModalSheet.of(modalSheetContext).showNext
                : null,
            child: const SizedBox(
              height: _kBtnHeight,
              width: double.infinity,
              child: Center(child: Text('다음')),
            ),
          ),
        ),
      ),
      child: _SwipeToPaginate(
        onNext: (_phoneCtl.text.trim().isEmpty || _isPhoneValid)
            ? WoltModalSheet.of(modalSheetContext).showNext
            : null,
        onPrevious: WoltModalSheet.of(modalSheetContext).showPrevious,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_kPad, _kPad, _kPad, _kBottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 휴대폰: 사진 컨테이너처럼 테두리 상단에 라벨이 겹치도록 배치
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    // keep padding and border radius but remove filled background
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: TextFormField(
                      controller: _phoneCtl,
                      style: Theme.of(modalSheetContext).textTheme.bodyMedium
                          ?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: '휴대폰 번호',
                        labelStyle: Theme.of(modalSheetContext)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: '예: 010-1234-5678',
                        hintStyle: Theme.of(modalSheetContext)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                        prefixIcon: Icon(
                          SolarIconsOutline.phone,
                          size: 20,
                          color: Theme.of(
                            modalSheetContext,
                          ).colorScheme.onSurfaceVariant,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(modalSheetContext).inputGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              modalSheetContext,
                            ).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => _formTick.value++,
                    ),
                  ),
                  // overlay label removed: use inner labelText for consistency with name/age fields
                ],
              ),
              const SizedBox(height: 20),

              // SNS: photo 스타일과 동일하게 라벨이 테두리에 걸치도록 컨테이너에 담음
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _snsN.value,
                            style: Theme.of(modalSheetContext)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                            items: const [
                              DropdownMenuItem(
                                value: '카카오톡',
                                child: Text('카카오톡'),
                              ),
                              DropdownMenuItem(
                                value: '텔레그램',
                                child: Text('텔레그램'),
                              ),
                              DropdownMenuItem(value: '라인', child: Text('라인')),
                              DropdownMenuItem(
                                value: '인스타',
                                child: Text('인스타'),
                              ),
                              DropdownMenuItem(
                                value: '페이스북',
                                child: Text('페이스북'),
                              ),
                              DropdownMenuItem(value: '틱톡', child: Text('틱톡')),
                              DropdownMenuItem(value: '', child: Text('선택 안함')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                _snsN.value = v;
                                if (v.isEmpty) _snsHandleCtl.clear();
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'SNS 서비스',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(modalSheetContext).inputGrey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(
                                    modalSheetContext,
                                  ).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: ValueListenableBuilder<String>(
                            valueListenable: _snsN,
                            builder: (context, val, _) {
                              final enabled = val.isNotEmpty;
                              return TextFormField(
                                controller: _snsHandleCtl,
                                style: Theme.of(modalSheetContext)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                enabled: enabled,
                                decoration: InputDecoration(
                                  labelText: enabled ? 'SNS 아이디/핸들' : 'SNS 미선택',
                                  labelStyle: Theme.of(modalSheetContext)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: enabled ? '예: your_handle' : '',
                                  hintStyle: Theme.of(modalSheetContext)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  prefixIcon: Icon(
                                    SolarIconsOutline.userCircle,
                                    size: 20,
                                    color: Theme.of(
                                      modalSheetContext,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        modalSheetContext,
                                      ).inputGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        modalSheetContext,
                                      ).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (_) => _formTick.value++,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 우측 닫기 버튼 왼쪽에 (n/총) 진행 상태를 함께 표시하는 trailing 위젯
  Widget _buildTrailingWithProgress(
    BuildContext modalSheetContext, {
    required int current,
    required int total,
  }) {
    final textTheme = Theme.of(modalSheetContext).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text('($current/$total)', style: textTheme.labelMedium),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          onPressed: () => Navigator.of(modalSheetContext).pop(),
          icon: const Icon(SolarIconsOutline.closeCircle, size: 20),
        ),
      ],
    );
  }

  // 페이지 1: 사진 선택/미리보기
  WoltModalSheetPage _pageIntro(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return WoltModalSheetPage(
      pageTitle: Padding(
        padding: const EdgeInsets.all(_kPad),
        child: Text(
          '플레이스에 어필할 매력적인 사진을 올려보세요',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // 헤더(Top bar)를 사용하지 않고 내부 타이틀(pageTitle)만 사용하여
      // 샘플처럼 상단이 자연스럽게 보이게 합니다.
      leadingNavBarWidget: null,
      trailingNavBarWidget: _buildTrailingWithProgress(
        modalSheetContext,
        current: 1,
        total: _kTotalPages,
      ),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(_kPad),
        child: ElevatedButton(
          onPressed: () => WoltModalSheet.of(modalSheetContext).showNext(),
          child: const SizedBox(
            height: _kBtnHeight,
            width: double.infinity,
            child: Center(child: Text('다음')),
          ),
        ),
      ),
      child: _SwipeToPaginate(
        onNext: WoltModalSheet.of(modalSheetContext).showNext,
        onPrevious: null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_kPad, _kPad, _kPad, _kBottomPad),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이전에 요청하셨던 3개의 정보 텍스트(아이콘 포함)
                Row(
                  children: const [
                    Icon(SolarIconsOutline.infoCircle, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('사진은 지원한 플레이스에만 공개돼요')),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(SolarIconsOutline.checkCircle, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('가장 매력적인 선명한 사진을 올려주세요')),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(SolarIconsOutline.lock, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('프로필 사진은 암호화하여 저장되며 외부에 노출되지 않습니다')),
                  ],
                ),

                const SizedBox(height: 12),

                // 카메라 / 앨범 버튼 (일관된 스타일)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _pickFromCamera,
                        icon: const Icon(SolarIconsOutline.cameraMinimalistic),
                        label: const Text('카메라'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(
                            modalSheetContext,
                          ).colorScheme.onSurface,
                          side: BorderSide(
                            color: Theme.of(modalSheetContext).inputGrey,
                          ),
                          textStyle: Theme.of(modalSheetContext)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                          elevation: 6,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(SolarIconsOutline.galleryMinimalistic),
                        label: const Text('앨범에서 불러오기'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(
                            modalSheetContext,
                          ).colorScheme.onSurface,
                          side: BorderSide(
                            color: Theme.of(modalSheetContext).inputGrey,
                          ),
                          textStyle: Theme.of(modalSheetContext)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                          elevation: 6,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 섬네일 스트립: 비어 있어도 placeholder를 노출해 영역을 고정
                SizedBox(
                  height: 80,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _photosTick,
                    builder: (context, _, __) => _buildThumbnails(),
                  ),
                ),

                const SizedBox(height: 8),

                Text('최대 5장의 사진을 업로드할 수 있습니다.', style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    if (_photos.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).inputGrey),
            color: Colors.grey.shade100,
          ),
          child: Icon(
            SolarIconsOutline.userCircle,
            size: 24,
            color: Colors.grey,
          ),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _photos.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _photos[index],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (context, error, stack) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(
                    SolarIconsOutline.dangerTriangle,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    setState(() => _photos.removeAt(index));
                    _photosTick.value++;
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        SolarIconsOutline.closeCircle,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 페이지 3: 이름/나이/성별
  WoltModalSheetPage _pageNameAgeGender(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return WoltModalSheetPage(
      pageTitle: Padding(
        padding: const EdgeInsets.all(_kPad),
        child: Text(
          '나를 알아 볼 수 있는 정보를 입력해 주세요',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leadingNavBarWidget: IconButton(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        icon: const Icon(SolarIconsOutline.arrowLeft, size: 20),
        onPressed: WoltModalSheet.of(modalSheetContext).showPrevious,
      ),
      trailingNavBarWidget: _buildTrailingWithProgress(
        modalSheetContext,
        current: 2,
        total: _kTotalPages,
      ),
      stickyActionBar: ValueListenableBuilder<int>(
        valueListenable: _formTick,
        builder: (context, _, __) => Padding(
          padding: const EdgeInsets.all(_kPad),
          child: ElevatedButton(
            onPressed: _isNameAgeGenderValid
                ? WoltModalSheet.of(modalSheetContext).showNext
                : null,
            child: const SizedBox(
              height: _kBtnHeight,
              width: double.infinity,
              child: Center(child: Text('다음')),
            ),
          ),
        ),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _formTick,
        builder: (context, _, __) {
          return _SwipeToPaginate(
            onNext: _isNameAgeGenderValid
                ? WoltModalSheet.of(modalSheetContext).showNext
                : null,
            onPrevious: WoltModalSheet.of(modalSheetContext).showPrevious,
            child: Padding(
              // reduce bottom padding on this form page so the space under
              // the gender buttons is smaller while keeping sticky action bar
              // reserve large enough area. 96.0 is slimmer than the global
              // _kBottomPad used elsewhere.
              padding: const EdgeInsets.fromLTRB(_kPad, _kPad, _kPad, 96.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름 (Material 3 테마로 복원)
                  TextFormField(
                    controller: _nameCtl,
                    style: Theme.of(modalSheetContext).textTheme.bodyMedium
                        ?.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: '이름',
                      labelStyle: Theme.of(modalSheetContext)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                      hintText: '이름을 입력해주세요',
                      hintStyle: Theme.of(modalSheetContext)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                      helperText: '실명 또는 예명을 입력해주세요',
                      prefixIcon: Icon(
                        SolarIconsOutline.userCircle,
                        size: 20,
                        color: Theme.of(
                          modalSheetContext,
                        ).colorScheme.onSurfaceVariant,
                      ),
                      // no filled background: rely on outline border only
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(modalSheetContext).inputGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            modalSheetContext,
                          ).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => _formTick.value++,
                  ),
                  const SizedBox(height: 20),

                  // 나이 (Material 3 테마로 복원)
                  TextFormField(
                    controller: _ageCtl,
                    style: Theme.of(modalSheetContext).textTheme.bodyMedium
                        ?.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: '나이',
                      labelStyle: Theme.of(modalSheetContext)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                      hintText: '숫자만 입력',
                      hintStyle: Theme.of(modalSheetContext)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                      helperText: '만 나이 기준으로 입력해주세요',
                      prefixIcon: Icon(
                        SolarIconsOutline.calendarMinimalistic,
                        size: 20,
                        color: Theme.of(
                          modalSheetContext,
                        ).colorScheme.onSurfaceVariant,
                      ),
                      // no filled background: rely on outline border only
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(modalSheetContext).inputGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            modalSheetContext,
                          ).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => _formTick.value++,
                  ),
                  const SizedBox(height: 20),

                  // 성별 (Material 3 세그먼트 버튼으로 통합)
                  Text(
                    '성별',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: _genderN,
                    builder: (context, gender, _) {
                      return SegmentedButton<String>(
                        segments: const <ButtonSegment<String>>[
                          ButtonSegment(value: '남', label: Text('남')),
                          ButtonSegment(value: '여', label: Text('여')),
                        ],
                        selected: <String>{gender},
                        onSelectionChanged: (Set<String> newSelection) {
                          if (newSelection.isNotEmpty) {
                            _genderN.value = newSelection.first;
                            _formTick.value++;
                          }
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // selected state color and border
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.primary;
                              }
                              return Colors.transparent;
                            },
                          ),
                          side: WidgetStateProperty.resolveWith<BorderSide?>(
                            (states) {
                              return BorderSide(
                                color: Theme.of(context).inputGrey,
                              );
                            },
                          ),
                          textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                            (states) {
                              return TextStyle(
                                fontWeight: states.contains(WidgetState.selected)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              );
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return Theme.of(context).colorScheme.onSurface;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 페이지 4: 소개글
  WoltModalSheetPage _pageIntroText(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return WoltModalSheetPage(
      pageTitle: Padding(
        padding: const EdgeInsets.all(_kPad),
        child: Text(
          '간단한 자기 소개를 적어주세요.',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leadingNavBarWidget: IconButton(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        icon: const Icon(SolarIconsOutline.arrowLeft, size: 20),
        onPressed: WoltModalSheet.of(modalSheetContext).showPrevious,
      ),
      trailingNavBarWidget: _buildTrailingWithProgress(
        modalSheetContext,
        current: 4,
        total: _kTotalPages,
      ),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(_kPad),
        child: ElevatedButton(
          onPressed: () => Navigator.of(modalSheetContext).pop(),
          child: const SizedBox(
            height: _kBtnHeight,
            width: double.infinity,
            child: Center(child: Text('완료')),
          ),
        ),
      ),
      child: _SwipeToPaginate(
        onNext: null,
        onPrevious: WoltModalSheet.of(modalSheetContext).showPrevious,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_kPad, _kPad, _kPad, _kBottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: _introCtl,
                style: Theme.of(modalSheetContext).textTheme.bodyMedium
                    ?.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                maxLength: 140,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '취미, 관심사, 하고 싶은 것 등 자유롭게 적어주세요.',
                  hintStyle: Theme.of(modalSheetContext).textTheme.bodyMedium
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                  // no filled background: rely on outline border only
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(modalSheetContext).inputGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(modalSheetContext).colorScheme.primary,
                      width: 2,
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
  Widget build(BuildContext context) {
    // Show the modal once when this page is pushed.
    if (!_sheetOpened) {
      _sheetOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = Navigator.of(context);
        WoltModalSheet.show(
          context: context,
          pageListBuilder: (modalContext) => [
            _pageIntro(modalContext, Theme.of(modalContext).textTheme),
            _pageNameAgeGender(modalContext, Theme.of(modalContext).textTheme),
            _pageContact(modalContext, Theme.of(modalContext).textTheme),
            _pageIntroText(modalContext, Theme.of(modalContext).textTheme),
          ],
          modalTypeBuilder: (ctx) => WoltModalType.bottomSheet(),
          onModalDismissedWithBarrierTap: () => nav.maybePop(),
        ).then((_) {
          if (mounted) nav.maybePop();
        });
      });
    }

    return const Scaffold(backgroundColor: Colors.transparent);
  }

  @override
  void dispose() {
    _photosTick.dispose();
    _formTick.dispose();
    _genderN.dispose();
    _nameCtl.dispose();
    _ageCtl.dispose();
    _introCtl.dispose();
    _phoneCtl.dispose();
    _snsHandleCtl.dispose();
    _snsN.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }
}

// 공통 상수
const double _kBottomPad = 150.0;
const double _kBtnHeight = 48.0;
const double _kPad = 16.0;

// 이하 페이지 빌더 함수들은 Stateful 클래스 안으로 이동했습니다.

/// 스와이프(좌/우)로 페이지 전환을 트리거하는 래퍼
class _SwipeToPaginate extends StatelessWidget {
  const _SwipeToPaginate({required this.child, this.onNext, this.onPrevious});

  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  static const double _velocityThreshold = 250; // px/s
  static const double _distanceThreshold = 40; // logical px

  @override
  Widget build(BuildContext context) {
    Offset? start;
    bool handled = false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (d) {
        start = d.localPosition;
        handled = false;
      },
      onHorizontalDragUpdate: (d) {
        if (handled || start == null) return;
        final dx = d.localPosition.dx - start!.dx;
        if (dx.abs() > _distanceThreshold) {
          handled = true;
          if (dx < 0) {
            onNext?.call();
          } else {
            onPrevious?.call();
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (handled) return;
        final vx = details.velocity.pixelsPerSecond.dx;
        if (vx.abs() < _velocityThreshold) return;
        if (vx < 0) {
          onNext?.call();
        } else {
          onPrevious?.call();
        }
      },
      child: child,
    );
  }
}
