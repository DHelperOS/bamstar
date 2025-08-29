import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../models/business_verification_models.dart';
import '../../providers/business_verification/business_verification_providers.dart';
import '../../services/business_verification_service.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/toast_helper.dart';

class BusinessVerificationPage extends ConsumerStatefulWidget {
  const BusinessVerificationPage({super.key});

  @override
  ConsumerState<BusinessVerificationPage> createState() =>
      _BusinessVerificationPageState();
}

class _BusinessVerificationPageState
    extends ConsumerState<BusinessVerificationPage> {
  int _currentStep = 1;
  final Set<String> _touchedFields = {};

  // Form controllers
  final _businessNumberCtl = TextEditingController();
  final _representativeNameCtl = TextEditingController();
  final _openingDateCtl = TextEditingController();
  final _representativeName2Ctl = TextEditingController();
  final _businessNameCtl = TextEditingController();
  final _corporateNumberCtl = TextEditingController();
  final _mainBusinessTypeCtl = TextEditingController();
  final _subBusinessTypeCtl = TextEditingController();
  final _businessAddressCtl = TextEditingController();

  bool _showOptionalFields = false;
  bool _isLoading = false;
  bool _isNavigatingForward = true;

  @override
  void initState() {
    super.initState();
    // Load cached data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCachedData();
    });
  }

  void _loadCachedData() {
    final state = ref.read(businessVerificationProvider);
    if (state.input != null) {
      final input = state.input!;
      _businessNumberCtl.text = input.businessNumber;
      _representativeNameCtl.text = input.representativeName;
      _openingDateCtl.text = input.openingDate;
      _representativeName2Ctl.text = input.representativeName2 ?? '';
      _businessNameCtl.text = input.businessName ?? '';
      _corporateNumberCtl.text = input.corporateNumber ?? '';
      _mainBusinessTypeCtl.text = input.mainBusinessType ?? '';
      _subBusinessTypeCtl.text = input.subBusinessType ?? '';
      _businessAddressCtl.text = input.businessAddress ?? '';

      // Show optional fields if any optional data exists
      final hasOptionalData = (input.representativeName2?.isNotEmpty == true) ||
                            (input.businessName?.isNotEmpty == true) ||
                            (input.corporateNumber?.isNotEmpty == true) ||
                            (input.mainBusinessType?.isNotEmpty == true) ||
                            (input.subBusinessType?.isNotEmpty == true) ||
                            (input.businessAddress?.isNotEmpty == true);
      
      if (hasOptionalData) {
        setState(() {
          _showOptionalFields = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _businessNumberCtl.dispose();
    _representativeNameCtl.dispose();
    _openingDateCtl.dispose();
    _representativeName2Ctl.dispose();
    _businessNameCtl.dispose();
    _corporateNumberCtl.dispose();
    _mainBusinessTypeCtl.dispose();
    _subBusinessTypeCtl.dispose();
    _businessAddressCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: _currentStep > 1 
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  setState(() {
                    _isNavigatingForward = false;
                    _currentStep--;
                  });
                },
              )
            : null,
        title: Text(
          '사업자 인증',
          style: AppTextStyles.cardTitle(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Form content
          Expanded(
            child: _buildStepContent(),
          ),
          
          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Step circles
          Row(
            children: [
              _buildStepCircle(1, '정보입력', _currentStep >= 1),
              _buildStepLine(_currentStep >= 2),
              _buildStepCircle(2, '조회결과', _currentStep >= 2),
              _buildStepLine(_currentStep >= 3),
              _buildStepCircle(3, '서류제출', _currentStep >= 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 14,
                    )
                  : Text(
                      step.toString(),
                      style: AppTextStyles.captionText(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.captionText(context).copyWith(
              color: _currentStep == step
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: _currentStep == step ? FontWeight.w600 : FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      alignment: Alignment.topLeft,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Slide transition from right to left for forward navigation
        // Slide transition from left to right for backward navigation
        final slideAnimation = Tween<Offset>(
          begin: _isNavigatingForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ));

        // Fade transition combined with slide
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      child: _buildCurrentStepWidget(),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return _Step1FormWidget(
          key: const ValueKey('step1'),
          businessNumberController: _businessNumberCtl,
          representativeNameController: _representativeNameCtl,
          openingDateController: _openingDateCtl,
          representativeName2Controller: _representativeName2Ctl,
          businessNameController: _businessNameCtl,
          corporateNumberController: _corporateNumberCtl,
          mainBusinessTypeController: _mainBusinessTypeCtl,
          subBusinessTypeController: _subBusinessTypeCtl,
          businessAddressController: _businessAddressCtl,
          showOptionalFields: _showOptionalFields,
          onOptionalFieldsToggle: () => setState(() => _showOptionalFields = !_showOptionalFields),
          touchedFields: _touchedFields,
          onFieldTouched: (field) => setState(() => _touchedFields.add(field)),
        );
      case 2:
        return const _Step2FormWidget(key: ValueKey('step2'));
      case 3:
        return const _Step3FormWidget(key: ValueKey('step3'));
      default:
        return Container(key: const ValueKey('default'));
    }
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: _isLoading
            ? ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _getButtonAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _getButtonText(),
                  style: AppTextStyles.buttonText(context).copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 1:
        return '조회하기';
      case 2:
        return '다음';
      case 3:
        return '제출하기';
      default:
        return '다음';
    }
  }

  VoidCallback? _getButtonAction() {
    switch (_currentStep) {
      case 1:
        return _submitStep1;
      case 2:
        return () => setState(() {
          _isNavigatingForward = true;
          _currentStep = 3;
        });
      case 3:
        return _submitBusinessVerification;
      default:
        return null;
    }
  }

  Future<void> _submitStep1() async {
    // Validate required fields
    final businessNumberError = BusinessVerificationService.validateBusinessNumber(_businessNumberCtl.text);
    final representativeNameError = BusinessVerificationService.validateRepresentativeName(_representativeNameCtl.text);
    final openingDateError = BusinessVerificationService.validateOpeningDate(_openingDateCtl.text);

    if (businessNumberError != null || representativeNameError != null || openingDateError != null) {
      setState(() {
        _touchedFields.addAll(['business_number', 'representative_name', 'opening_date']);
      });
      ToastHelper.error(context, '필수 정보를 올바르게 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update input data
      final input = BusinessVerificationInput(
        businessNumber: _businessNumberCtl.text,
        representativeName: _representativeNameCtl.text,
        openingDate: _openingDateCtl.text,
        representativeName2: _representativeName2Ctl.text.isNotEmpty ? _representativeName2Ctl.text : null,
        businessName: _businessNameCtl.text.isNotEmpty ? _businessNameCtl.text : null,
        corporateNumber: _corporateNumberCtl.text.isNotEmpty ? _corporateNumberCtl.text : null,
        mainBusinessType: _mainBusinessTypeCtl.text.isNotEmpty ? _mainBusinessTypeCtl.text : null,
        subBusinessType: _subBusinessTypeCtl.text.isNotEmpty ? _subBusinessTypeCtl.text : null,
        businessAddress: _businessAddressCtl.text.isNotEmpty ? _businessAddressCtl.text : null,
      );

      ref.read(businessVerificationProvider.notifier).updateInput(input);
      await ref.read(businessVerificationProvider.notifier).verify();

      final state = ref.read(businessVerificationProvider);
      if (state.isSuccess) {
        setState(() {
          _isNavigatingForward = true;
          _currentStep = 2;
        });
        ToastHelper.success(context, '사업자 정보 조회가 완료되었습니다');
      } else {
        ToastHelper.error(context, state.error ?? '사업자 정보 조회에 실패했습니다');
      }
    } catch (e) {
      ToastHelper.error(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitBusinessVerification() async {
    ToastHelper.info(context, '사업자 인증이 완료되었습니다');
    Navigator.pop(context);
  }
}

class _Step1FormWidget extends ConsumerWidget {
  final TextEditingController businessNumberController;
  final TextEditingController representativeNameController;
  final TextEditingController openingDateController;
  final TextEditingController representativeName2Controller;
  final TextEditingController businessNameController;
  final TextEditingController corporateNumberController;
  final TextEditingController mainBusinessTypeController;
  final TextEditingController subBusinessTypeController;
  final TextEditingController businessAddressController;
  final bool showOptionalFields;
  final VoidCallback onOptionalFieldsToggle;
  final Set<String> touchedFields;
  final Function(String) onFieldTouched;

  const _Step1FormWidget({
    super.key,
    required this.businessNumberController,
    required this.representativeNameController,
    required this.openingDateController,
    required this.representativeName2Controller,
    required this.businessNameController,
    required this.corporateNumberController,
    required this.mainBusinessTypeController,
    required this.subBusinessTypeController,
    required this.businessAddressController,
    required this.showOptionalFields,
    required this.onOptionalFieldsToggle,
    required this.touchedFields,
    required this.onFieldTouched,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '사업자 등록증에 기재된 정보를 정확히 입력해 주세요',
                    style: AppTextStyles.captionText(context).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Required fields
          _buildFormField(
            context: context,
            ref: ref,
            label: '사업자등록번호',
            controller: businessNumberController,
            hint: '하이픈 없이 10자리 숫자 입력',
            keyboardType: TextInputType.number,
            inputFormatters: [_BusinessNumberFormatter()],
            validationProvider: businessNumberValidationProvider,
            fieldKey: 'business_number',
          ),

          const SizedBox(height: 16),

          _buildFormField(
            context: context,
            ref: ref,
            label: '대표자명',
            controller: representativeNameController,
            hint: '대표자 성명 입력',
            validationProvider: representativeNameValidationProvider,
            fieldKey: 'representative_name',
          ),

          const SizedBox(height: 16),

          _buildFormField(
            context: context,
            ref: ref,
            label: '개업일자',
            controller: openingDateController,
            hint: '8자리 숫자 입력 (예: 20050302)',
            keyboardType: TextInputType.number,
            inputFormatters: [_DateFormatter()],
            validationProvider: openingDateValidationProvider,
            fieldKey: 'opening_date',
          ),

          const SizedBox(height: 24),

          // Optional fields toggle
          GestureDetector(
            onTap: onOptionalFieldsToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: showOptionalFields 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: showOptionalFields
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    showOptionalFields 
                        ? Icons.remove_circle_outline_rounded 
                        : Icons.add_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      showOptionalFields ? '추가 정보 숨기기' : '추가 정보 입력하기',
                      style: AppTextStyles.captionText(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: showOptionalFields ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Optional fields
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showOptionalFields 
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildOptionalFormField(
                        context: context,
                        label: '대표자명2',
                        controller: representativeName2Controller,
                        hint: '공동대표자가 있을 경우 입력',
                      ),
                      const SizedBox(height: 16),
                      _buildOptionalFormField(
                        context: context,
                        label: '상호명',
                        controller: businessNameController,
                        hint: '사업체 상호명 입력',
                      ),
                      const SizedBox(height: 16),
                      _buildOptionalFormField(
                        context: context,
                        label: '법인등록번호',
                        controller: corporateNumberController,
                        hint: '법인인 경우 등록번호 입력',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildOptionalFormField(
                        context: context,
                        label: '주업태',
                        controller: mainBusinessTypeController,
                        hint: '주요 업태 입력',
                      ),
                      const SizedBox(height: 16),
                      _buildOptionalFormField(
                        context: context,
                        label: '주종목',
                        controller: subBusinessTypeController,
                        hint: '주요 종목 입력',
                      ),
                      const SizedBox(height: 16),
                      _buildOptionalFormField(
                        context: context,
                        label: '사업장소재지',
                        controller: businessAddressController,
                        hint: '사업장 주소 입력',
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required TextEditingController controller,
    required String hint,
    required Provider<String?> Function(String?) validationProvider,
    required String fieldKey,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.formLabel(context),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.secondaryText(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            errorText: touchedFields.contains(fieldKey) 
                ? ref.watch(validationProvider(controller.text))
                : null,
          ),
          onChanged: (value) => onFieldTouched(fieldKey),
        ),
      ],
    );
  }

  Widget _buildOptionalFormField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (선택)',
          style: AppTextStyles.formLabel(context).copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.secondaryText(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _Step2FormWidget extends ConsumerWidget {
  const _Step2FormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessVerificationProvider);
    final result = state.result;

    if (result == null) {
      return Center(
        child: Text(
          '조회 결과가 없습니다.',
          style: AppTextStyles.primaryText(context),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header with beautiful design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  const Color(0xFF4CAF50).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '국세청 인증 완료',
                            style: AppTextStyles.cardTitle(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '사업자 정보가 국세청 데이터베이스에서 확인되었습니다',
                            style: AppTextStyles.captionText(context).copyWith(
                              color: const Color(0xFF388E3C),
                              fontSize: 12,
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

          const SizedBox(height: 32),

          // Business information with enhanced design
          Text(
            '조회된 사업자 정보',
            style: AppTextStyles.sectionTitle(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(context, '사업자등록번호', result.bNo, icon: Icons.business_rounded),
                _buildInfoRow(context, '대표자명', result.requestParam.pNm, icon: Icons.person_rounded),
                _buildInfoRow(context, '개업일자', _formatDate(result.requestParam.startDt), icon: Icons.calendar_today_rounded),
                if (result.status != null) ...[
                  _buildInfoRow(context, '과세유형', result.status!.taxType, icon: Icons.account_balance_rounded),
                  _buildInfoRow(context, '납세자상태', result.status!.bStt, icon: Icons.check_circle_rounded, isLast: true),
                ] else
                  _buildInfoRow(context, '상태', '정상', icon: Icons.check_circle_rounded, isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length != 8) return dateStr ?? '-';
    
    try {
      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(4, 6);
      final day = dateStr.substring(6, 8);
      return '$year년 $month월 $day일';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {IconData? icon, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.formLabel(context).copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.primaryText(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step3FormWidget extends StatelessWidget {
  const _Step3FormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '서류 제출',
            style: AppTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: 12),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '사업자등록증을 업로드해주세요',
                  style: AppTextStyles.primaryText(context),
                ),
                const SizedBox(height: 8),
                Text(
                  '파일 형식: JPG, PNG, PDF\n최대 크기: 10MB',
                  style: AppTextStyles.captionText(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Input formatters
class _BusinessNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length <= 10) {
      return newValue.copyWith(text: newText);
    }
    return oldValue;
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length <= 8) {
      return newValue.copyWith(text: newText);
    }
    return oldValue;
  }
}