import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_text_styles.dart';
import '../../services/attribute_service.dart';
import 'services/place_preferences_service.dart';
import '../../utils/toast_helper.dart';

class PlaceMatchingPreferencesPage extends StatefulWidget {
  const PlaceMatchingPreferencesPage({super.key});

  @override
  State<PlaceMatchingPreferencesPage> createState() =>
      _PlaceMatchingPreferencesPageState();
}

class _PlaceMatchingPreferencesPageState
    extends State<PlaceMatchingPreferencesPage>
    with TickerProviderStateMixin {
  // Form state variables
  Set<String> selectedIndustries = {};
  Set<String> selectedJobs = {};
  String? selectedPayType;
  final TextEditingController _payAmountController = TextEditingController();
  Set<String> selectedDays = {};
  String? selectedExperienceLevel;
  Set<String> selectedStyles = {};
  Set<String> selectedPlaceFeatures = {};
  Set<String> selectedBenefits = {};

  // Data loading state
  bool _isLoading = true;
  bool _isSaving = false;

  // Animation controllers
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  // Data from services
  List<Map<String, dynamic>> industries = [];
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> styles = [];
  List<Map<String, dynamic>> placeFeatures = [];
  List<Map<String, dynamic>> benefits = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeOutCubic),
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _payAmountController.dispose();
    super.dispose();
  }

  // Static data for working days and experience levels (not in database)
  final List<String> payTypes = ['TC', '일급', '월급', '협의'];
  final List<String> experienceLevels = ['무관', '신입', '주니어', '시니어', '전문가'];

  final List<Map<String, String>> daysTop = [
    {'id': '전체', 'name': '전체'},
    {'id': '월', 'name': '월'},
    {'id': '화', 'name': '화'},
    {'id': '수', 'name': '수'},
  ];

  final List<Map<String, String>> daysBottom = [
    {'id': '목', 'name': '목'},
    {'id': '금', 'name': '금'},
    {'id': '토', 'name': '토'},
    {'id': '일', 'name': '일'},
  ];

  /// Load all data from services
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Clear cache to ensure fresh data with emojis
      AttributeService.instance.clearCache();

      // Load attributes data from service
      final industryData = AttributeService.instance.getAttributesForUI(
        'INDUSTRY',
      );
      final jobData = AttributeService.instance.getAttributesForUI('JOB_ROLE');
      final styleData = AttributeService.instance.getAttributesForUI(
        'MEMBER_STYLE',
      );
      final placeFeatureData = AttributeService.instance.getAttributesForUI(
        'PLACE_FEATURE',
      );
      final benefitData = AttributeService.instance.getAttributesForUI(
        'WELFARE',
      );

      // Load existing place preferences
      final existingPreferences = PlacePreferencesService.instance
          .loadMatchingPreferences();

      // Wait for all data to load
      final results = await Future.wait([
        industryData,
        jobData,
        styleData,
        placeFeatureData,
        benefitData,
        existingPreferences,
      ]);

      setState(() {
        industries = results[0] as List<Map<String, dynamic>>;
        jobs = results[1] as List<Map<String, dynamic>>;
        styles = results[2] as List<Map<String, dynamic>>;
        placeFeatures = results[3] as List<Map<String, dynamic>>;
        benefits = results[4] as List<Map<String, dynamic>>;

        // Load existing place preferences
        final prefs = results[5] as PlacePreferencesData?;
        if (prefs != null) {
          selectedIndustries = prefs.selectedIndustryIds;
          selectedJobs = prefs.selectedJobIds;
          selectedPayType = prefs.selectedPayType;
          if (prefs.payAmount != null) {
            _payAmountController.text = prefs.payAmount.toString();
          }
          selectedDays = prefs.selectedDays;
          selectedExperienceLevel = prefs.experienceLevel;
          selectedStyles = prefs.selectedStyleIds;
          selectedPlaceFeatures = prefs.selectedPlaceFeatureIds;
          selectedBenefits = prefs.selectedWelfareIds;
        }

        _isLoading = false;
      });

      // Start fade animation after data is loaded
      _fadeController!.forward();
    } catch (e) {
      debugPrint('Error loading matching preferences data: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ToastHelper.error(context, '데이터 로딩 중 오류가 발생했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside input fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          title: Text('매칭 조건 설정', style: AppTextStyles.pageTitle(context)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '매칭 조건 정보를 불러오는 중...',
                      style: AppTextStyles.secondaryText(context),
                    ),
                  ],
                ),
              )
            : _fadeAnimation != null
            ? FadeTransition(
                opacity: _fadeAnimation!,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Individual cards for each section
                            _buildIndustryCard(),
                            const SizedBox(height: 20),

                            _buildJobCard(),
                            const SizedBox(height: 20),

                            _buildPayConditionCard(),
                            const SizedBox(height: 20),

                            _buildExperienceLevelCard(),
                            const SizedBox(height: 20),

                            _buildWorkingDaysCard(),
                            const SizedBox(height: 20),

                            _buildMemberStyleCard(),
                            const SizedBox(height: 20),

                            _buildPlaceFeaturesCard(),
                            const SizedBox(height: 20),

                            _buildBenefitsCard(),
                            const SizedBox(height: 32),

                            // Save button
                            _buildSaveButton(),

                            SizedBox(
                              height: 24 + MediaQuery.paddingOf(context).bottom,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ), // Close Scaffold
    ); // Close GestureDetector
  }

  Widget _buildIndustryCard() {
    return _buildCard(
      icon: '🏢',
      title: '모집 업종',
      subtitle: '운영하시는 업종을 선택해주세요',
      child: _buildEnhancedChipGroup(
        items: industries,
        selectedItems: selectedIndustries,
        onChanged: (selected) {
          setState(() {
            selectedIndustries = selected;
          });
        },
        showIcon: true,
      ),
    );
  }

  Widget _buildJobCard() {
    return _buildCard(
      icon: '💼',
      title: '모집 직무',
      subtitle: '매칭이 필요한 직무를 선택해주세요',
      child: _buildEnhancedChipGroup(
        items: jobs,
        selectedItems: selectedJobs,
        onChanged: (selected) {
          setState(() {
            selectedJobs = selected;
          });
        },
        showIcon: true,
      ),
    );
  }

  Widget _buildPayConditionCard() {
    return _buildCard(
      icon: '💰',
      title: '급여 조건',
      subtitle: '제공 가능한 급여 조건을 설정해주세요',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildEnhancedDropdown(
                  hint: '급여 형태',
                  value: selectedPayType,
                  items: payTypes,
                  onChanged: (value) {
                    setState(() {
                      selectedPayType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedTextField(
                  controller: _payAmountController,
                  hint: '제공 금액',
                  suffix: '만원',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceLevelCard() {
    return _buildCard(
      icon: '🏆',
      title: '경력 수준',
      subtitle: '원하는 스타의 경력 수준을 선택해주세요',
      child: _buildCompactChipGroup(
        items: experienceLevels
            .map((level) => {'id': level, 'name': level})
            .toList(),
        selectedItems: selectedExperienceLevel != null
            ? {selectedExperienceLevel!}
            : {},
        onChanged: (selected) {
          setState(() {
            selectedExperienceLevel = selected.isNotEmpty
                ? selected.first
                : null;
          });
        },
        multiSelect: false,
      ),
    );
  }

  Widget _buildWorkingDaysCard() {
    return _buildCard(
      icon: '📅',
      title: '근무 요일',
      subtitle: '필요한 근무 요일을 선택해주세요',
      child: Column(
        children: [
          // 간단한 전체/선택 방식 선택
          Row(
            children: [
              Expanded(
                child: _buildWorkingDayToggle(
                  '전체',
                  selectedDays.length == 7,
                  () {
                    setState(() {
                      if (selectedDays.length == 7) {
                        selectedDays.clear();
                      } else {
                        selectedDays = {'월', '화', '수', '목', '금', '토', '일'};
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWorkingDayToggle(
                  '평일',
                  selectedDays.containsAll(['월', '화', '수', '목', '금']),
                  () {
                    setState(() {
                      final weekdays = {'월', '화', '수', '목', '금'};
                      if (selectedDays.containsAll(weekdays)) {
                        selectedDays.removeAll(weekdays);
                      } else {
                        selectedDays.addAll(weekdays);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWorkingDayToggle(
                  '주말',
                  selectedDays.containsAll(['토', '일']),
                  () {
                    setState(() {
                      final weekends = {'토', '일'};
                      if (selectedDays.containsAll(weekends)) {
                        selectedDays.removeAll(weekends);
                      } else {
                        selectedDays.addAll(weekends);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 개별 요일 선택
          _buildCompactChipGroup(
            items: [
              '월',
              '화',
              '수',
              '목',
              '금',
              '토',
              '일',
            ].map((day) => {'id': day, 'name': day}).toList(),
            selectedItems: selectedDays,
            onChanged: (selected) {
              setState(() {
                selectedDays = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberStyleCard() {
    return _buildCard(
      icon: '✨',
      title: '희망 스타 스타일',
      subtitle: '원하는 스타의 스타일을 선택해주세요',
      child: _buildEnhancedChipGroup(
        items: styles,
        selectedItems: selectedStyles,
        onChanged: (selected) {
          setState(() {
            selectedStyles = selected;
          });
        },
        prefix: '#',
      ),
    );
  }

  Widget _buildPlaceFeaturesCard() {
    return _buildCard(
      icon: '🏪',
      title: '플레이스 특징',
      subtitle: '우리 플레이스의 특징을 선택해주세요',
      child: _buildEnhancedChipGroup(
        items: placeFeatures,
        selectedItems: selectedPlaceFeatures,
        onChanged: (selected) {
          setState(() {
            selectedPlaceFeatures = selected;
          });
        },
        prefix: '#',
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return _buildCard(
      icon: '🎁',
      title: '복지 및 혜택',
      subtitle: '제공 가능한 복지를 선택해주세요',
      child: _buildEnhancedChipGroup(
        items: benefits,
        selectedItems: selectedBenefits,
        onChanged: (selected) {
          setState(() {
            selectedBenefits = selected;
          });
        },
        prefix: '#',
      ),
    );
  }

  Widget _buildCard({
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.captionText(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildEnhancedChipGroup({
    required List<Map<String, dynamic>> items,
    required Set<String> selectedItems,
    required Function(Set<String>) onChanged,
    bool multiSelect = true,
    String? prefix,
    bool showIcon = false,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map<Widget>((item) {
        final isSelected = selectedItems.contains(item['id']);
        return _buildEnhancedChip(
          label: item['name']!,
          icon: showIcon ? item['icon'] : null,
          prefix: prefix,
          isSelected: isSelected,
          onTap: () {
            Set<String> newSelection = Set.from(selectedItems);
            if (multiSelect) {
              if (isSelected) {
                newSelection.remove(item['id']!);
              } else {
                newSelection.add(item['id']!);
              }
            } else {
              if (isSelected) {
                newSelection.clear();
              } else {
                newSelection = {item['id']!};
              }
            }
            onChanged(newSelection);
          },
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedChip({
    required String label,
    String? icon,
    String? prefix,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Text(icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                ],
                if (prefix != null) ...[
                  Text(
                    prefix,
                    style: AppTextStyles.chipLabel(context).copyWith(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                Text(
                  label,
                  style: AppTextStyles.chipLabel(context).copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChipGroup({
    required List<Map<String, dynamic>> items,
    required Set<String> selectedItems,
    required Function(Set<String>) onChanged,
    bool multiSelect = true,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map<Widget>((item) {
        final isSelected = selectedItems.contains(item['id']);
        return _buildCompactChip(
          label: item['name']!,
          isSelected: isSelected,
          onTap: () {
            Set<String> newSelection = Set.from(selectedItems);
            if (multiSelect) {
              if (isSelected) {
                newSelection.remove(item['id']!);
              } else {
                newSelection.add(item['id']!);
              }
            } else {
              if (isSelected) {
                newSelection.clear();
              } else {
                newSelection = {item['id']!};
              }
            }
            onChanged(newSelection);
          },
        );
      }).toList(),
    );
  }

  Widget _buildCompactChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.captionText(context).copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingDayToggle(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.captionText(context).copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(hint, style: AppTextStyles.primaryText(context)),
          ),
          value: value,
          isExpanded: true,
          style: AppTextStyles.primaryText(context),
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(item, style: AppTextStyles.primaryText(context)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSaving ? null : _savePreferences,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _isSaving
                  ? [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '저장 중...',
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]
                  : [
                      Icon(
                        Icons.favorite_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '매칭 조건 저장하기',
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Create PlacePreferencesData from current form state
      final preferences = PlacePreferencesData(
        selectedIndustryIds: selectedIndustries,
        selectedJobIds: selectedJobs,
        selectedPayType: selectedPayType,
        payAmount: _payAmountController.text.isNotEmpty
            ? int.tryParse(_payAmountController.text)
            : null,
        selectedDays: selectedDays,
        experienceLevel: selectedExperienceLevel,
        selectedStyleIds: selectedStyles,
        selectedPlaceFeatureIds: selectedPlaceFeatures,
        selectedWelfareIds: selectedBenefits,
      );

      // Save preferences using PlacePreferencesService
      final success = await PlacePreferencesService.instance
          .saveMatchingPreferences(preferences);

      if (!mounted) return;

      if (success) {
        // 즉시 프로그레스바 중단
        setState(() {
          _isSaving = false;
        });
        
        ToastHelper.success(context, '매칭 조건이 저장되었습니다');
        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ToastHelper.error(context, '저장 중 오류가 발생했습니다');
        // 실패 시 프로그레스바 중단
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      if (!mounted) return;

      ToastHelper.error(context, '저장 중 오류가 발생했습니다');
      // 오류 시 프로그레스바 중단
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
    // finally 블록 제거 - 각 케이스에서 직접 처리
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.primaryText(context),
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.primaryText(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          suffixText: suffix,
          suffixStyle: AppTextStyles.primaryText(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
