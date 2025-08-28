import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Note: This implementation uses standard Theme.of(context) calls for robustness.

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State management for agreements
  bool _allAgreed = false;

  // Mandatory
  bool _termsOfService = false;
  bool _privacyPolicy = false;
  bool _collectPersonalInfo = false;
  bool _provideToThirdParties = false;

  // Optional
  bool _pushNotifications = false;
  bool _eventNotifications = false;
  bool _marketingConsent = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateAllAgreed();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _updateAllAgreed() {
    setState(() {
      final allMandatory =
          _termsOfService &&
          _privacyPolicy &&
          _collectPersonalInfo &&
          _provideToThirdParties;
      final allOptional =
          _pushNotifications && _eventNotifications && _marketingConsent;
      _allAgreed = allMandatory && allOptional;
    });
  }

  void _setAllAgreements(bool? value) {
    if (value == null) return;
    setState(() {
      _allAgreed = value;
      _termsOfService = value;
      _privacyPolicy = value;
      _collectPersonalInfo = value;
      _provideToThirdParties = value;
      _pushNotifications = value;
      _eventNotifications = value;
      _marketingConsent = value;
    });
  }

  bool get _canProceed =>
      _termsOfService &&
      _privacyPolicy &&
      _collectPersonalInfo &&
      _provideToThirdParties;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            '밤스타가 처음이신군요!',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      backgroundColor: cs.surface,
      body: Column(
        children: [
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    const SizedBox(height: 12),

                    // All agreement card
                    _buildAllAgreementCard(),
                    const SizedBox(height: 12),

                    // Mandatory Terms Card
                    _buildMandatoryTermsCard(),
                    const SizedBox(height: 12),

                    // Optional Terms Card
                    _buildOptionalTermsCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Enhanced Action Button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildAllAgreementCard() {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _allAgreed
            ? cs.primaryContainer.withValues(alpha: 0.15)
            : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _allAgreed
              ? cs.primary.withValues(alpha: 0.2)
              : cs.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _allAgreed
                ? cs.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildEnhancedAgreementTile(
        title: '전체 동의',
        subtitle: '모든 약관에 동의합니다',
        isAgreed: _allAgreed,
        onChanged: _setAllAgreements,
        isHeader: true,
        showViewButton: false,
      ),
    );
  }

  Widget _buildMandatoryTermsCard() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.priority_high_rounded, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  '필수 약관',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'REQUIRED',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildEnhancedAgreementTile(
                  title: '밤스타 이용약관',
                  subtitle: '서비스 이용을 위한 기본 약관',
                  isAgreed: _termsOfService,
                  onChanged: (value) => setState(() {
                    _termsOfService = value ?? false;
                    _updateAllAgreed();
                  }),
                  isMandatory: true,
                ),
                _buildEnhancedAgreementTile(
                  title: '개인정보 처리 방침',
                  subtitle: '개인정보 보호에 관한 정책',
                  isAgreed: _privacyPolicy,
                  onChanged: (value) => setState(() {
                    _privacyPolicy = value ?? false;
                    _updateAllAgreed();
                  }),
                  isMandatory: true,
                ),
                _buildEnhancedAgreementTile(
                  title: '개인정보 수집 및 이용 동의',
                  subtitle: '서비스 제공을 위한 개인정보 활용',
                  isAgreed: _collectPersonalInfo,
                  onChanged: (value) => setState(() {
                    _collectPersonalInfo = value ?? false;
                    _updateAllAgreed();
                  }),
                  isMandatory: true,
                ),
                _buildEnhancedAgreementTile(
                  title: '개인정보 제 3자 정보 제공 동의',
                  subtitle: '파트너사와의 정보 공유',
                  isAgreed: _provideToThirdParties,
                  onChanged: (value) => setState(() {
                    _provideToThirdParties = value ?? false;
                    _updateAllAgreed();
                  }),
                  isMandatory: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalTermsCard() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_rounded,
                  color: cs.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '선택 약관',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OPTIONAL',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildEnhancedAgreementTile(
                  title: '푸시 알림 동의',
                  subtitle: '중요한 정보와 업데이트 알림',
                  isAgreed: _pushNotifications,
                  onChanged: (value) => setState(() {
                    _pushNotifications = value ?? false;
                    _updateAllAgreed();
                  }),
                  showViewButton: false,
                ),
                _buildEnhancedAgreementTile(
                  title: '이벤트 알림 동의',
                  subtitle: '특별 이벤트 및 혜택 정보',
                  isAgreed: _eventNotifications,
                  onChanged: (value) => setState(() {
                    _eventNotifications = value ?? false;
                    _updateAllAgreed();
                  }),
                  showViewButton: false,
                ),
                _buildEnhancedAgreementTile(
                  title: '마케팅 활용 동의',
                  subtitle: '맞춤형 광고 및 마케팅 정보 수신',
                  isAgreed: _marketingConsent,
                  onChanged: (value) => setState(() {
                    _marketingConsent = value ?? false;
                    _updateAllAgreed();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAgreementTile({
    required String title,
    String? subtitle,
    required bool isAgreed,
    required ValueChanged<bool?> onChanged,
    bool isHeader = false,
    bool isMandatory = false,
    bool showViewButton = true,
  }) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isAgreed),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isHeader ? 10.0 : 10.0),
            child: Row(
              children: [
                // Custom Checkbox
                Container(
                  width: isHeader ? 28 : 24,
                  height: isHeader ? 28 : 24,
                  decoration: BoxDecoration(
                    color: isAgreed ? cs.primary : Colors.transparent,
                    border: Border.all(
                      color: isAgreed ? cs.primary : cs.outline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isAgreed
                      ? Icon(
                          Icons.check_rounded,
                          color: cs.onPrimary,
                          size: isHeader ? 18 : 16,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: isHeader
                            ? textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              )
                            : textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // View button (conditional)
                if (showViewButton)
                  Container(
                    decoration: BoxDecoration(
                      color: isAgreed 
                          ? cs.primary.withValues(alpha: 0.1)
                          : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to term details page based on title/id
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '보기',
                        style: textTheme.labelSmall?.copyWith(
                          color: isAgreed ? cs.primary : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
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

  Widget _buildActionButton() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: _canProceed
                  ? LinearGradient(
                      colors: [cs.primary, cs.primary.withValues(alpha: 0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _canProceed ? null : cs.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _canProceed
                  ? [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _canProceed
                    ? () {
                        // TODO: Save agreements and navigate
                        context.go('/home');
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _canProceed
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: cs.onPrimary,
                                size: 20,
                              )
                            : Icon(
                                Icons.lock_rounded,
                                color: cs.onSurface.withValues(alpha: 0.12),
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _canProceed ? '동의하고 시작하기' : '필수 약관에 동의해주세요',
                        style: textTheme.titleMedium?.copyWith(
                          color: _canProceed
                              ? cs.onPrimary
                              : cs.onSurface.withValues(alpha: 0.12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
