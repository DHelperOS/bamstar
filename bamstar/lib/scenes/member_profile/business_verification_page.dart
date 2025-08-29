import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/business_verification/business_verification_providers.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '사업자 인증',
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Beautiful step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: _buildStepIndicator(),
          ),
          
          // Content based on current step
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        // Step titles
        Row(
          children: [
            Expanded(
              child: Text(
                '정보 입력',
                style: AppTextStyles.captionText(context).copyWith(
                  color: _currentStep >= 1 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: _currentStep == 1 ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: Text(
                '정보 확인',
                style: AppTextStyles.captionText(context).copyWith(
                  color: _currentStep >= 2 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: _currentStep == 2 ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '서류 제출',
                style: AppTextStyles.captionText(context).copyWith(
                  color: _currentStep >= 3 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: _currentStep == 3 ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Visual step indicator
        Row(
          children: [
            // Step 1
            _buildStepCircle(1),
            // Connection line 1
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: _currentStep > 1 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Step 2
            _buildStepCircle(2),
            // Connection line 2
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: _currentStep > 2 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Step 3
            _buildStepCircle(3),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCircle(int step) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isActive || isCompleted) 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: (isActive || isCompleted) 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isActive ? 3 : 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 18,
              )
            : Text(
                step.toString(),
                style: AppTextStyles.captionText(context).copyWith(
                  color: (isActive || isCompleted)
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _Step1FormWidget(
          onNext: () => setState(() => _currentStep = 2),
        );
      case 2:
        return _Step2FormWidget(
          onNext: () => setState(() => _currentStep = 3),
        );
      case 3:
        return _Step3FormWidget(
          onComplete: () => Navigator.of(context).pop(),
        );
      default:
        return Container();
    }
  }
}

// Step 1 Form Widget
class _Step1FormWidget extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const _Step1FormWidget({required this.onNext});

  @override
  ConsumerState<_Step1FormWidget> createState() => _Step1FormWidgetState();
}

class _Step1FormWidgetState extends ConsumerState<_Step1FormWidget> {
  final TextEditingController _registrationNumberCtl = TextEditingController();
  final TextEditingController _representativeNameCtl = TextEditingController();
  final TextEditingController _openingDateCtl = TextEditingController();
  final TextEditingController _representativeName2Ctl = TextEditingController();
  final TextEditingController _businessNameCtl = TextEditingController();
  final TextEditingController _corporateNumberCtl = TextEditingController();
  final TextEditingController _mainBusinessTypeCtl = TextEditingController();
  final TextEditingController _subBusinessTypeCtl = TextEditingController();
  final TextEditingController _businessAddressCtl = TextEditingController();
  
  bool _showOptionalFields = false;
  
  // Track which fields have been touched to prevent premature error messages
  final Set<String> _touchedFields = {};

  @override
  void dispose() {
    _registrationNumberCtl.dispose();
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

  void _validateAndProceed() async {
    final input = BusinessVerificationInput(
      businessNumber: _registrationNumberCtl.text,
      representativeName: _representativeNameCtl.text,
      openingDate: _openingDateCtl.text,
      representativeName2: _representativeName2Ctl.text.isNotEmpty ? _representativeName2Ctl.text : null,
      businessName: _businessNameCtl.text.isNotEmpty ? _businessNameCtl.text : null,
      corporateNumber: _corporateNumberCtl.text.isNotEmpty ? _corporateNumberCtl.text : null,
      mainBusinessType: _mainBusinessTypeCtl.text.isNotEmpty ? _mainBusinessTypeCtl.text : null,
      subBusinessType: _subBusinessTypeCtl.text.isNotEmpty ? _subBusinessTypeCtl.text : null,
      businessAddress: _businessAddressCtl.text.isNotEmpty ? _businessAddressCtl.text : null,
    );

    print('🔍 [Business Verification] Starting verification with input: ${input.businessNumber}');
    
    ref.read(businessVerificationProvider.notifier).updateInput(input);
    await ref.read(businessVerificationProvider.notifier).verify();

    final state = ref.read(businessVerificationProvider);
    
    print('🔍 [Business Verification] Verification completed:');
    print('   - Error: ${state.error}');
    print('   - Success: ${state.isSuccess}');
    print('   - Result: ${state.result?.toString() ?? 'null'}');
    
    if (state.result != null) {
      print('🔍 [Business Verification] Result details:');
      print('   - Valid: ${state.result!.isValid}');
      print('   - Valid Message: ${state.result!.validMsg}');
      print('   - Request Parameter: ${state.result!.requestParam}');
    }
    
    if (state.error != null) {
      if (mounted) {
        ToastHelper.error(context, state.error!);
      }
    } else if (state.isSuccess) {
      if (mounted) {
        ToastHelper.success(context, '사업자 정보 조회가 완료되었습니다');
        widget.onNext();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _registrationNumberCtl.text.trim().isNotEmpty &&
        _representativeNameCtl.text.trim().isNotEmpty &&
        _openingDateCtl.text.trim().isNotEmpty;
    final isLoading = ref.watch(businessVerificationLoadingProvider);

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card - Guidance for users
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.business_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '사업자등록증을 준비해주세요',
                                style: AppTextStyles.captionText(context).copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '사업자등록증에 기재된 정보를 정확히 입력하시면\n국세청 API를 통해 자동으로 사업자 정보를 확인합니다.',
                                style: AppTextStyles.captionText(context).copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Business Registration Number
                  _buildFormFieldWithError(
                    context: context,
                    label: '사업자등록번호',
                    controller: _registrationNumberCtl,
                    hint: '10자리 숫자 입력 (예: 1234567890)',
                    errorText: _touchedFields.contains('business_number') 
                        ? ref.watch(
                            businessNumberValidationProvider(
                              _registrationNumberCtl.text,
                            ),
                          )
                        : null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_BusinessNumberFormatter()],
                    onChanged: (value) {
                      _touchedFields.add('business_number');
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  // Representative Name
                  _buildFormFieldWithError(
                    context: context,
                    label: '대표자명',
                    controller: _representativeNameCtl,
                    hint: '홍길동',
                    errorText: _touchedFields.contains('representative_name') 
                        ? ref.watch(
                            representativeNameValidationProvider(
                              _representativeNameCtl.text,
                            ),
                          )
                        : null,
                    onChanged: (value) {
                      _touchedFields.add('representative_name');
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  // Opening Date
                  _buildFormFieldWithError(
                    context: context,
                    label: '개업일자',
                    controller: _openingDateCtl,
                    hint: '8자리 숫자 입력 (예: 20050302)',
                    errorText: _touchedFields.contains('opening_date') 
                        ? ref.watch(
                            openingDateValidationProvider(
                              _openingDateCtl.text,
                            ),
                          )
                        : null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_DateFormatter()],
                    onChanged: (value) {
                      _touchedFields.add('opening_date');
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 24),

                  // Optional fields toggle with improved design
                  GestureDetector(
                    onTap: () => setState(() => _showOptionalFields = !_showOptionalFields),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _showOptionalFields 
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _showOptionalFields
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showOptionalFields 
                                ? Icons.remove_circle_outline_rounded 
                                : Icons.add_circle_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _showOptionalFields ? '추가 정보 숨기기' : '추가 정보 입력하기',
                              style: AppTextStyles.captionText(context).copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _showOptionalFields ? 0.5 : 0,
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

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showOptionalFields 
                        ? Column(
                            children: [
                    const SizedBox(height: 16),

                    // Representative Name 2 (Optional)
                    _buildFormFieldWithError(
                      context: context,
                      label: '대표자명2',
                      controller: _representativeName2Ctl,
                      hint: '공동대표자명 (선택사항)',
                      isRequired: false,
                    ),

                    const SizedBox(height: 16),

                    // Business Name (Optional)
                    _buildFormFieldWithError(
                      context: context,
                      label: '상호',
                      controller: _businessNameCtl,
                      hint: '상호명을 입력하세요',
                      isRequired: false,
                    ),

                    const SizedBox(height: 16),

                    // Corporate Number (Optional)
                    _buildFormFieldWithError(
                      context: context,
                      label: '법인번호',
                      controller: _corporateNumberCtl,
                      hint: '법인번호를 입력하세요',
                      isRequired: false,
                    ),

                    const SizedBox(height: 16),

                    // Main Business Type (Optional)
                    _buildFormFieldWithError(
                      context: context,
                      label: '주업태명',
                      controller: _mainBusinessTypeCtl,
                      hint: '주업태명을 입력하세요',
                      isRequired: false,
                    ),

                    const SizedBox(height: 16),

                    // Sub Business Type (Optional)
                    _buildFormFieldWithError(
                      context: context,
                      label: '주종목명',
                      controller: _subBusinessTypeCtl,
                      hint: '주종목명을 입력하세요',
                      isRequired: false,
                    ),

                    const SizedBox(height: 16),

                    // Business Address
                    _buildFormFieldWithError(
                      context: context,
                      label: '사업장주소',
                      controller: _businessAddressCtl,
                      hint: '사업장 주소를 입력하세요',
                      isRequired: false,
                    ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 100), // Button space
                ],
              ),
            ),
          ),
        ),

        // Bottom button
        Container(
          padding: EdgeInsets.fromLTRB(
            20.0,
            16.0,
            20.0,
            16.0 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isFormValid
                    ? [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      ]
                    : [
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isFormValid ? _validateAndProceed : null,
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            isFormValid ? '사업자 정보 조회' : '필수 정보를 모두 입력해주세요',
                            style: AppTextStyles.buttonText(context).copyWith(
                              color: isFormValid
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFieldWithError({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    String? errorText,
    bool isRequired = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.formLabel(context),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.formLabel(context).copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.secondaryText(context),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: AppTextStyles.primaryText(context),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: AppTextStyles.errorText(context),
          ),
        ],
      ],
    );
  }
}

// Step 2 Form Widget
class _Step2FormWidget extends ConsumerWidget {
  const _Step2FormWidget();

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
          // Success header
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사업자 정보 조회 완료',
                        style: AppTextStyles.cardTitle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '국세청 데이터베이스에서 확인되었습니다',
                        style: AppTextStyles.captionText(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Business information
          Text(
            '사업자 정보',
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
                _buildInfoRow('사업자등록번호', result.bNo ?? '-'),
                _buildInfoRow('상호명', result.bNm ?? '-'),
                _buildInfoRow('대표자명', result.pNm ?? '-'),
                _buildInfoRow('개업일자', result.startDt ?? '-'),
                _buildInfoRow('사업장소재지', result.bAdr ?? '-'),
                _buildInfoRow('업태', result.bSector ?? '-'),
                _buildInfoRow('종목', result.bType ?? '-'),
                _buildInfoRow('과세유형', result.taxType ?? '-'),
                _buildInfoRow('납세자상태', result.bStt ?? '-'),
                _buildInfoRow('납세자상태변경일자', result.bSttCd ?? '-', isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Builder(
      builder: (context) => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: AppTextStyles.captionText(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.primaryText(context),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            Divider(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              height: 1,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          // Success icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Success title
          Text(
            '사업자 정보 조회 완료',
            style: AppTextStyles.pageTitle(context),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '국세청에서 사업자 정보를 성공적으로 확인했습니다.',
            style: AppTextStyles.secondaryText(context),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),

          // Business info card with success badge
          if (result != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with success badge
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '확인된 사업자 정보',
                          style: AppTextStyles.cardTitle(context).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Success badge - moved to natural position
                      if (result.isValid) 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50), // Green success color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '인증완료',
                                style: AppTextStyles.captionText(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Business details with improved styling
                  _buildInfoRow(
                    context,
                    '사업자등록번호',
                    result.requestParam?.bNo ?? state.input?.businessNumber ?? '-',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    context,
                    '대표자명',
                    result.requestParam?.pNm ?? state.input?.representativeName ?? '-',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    context,
                    '개업일자',
                    result.requestParam?.startDt ?? state.input?.openingDate ?? '-',
                  ),
                  
                  if (result.requestParam?.bNm?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      '상호',
                      result.requestParam!.bNm!,
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
          
          // Next button with proper styling
          Container(
            width: double.infinity,
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
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '다음 단계',
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
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.captionText(context).copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.primaryText(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Step 3 Form Widget
class _Step3FormWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const _Step3FormWidget({required this.onComplete});

  @override
  State<_Step3FormWidget> createState() => _Step3FormWidgetState();
}

class _Step3FormWidgetState extends State<_Step3FormWidget> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '서류 업로드',
            style: AppTextStyles.pageTitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            '사업자등록증 사본을 업로드해주세요.',
            style: AppTextStyles.secondaryText(context),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.onComplete,
            child: Text('완료'),
          ),
        ],
      ),
    );
  }
}

// Business Number Formatter
class _BusinessNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length <= 10) {
      String formatted = '';
      for (int i = 0; i < newText.length; i++) {
        if (i == 3 || i == 5) {
          formatted += '-';
        }
        formatted += newText[i];
      }
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return oldValue;
  }
}

// Date Formatter
class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length <= 8) {
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    return oldValue;
  }
}