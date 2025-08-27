import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_text_styles.dart';
import '../../services/attribute_service.dart';
import 'services/member_preferences_service.dart';
import 'services/matching_conditions_service.dart';
import '../../utils/toast_helper.dart';

class MatchingPreferencesPage extends StatefulWidget {
  const MatchingPreferencesPage({super.key});

  @override
  State<MatchingPreferencesPage> createState() =>
      _MatchingPreferencesPageState();
}

class _MatchingPreferencesPageState extends State<MatchingPreferencesPage>
    with TickerProviderStateMixin {


  // Form state variables
  Set<String> selectedIndustries = {};
  Set<String> selectedJobs = {};
  String? selectedPayType;
  final TextEditingController _payAmountController = TextEditingController();
  Set<String> selectedDays = {};
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

  // Static data for working days (not in database)
  final List<String> payTypes = ['TC', '일급', '월급', '협의'];

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
      final industryData = AttributeService.instance.getAttributesForUI('INDUSTRY');
      final jobData = AttributeService.instance.getAttributesForUI('JOB_ROLE');
      final styleData = AttributeService.instance.getAttributesForUI('MEMBER_STYLE');
      final placeFeatureData = AttributeService.instance.getAttributesForUI('PLACE_FEATURE');
      final benefitData = AttributeService.instance.getAttributesForUI('WELFARE');

      // Load existing user preferences
      final existingPreferences = MemberPreferencesService.instance.loadMatchingPreferences();

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
        
        // Load existing preferences if available
        final prefs = results[5] as MatchingPreferencesData?;
        if (prefs != null) {
          selectedIndustries = prefs.selectedIndustryIds.map((id) => id.toString()).toSet();
          selectedJobs = prefs.selectedJobIds.map((id) => id.toString()).toSet();
          selectedPayType = prefs.selectedPayType;
          if (prefs.payAmount != null) {
            _payAmountController.text = prefs.payAmount.toString();
          }
          selectedDays = prefs.selectedDays;
          selectedStyles = prefs.selectedStyleIds.map((id) => id.toString()).toSet();
          selectedPlaceFeatures = prefs.selectedPlaceFeatureIds.map((id) => id.toString()).toSet();
          selectedBenefits = prefs.selectedWelfareIds.map((id) => id.toString()).toSet();
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        title: Text('매칭 스타일 설정', style: AppTextStyles.pageTitle(context)),
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
                    '매칭 스타일 정보를 불러오는 중...',
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
                          const SizedBox(height: 24),

                          // Individual cards for each section
                          _buildIndustryCard(),
                          const SizedBox(height: 20),

                          _buildJobCard(),
                          const SizedBox(height: 20),

                          _buildPayConditionCard(),
                          const SizedBox(height: 20),

                          _buildWorkingDaysCard(),
                          const SizedBox(height: 20),

                          _buildPersonalStyleCard(),
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
    );
  }

  Widget _buildIndustryCard() {
    return _buildCard(
      icon: '🏢',
      title: '희망 업종',
      subtitle: '관심 있는 업종을 모두 선택해주세요',
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
      title: '희망 직무',
      subtitle: '경험해보고 싶은 직무를 선택해주세요',
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
      subtitle: '원하시는 급여 조건을 설정해주세요',
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
                  hint: '희망 금액',
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

  Widget _buildWorkingDaysCard() {
    return _buildCard(
      icon: '📅',
      title: '근무 요일',
      subtitle: '가능한 근무 요일을 선택해주세요',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 첫 번째 줄: 전체, 월, 화, 수
          _buildEnhancedChipGroup(
            items: daysTop,
            selectedItems: selectedDays,
            onChanged: (selected) {
              setState(() {
                selectedDays = selected;
              });
            },
          ),
          const SizedBox(height: 8),
          // 두 번째 줄: 목, 금, 토, 일
          _buildEnhancedChipGroup(
            items: daysBottom,
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

  Widget _buildPersonalStyleCard() {
    return _buildCard(
      icon: '✨',
      title: '나의 스타일',
      subtitle: '스타님의 강점을 표현해주세요',
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
      subtitle: '이런 분위기의 플레이스가 좋아요',
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
      subtitle: '중요하게 생각하는 복지를 선택해주세요',
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
      children: items.map((item) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
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

  Widget _buildEnhancedDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(hint, style: AppTextStyles.secondaryText(context)),
          ),
          value: value,
          isExpanded: true,
          style: AppTextStyles.primaryText(context),
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(item),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.secondaryText(context),
          suffixText: suffix,
          suffixStyle: AppTextStyles.captionText(context),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
                        '매칭 스타일 저장하기',
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
      // Parse selected IDs to integers
      final selectedIndustryIds = selectedIndustries.map((id) => int.parse(id)).toSet();
      final selectedJobIds = selectedJobs.map((id) => int.parse(id)).toSet();
      final selectedStyleIds = selectedStyles.map((id) => int.parse(id)).toSet();
      final selectedPlaceFeatureIds = selectedPlaceFeatures.map((id) => int.parse(id)).toSet();
      final selectedWelfareIds = selectedBenefits.map((id) => int.parse(id)).toSet();
      
      // Parse pay amount
      int? payAmount;
      if (_payAmountController.text.isNotEmpty) {
        payAmount = int.tryParse(_payAmountController.text);
      }

      // Convert UI pay type to database enum
      String? dbPayType;
      if (selectedPayType != null) {
        switch (selectedPayType!) {
          case 'TC':
            dbPayType = 'TC';
            break;
          case '일급':
            dbPayType = 'DAILY';
            break;
          case '월급':
            dbPayType = 'MONTHLY';
            break;
          case '협의':
            dbPayType = 'NEGOTIABLE';
            break;
        }
      }

      // Call Edge Function API
      final response = await MatchingConditionsService.instance.updateMatchingConditions(
        desiredPayType: dbPayType,
        desiredPayAmount: payAmount,
        desiredWorkingDays: selectedDays.toList(),
        selectedStyleAttributeIds: selectedStyleIds.toList(),
        selectedPreferenceAttributeIds: [
          ...selectedIndustryIds,
          ...selectedJobIds,
          ...selectedPlaceFeatureIds,
          ...selectedWelfareIds,
        ].toList(),
        selectedAreaGroupIds: [], // Area groups can be added later if needed
      );

      if (!mounted) return;

      if (response.success) {
        ToastHelper.success(context, response.message ?? '매칭 스타일이 저장되었습니다');
        
        Navigator.of(context).pop();
      } else {
        throw Exception(response.error ?? 'Failed to save preferences');
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      if (!mounted) return;
      
      ToastHelper.error(context, '저장 중 오류가 발생했습니다');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
