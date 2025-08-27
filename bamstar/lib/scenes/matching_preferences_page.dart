import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text_styles.dart';

class MatchingPreferencesPage extends StatefulWidget {
  const MatchingPreferencesPage({super.key});

  @override
  State<MatchingPreferencesPage> createState() =>
      _MatchingPreferencesPageState();
}

class _MatchingPreferencesPageState extends State<MatchingPreferencesPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Form state variables
  Set<String> selectedIndustries = {};
  Set<String> selectedJobs = {};
  String? selectedPayType;
  final TextEditingController _payAmountController = TextEditingController();
  Set<String> selectedDays = {};
  Set<String> selectedStyles = {};
  Set<String> selectedPlaceFeatures = {};
  Set<String> selectedBenefits = {};

  // Animation controllers
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

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
    _fadeController!.forward();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _payAmountController.dispose();
    super.dispose();
  }

  // Data matching the nightlife/entertainment industry
  final List<Map<String, dynamic>> industries = [
    {'id': '1', 'name': '모던 바', 'icon': '🍸'},
    {'id': '2', 'name': '토크 바', 'icon': '💬'},
    {'id': '3', 'name': '캐주얼 펍', 'icon': '🍺'},
    {'id': '4', 'name': '가라오케', 'icon': '🎤'},
    {'id': '5', 'name': '카페', 'icon': '☕'},
    {'id': '6', 'name': '테라피', 'icon': '💆'},
    {'id': '7', 'name': '라이브 방송', 'icon': '📹'},
    {'id': '8', 'name': '이벤트', 'icon': '🎉'},
  ];

  final List<Map<String, dynamic>> jobs = [
    {'id': '9', 'name': '매니저', 'icon': '👔'},
    {'id': '10', 'name': '실장', 'icon': '👑'},
    {'id': '11', 'name': '바텐더', 'icon': '🍹'},
    {'id': '12', 'name': '스탭', 'icon': '👥'},
    {'id': '13', 'name': '가드', 'icon': '🛡️'},
    {'id': '14', 'name': '주방', 'icon': '👨‍🍳'},
    {'id': '15', 'name': 'DJ', 'icon': '🎧'},
  ];

  final List<String> payTypes = ['TC', '일급', '월급', '협의'];

  final List<Map<String, String>> daysTop = [
    {'id': '23', 'name': '전체'},
    {'id': '16', 'name': '월'},
    {'id': '17', 'name': '화'},
    {'id': '18', 'name': '수'},
  ];

  final List<Map<String, String>> daysBottom = [
    {'id': '19', 'name': '목'},
    {'id': '20', 'name': '금'},
    {'id': '21', 'name': '토'},
    {'id': '22', 'name': '일'},
  ];

  final List<Map<String, String>> styles = [
    {'id': '24', 'name': '긍정적'},
    {'id': '25', 'name': '활발함'},
    {'id': '26', 'name': '성실함'},
    {'id': '27', 'name': '대화리드'},
    {'id': '28', 'name': '패션센스'},
    {'id': '29', 'name': '좋은비율'},
  ];

  final List<Map<String, String>> placeFeatures = [
    {'id': '29', 'name': '초보환영'},
    {'id': '30', 'name': '텃세없음'},
    {'id': '31', 'name': '술강요없음'},
    {'id': '32', 'name': '가족같은'},
    {'id': '33', 'name': '고급스러운'},
    {'id': '34', 'name': '자유복장'},
  ];

  final List<Map<String, String>> benefits = [
    {'id': '35', 'name': '당일지급'},
    {'id': '36', 'name': '선불/마이킹'},
    {'id': '37', 'name': '인센티브'},
    {'id': '38', 'name': '숙소 제공'},
    {'id': '39', 'name': '교통비 지원'},
    {'id': '40', 'name': '식사 제공'},
    {'id': '41', 'name': '의상/유니폼'},
    {'id': '42', 'name': '헤어/메이크업'},
    {'id': '43', 'name': '성형 지원'},
    {'id': '44', 'name': '4대보험'},
    {'id': '45', 'name': '퇴직금'},
    {'id': '46', 'name': '휴가/월차'},
  ];

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
      body: _fadeAnimation != null
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
          onTap: _savePreferences,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

  void _savePreferences() {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // TODO: Implement Supabase data persistence
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            const Text('매칭 스타일이 저장되었습니다'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.of(context).pop();
  }
}
