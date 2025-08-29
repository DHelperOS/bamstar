import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/toast_helper.dart';
import '../../../models/business_verification_models.dart';
import '../../../providers/business_verification/business_verification_providers.dart';

class Step1FormWidget extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  
  const Step1FormWidget({required this.onComplete, super.key});

  @override
  ConsumerState<Step1FormWidget> createState() => _Step1FormWidgetState();
}

class _Step1FormWidgetState extends ConsumerState<Step1FormWidget> {
  
  // Controllers
  final _registrationNumberCtl = TextEditingController();
  final _representativeNameCtl = TextEditingController();
  final _openingDateCtl = TextEditingController();
  
  // Optional fields
  final _representativeNameCtl2 = TextEditingController();
  final _corporateNumberCtl = TextEditingController();
  final _businessNameCtl = TextEditingController();
  final _mainBusinessCtl = TextEditingController();
  final _subBusinessCtl = TextEditingController();
  final _businessAddressCtl = TextEditingController();

  bool _showOptionalFields = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<BusinessVerificationState>(
        businessVerificationProvider,
        (previous, next) {
          _handleBusinessVerificationState(next);
        },
      );
    });
  }

  @override
  void dispose() {
    _registrationNumberCtl.dispose();
    _representativeNameCtl.dispose();
    _openingDateCtl.dispose();
    _representativeNameCtl2.dispose();
    _corporateNumberCtl.dispose();
    _businessNameCtl.dispose();
    _mainBusinessCtl.dispose();
    _subBusinessCtl.dispose();
    _businessAddressCtl.dispose();
    super.dispose();
  }

  void _validateAndProceed() async {
    final input = BusinessVerificationInput(
      businessNumber: _registrationNumberCtl.text.trim(),
      representativeName: _representativeNameCtl.text.trim(),
      openingDate: _openingDateCtl.text.trim(),
      representativeName2: _representativeNameCtl2.text.trim().isEmpty ? null : _representativeNameCtl2.text.trim(),
      businessName: _businessNameCtl.text.trim().isEmpty ? null : _businessNameCtl.text.trim(),
      corporateNumber: _corporateNumberCtl.text.trim().isEmpty ? null : _corporateNumberCtl.text.trim(),
      mainBusinessType: _mainBusinessCtl.text.trim().isEmpty ? null : _mainBusinessCtl.text.trim(),
      subBusinessType: _subBusinessCtl.text.trim().isEmpty ? null : _subBusinessCtl.text.trim(),
      businessAddress: _businessAddressCtl.text.trim().isEmpty ? null : _businessAddressCtl.text.trim(),
    );

    ref.read(businessVerificationProvider.notifier).updateInput(input);
    await ref.read(businessVerificationProvider.notifier).verify();
  }

  void _handleBusinessVerificationState(BusinessVerificationState state) {
    if (state.isSuccess && state.result != null) {
      final result = state.result!;
      
      // 사업자 상태에 따른 처리 - 폐업/휴업은 실패로 처리
      if (result.status != null) {
        if (result.status!.isClosed) {
          ToastHelper.error(context, '폐업된 사업자입니다. 정확한 정보인지 확인해주세요.');
          Navigator.of(context).pop(); // 모달 닫기
          return;
        } else if (result.status!.isOnHiatus) {
          ToastHelper.error(context, '휴업 중인 사업자입니다. 정확한 정보인지 확인해주세요.');
          Navigator.of(context).pop(); // 모달 닫기
          return;
        }
      }
      
      ToastHelper.success(context, '사업자 정보 조회가 완료되었습니다');
      widget.onComplete();
    } else if (state.error != null) {
      ToastHelper.error(context, state.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 실시간 폼 유효성 검증
    final isFormValid = _registrationNumberCtl.text.trim().isNotEmpty &&
                       _representativeNameCtl.text.trim().isNotEmpty &&
                       _openingDateCtl.text.trim().isNotEmpty;
    final isLoading = ref.watch(businessVerificationLoadingProvider);
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          // Form content - moved to top
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '1',
                                style: AppTextStyles.captionText(context).copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '사업자 정보 입력',
                              style: AppTextStyles.primaryText(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      '사업자등록증 정보',
                      style: AppTextStyles.sectionTitle(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '사업자등록증에 기재된 정보를 정확히 입력해주세요.',
                      style: AppTextStyles.secondaryText(context),
                    ),
                    const SizedBox(height: 24),
                    
                    // Business Registration Number
                    _buildFormField(
                      context: context,
                      label: '사업자등록번호',
                      controller: _registrationNumberCtl,
                      hint: '10자리 숫자 입력 (예: 1234567890)',
                      errorText: ref.watch(businessNumberValidationProvider(_registrationNumberCtl.text)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [_BusinessNumberFormatter()],
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Representative Name
                    _buildFormField(
                      context: context,
                      label: '대표자명',
                      controller: _representativeNameCtl,
                      hint: '홍길동',
                      errorText: ref.watch(representativeNameValidationProvider(_representativeNameCtl.text)),
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Opening Date
                    _buildFormField(
                      context: context,
                      label: '개업일자',
                      controller: _openingDateCtl,
                      hint: '8자리 숫자 입력 (예: 20050302)',
                      errorText: ref.watch(openingDateValidationProvider(_openingDateCtl.text)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [_DateFormatter()],
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Optional fields toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showOptionalFields = !_showOptionalFields;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _showOptionalFields 
                                  ? Icons.expand_less_rounded 
                                  : Icons.expand_more_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '선택 입력 항목',
                                style: AppTextStyles.primaryText(context).copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              _showOptionalFields ? '숨기기' : '보기',
                              style: AppTextStyles.captionText(context).copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Optional fields
                    if (_showOptionalFields) ...[
                      const SizedBox(height: 20),
                      
                      Text(
                        '선택 정보',
                        style: AppTextStyles.sectionTitle(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildFormField(
                        context: context,
                        label: '대표자성명2',
                        controller: _representativeNameCtl2,
                        hint: '부대표자명',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFormField(
                        context: context,
                        label: '상호',
                        controller: _businessNameCtl,
                        hint: '상호명을 입력하세요',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFormField(
                        context: context,
                        label: '법인등록번호',
                        controller: _corporateNumberCtl,
                        hint: '000000-0000000',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFormField(
                        context: context,
                        label: '주업태명',
                        controller: _mainBusinessCtl,
                        hint: '주요 업태를 입력하세요',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFormField(
                        context: context,
                        label: '주종목명',
                        controller: _subBusinessCtl,
                        hint: '주요 종목을 입력하세요',
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFormField(
                        context: context,
                        label: '사업장주소',
                        controller: _businessAddressCtl,
                        hint: '사업장 주소를 입력하세요',
                        isRequired: false,
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Button at bottom - sticky above keyboard
          Container(
            padding: EdgeInsets.fromLTRB(
              20.0, 
              16.0, 
              20.0, 
              16.0 + MediaQuery.of(context).viewInsets.bottom
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
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
                boxShadow: [
                  BoxShadow(
                    color: isFormValid
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                        : Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: isFormValid ? 8 : 4,
                    offset: const Offset(0, 4),
                  ),
                ],
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
      ),
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = true,
    ValueChanged<String>? onChanged,
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
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTextStyles.formLabel(context).copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppTextStyles.primaryText(context),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.primaryText(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorText: errorText,
            errorStyle: AppTextStyles.errorText(context),
          ),
        ),
      ],
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
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }
    
    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 3 || i == 5) {
        formatted += '-';
      }
      formatted += newText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Date Formatter
class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > 8) {
      newText = newText.substring(0, 8);
    }
    
    String formatted = '';
    for (int i = 0; i < newText.length; i++) {
      if (i == 4 || i == 6) {
        formatted += '-';
      }
      formatted += newText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}