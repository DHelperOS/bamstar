import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';
import '../services/terms_service.dart';
import '../utils/toast_helper.dart';

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
  bool _isLoading = true;
  
  // Terms data from Supabase
  List<Term> _mandatoryTerms = [];
  List<Term> _optionalTerms = [];
  Map<String, bool> _termsAgreements = {};

  // Legacy state for backward compatibility
  bool _pushNotifications = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTermsData();
  }
  
  /// Load terms data from Supabase
  Future<void> _loadTermsData() async {
    try {
      final mandatoryTerms = await TermsService.getMandatoryTerms();
      final optionalTerms = await TermsService.getOptionalTerms();
      
      // Check if user already agreed to terms
      await _checkExistingAgreements(mandatoryTerms, optionalTerms);
      
      setState(() {
        _mandatoryTerms = mandatoryTerms;
        _optionalTerms = optionalTerms;
        _isLoading = false;
        
        // Agreement states already set in _checkExistingAgreements
        _updateAllAgreed();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ToastHelper.error(context, '약관 정보를 불러오는데 실패했습니다');
      }
    }
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
      // Check if all mandatory terms are agreed
      final allMandatory = _mandatoryTerms.isEmpty || 
          _mandatoryTerms.every((term) => _termsAgreements[term.id] == true);
      
      // Check if all optional terms are agreed  
      final allOptional = _optionalTerms.isEmpty ||
          _optionalTerms.every((term) => _termsAgreements[term.id] == true);
      
      _allAgreed = allMandatory && allOptional;
      
      // Update push notification state for notification category
      _pushNotifications = _optionalTerms
          .where((term) => term.category == 'notification')
          .any((term) => _termsAgreements[term.id] == true);
    });
  }

  void _setAllAgreements(bool? value) {
    if (value == null) return;
    setState(() {
      _allAgreed = value;
      // Update all terms agreements
      for (final termId in _termsAgreements.keys) {
        _termsAgreements[termId] = value;
      }
      _updateAllAgreed();
    });
  }

  bool get _canProceed =>
      _mandatoryTerms.isNotEmpty &&
      _mandatoryTerms.every((term) => _termsAgreements[term.id] == true);

  /// Check existing user agreements and redirect if already agreed
  Future<void> _checkExistingAgreements(List<Term> mandatoryTerms, List<Term> optionalTerms) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // Initialize as false if no user
        for (final term in [...mandatoryTerms, ...optionalTerms]) {
          _termsAgreements[term.id] = false;
        }
        return;
      }

      // Get user's existing agreements
      final userAgreements = await TermsService.getUserAgreements(user.id);
      final agreedTermIds = userAgreements
          .where((agreement) => agreement.isAgreed)
          .map((agreement) => agreement.termId)
          .toSet();

      // Initialize agreement states
      for (final term in [...mandatoryTerms, ...optionalTerms]) {
        _termsAgreements[term.id] = agreedTermIds.contains(term.id);
      }

      // Check if all mandatory terms are already agreed
      final allMandatoryAgreed = mandatoryTerms.every((term) => _termsAgreements[term.id] == true);
      
      if (allMandatoryAgreed && mandatoryTerms.isNotEmpty) {
        // User already agreed to all mandatory terms, skip to home
        debugPrint('[DEBUG] User already agreed to all mandatory terms, going to home');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/home');
          }
        });
        return;
      }
    } catch (e) {
      debugPrint('[DEBUG] Error checking existing agreements: $e');
      // Initialize as false on error
      for (final term in [...mandatoryTerms, ...optionalTerms]) {
        _termsAgreements[term.id] = false;
      }
    }
  }

  /// Save user term agreements to database
  Future<void> _saveUserAgreements() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      // Get current version for all terms
      final allTerms = [..._mandatoryTerms, ..._optionalTerms];
      
      // Only save agreements that are true
      final agreementsToSave = <String, bool>{};
      for (final term in allTerms) {
        final isAgreed = _termsAgreements[term.id] ?? false;
        if (isAgreed) {
          agreementsToSave[term.id] = true;
        }
      }

      if (agreementsToSave.isNotEmpty) {
        await TermsService.saveMultipleAgreements(
          userId: user.id,
          agreements: agreementsToSave,
          version: '1.0', // You might want to get actual version from terms
          // IP 주소와 User-Agent는 개인정보보호를 위해 수집하지 않음
        );
      }
    } catch (e) {
      throw Exception('약관 동의 저장에 실패했습니다: $e');
    }
  }

  /// Handle agreement completion and notification setup
  Future<void> _handleAgreementAndProceed() async {
    bool isDialogOpen = false;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      isDialogOpen = true;

      // If push notifications are enabled, request permission and setup FCM
      if (_pushNotifications) {
        final notificationService = NotificationService();
        final success = await notificationService.setupNotifications();

        if (!success) {
          // Show warning that notifications couldn't be set up
          if (mounted) {
            ToastHelper.warning(context, '알림 권한을 얻을 수 없어 일부 기능이 제한될 수 있습니다');
          }

          // Wait a bit before continuing
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // Hide loading dialog
      if (mounted && isDialogOpen) {
        Navigator.of(context).pop();
        isDialogOpen = false;
      }

      // Save agreement states to user_term_agreements table
      await _saveUserAgreements();

      // Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted && isDialogOpen) {
        Navigator.of(context).pop();
        isDialogOpen = false;
      }

      // Show error message
      if (mounted) {
        ToastHelper.error(context, '설정 중 오류가 발생했습니다. 다시 시도해주세요');
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          if (_mandatoryTerms.isNotEmpty) ...[
                            _buildMandatoryTermsCard(),
                            const SizedBox(height: 12),
                          ],

                          // Optional Terms Card
                          if (_optionalTerms.isNotEmpty) ...[
                            _buildOptionalTermsCard(),
                            const SizedBox(height: 16),
                          ],
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
            ? cs.primaryContainer.withOpacity(0.15)
            : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _allAgreed
              ? cs.primary.withOpacity(0.2)
              : cs.outline.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _allAgreed
                ? cs.primary.withOpacity(0.2)
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
        isHeader: false,
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
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer.withOpacity(0.15),
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
                    color: cs.error.withOpacity(0.2),
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
              children: _mandatoryTerms.map((term) {
                return _buildEnhancedAgreementTile(
                  title: term.title,
                  subtitle: term.description,
                  isAgreed: _termsAgreements[term.id] ?? false,
                  onChanged: (value) => setState(() {
                    _termsAgreements[term.id] = value ?? false;
                    _updateAllAgreed();
                  }),
                  isMandatory: true,
                  termId: term.id,
                );
              }).toList(),
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
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withOpacity(0.15),
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
                    color: cs.secondary.withOpacity(0.2),
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
              children: _optionalTerms.map((term) {
                return _buildEnhancedAgreementTile(
                  title: term.title,
                  subtitle: term.description,
                  isAgreed: _termsAgreements[term.id] ?? false,
                  onChanged: (value) => setState(() {
                    _termsAgreements[term.id] = value ?? false;
                    _updateAllAgreed();
                  }),
                  showViewButton: term.category != 'notification',
                  termId: term.id,
                );
              }).toList(),
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
    String? termId,
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
                          ? cs.primary.withOpacity(0.1)
                          : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (termId != null) {
                          context.go('/terms/$termId');
                        }
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
          top: BorderSide(color: cs.outline.withOpacity(0.3), width: 1),
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
                      colors: [cs.primary, cs.primary.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _canProceed ? null : cs.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _canProceed
                  ? [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.2),
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
                    ? () async {
                        await _handleAgreementAndProceed();
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
