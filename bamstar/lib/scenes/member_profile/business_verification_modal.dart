import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/toast_helper.dart';

import '../../models/business_verification_models.dart';
import '../../providers/business_verification/business_verification_providers.dart';

/// Helper function to show the business verification modal
Future<void> showBusinessVerificationModal(BuildContext context) async {
  await WoltModalSheet.show(
    context: context,
    pageListBuilder: (modalCtx) => [
      // Step 1: Business Information Form
      WoltModalSheetPage(
        backgroundColor: Theme.of(modalCtx).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        pageTitle: null,
        leadingNavBarWidget: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '사업자 인증',
                style: AppTextStyles.dialogTitle(modalCtx),
              ),
              const SizedBox(height: 4),
              Text(
                '1/3 사업자 정보 입력',
                style: AppTextStyles.captionText(modalCtx).copyWith(
                  color: Theme.of(modalCtx).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        trailingNavBarWidget: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => Navigator.of(modalCtx).pop(),
          ),
        ),
        child: Consumer(
          builder: (context, ref, child) {
            return _Step1FormWidget(
              onComplete: () {
                if (modalCtx.mounted) {
                  WoltModalSheet.of(modalCtx).showNext();
                }
              },
            );
          },
        ),
      ),
      
      // Step 2: Business Information Confirmation  
      WoltModalSheetPage(
        backgroundColor: Theme.of(modalCtx).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        pageTitle: null,
        leadingNavBarWidget: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '사업자 인증',
                style: AppTextStyles.dialogTitle(modalCtx),
              ),
              const SizedBox(height: 4),
              Text(
                '2/3 정보 확인',
                style: AppTextStyles.captionText(modalCtx).copyWith(
                  color: Theme.of(modalCtx).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        trailingNavBarWidget: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => WoltModalSheet.of(modalCtx).showPrevious(),
          ),
        ),
        stickyActionBar: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          decoration: BoxDecoration(
            color: Theme.of(modalCtx).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(modalCtx).colorScheme.primary,
                  Theme.of(modalCtx).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(modalCtx).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => WoltModalSheet.of(modalCtx).showNext(),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      '정보가 맞습니다',
                      style: AppTextStyles.buttonText(modalCtx).copyWith(
                        color: Theme.of(modalCtx).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: Consumer(
          builder: (context, ref, child) {
            final result = ref.watch(businessVerificationResultProvider);
            return _buildStep2Content(modalCtx, result);
          },
        ),
      ),
      
      // Step 3: Document Upload & AI Verification
      WoltModalSheetPage(
        backgroundColor: Theme.of(modalCtx).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        pageTitle: null,
        leadingNavBarWidget: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '사업자 인증',
                style: AppTextStyles.dialogTitle(modalCtx),
              ),
              const SizedBox(height: 4),
              Text(
                '3/3 서류 업로드',
                style: AppTextStyles.captionText(modalCtx).copyWith(
                  color: Theme.of(modalCtx).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        trailingNavBarWidget: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => WoltModalSheet.of(modalCtx).showPrevious(),
          ),
        ),
        child: _Step3FormWidget(
          onComplete: () {
            if (modalCtx.mounted) {
              ToastHelper.success(modalCtx, '사업자 인증이 완료되었습니다');
              Navigator.of(modalCtx).pop();
            }
          },
        ),
      ),
    ],
    modalTypeBuilder: (ctx) => WoltModalType.bottomSheet(),
  );
}

// Step 1 Form Widget
class _Step1FormWidget extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  
  const _Step1FormWidget({required this.onComplete});

  @override
  ConsumerState<_Step1FormWidget> createState() => _Step1FormWidgetState();
}

class _Step1FormWidgetState extends ConsumerState<_Step1FormWidget> {
  
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
    // 캐시된 데이터 로드
    _loadCachedData();
  }

  void _loadCachedData() {
    final state = ref.read(businessVerificationProvider);
    final input = state.input;
    
    if (input != null && input.hasRequiredFields) {
      _registrationNumberCtl.text = input.businessNumber;
      _representativeNameCtl.text = input.representativeName;
      _openingDateCtl.text = input.openingDate;
      
      if (input.representativeName2?.isNotEmpty == true) {
        _representativeNameCtl2.text = input.representativeName2!;
        _showOptionalFields = true;
      }
      if (input.businessName?.isNotEmpty == true) {
        _businessNameCtl.text = input.businessName!;
        _showOptionalFields = true;
      }
      if (input.corporateNumber?.isNotEmpty == true) {
        _corporateNumberCtl.text = input.corporateNumber!;
        _showOptionalFields = true;
      }
      if (input.mainBusinessType?.isNotEmpty == true) {
        _mainBusinessCtl.text = input.mainBusinessType!;
        _showOptionalFields = true;
      }
      if (input.subBusinessType?.isNotEmpty == true) {
        _subBusinessCtl.text = input.subBusinessType!;
        _showOptionalFields = true;
      }
      if (input.businessAddress?.isNotEmpty == true) {
        _businessAddressCtl.text = input.businessAddress!;
        _showOptionalFields = true;
      }
      
      // 캐시된 데이터가 로드되었으므로 UI 업데이트
      setState(() {});
    }
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
    final notifier = ref.read(businessVerificationProvider.notifier);
    
    // 입력값을 Riverpod 상태로 업데이트
    final input = BusinessVerificationInput(
      businessNumber: _registrationNumberCtl.text.trim(),
      representativeName: _representativeNameCtl.text.trim(),
      openingDate: _openingDateCtl.text.trim(),
      representativeName2: _representativeNameCtl2.text.trim().isNotEmpty 
          ? _representativeNameCtl2.text.trim() 
          : null,
      businessName: _businessNameCtl.text.trim().isNotEmpty 
          ? _businessNameCtl.text.trim() 
          : null,
      corporateNumber: _corporateNumberCtl.text.trim().isNotEmpty 
          ? _corporateNumberCtl.text.trim() 
          : null,
      mainBusinessType: _mainBusinessCtl.text.trim().isNotEmpty 
          ? _mainBusinessCtl.text.trim() 
          : null,
      subBusinessType: _subBusinessCtl.text.trim().isNotEmpty 
          ? _subBusinessCtl.text.trim() 
          : null,
      businessAddress: _businessAddressCtl.text.trim().isNotEmpty 
          ? _businessAddressCtl.text.trim() 
          : null,
    );

    notifier.updateInput(input);
    
    // Riverpod으로 API 호출
    await notifier.verify();
    
    if (!mounted) return;
    
    // 결과에 따른 처리
    final state = ref.read(businessVerificationProvider);
    
    if (state.isSuccess && state.result != null) {
      final result = state.result!;
      
      // 사업자 상태에 따른 경고 처리
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
    final isFormValid = ref.watch(businessVerificationInputValidProvider);
    final isLoading = ref.watch(businessVerificationLoadingProvider);
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          // Action bar with validation button
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
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
          
          // Scrollable form content
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '사업자 정보를 입력해주세요',
                                  style: AppTextStyles.primaryText(context).copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '국세청 API를 통해 정보를 조회합니다\n아래 사업자등록증 사진은 미리 준비해주세요',
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
                    
                    // Form container
                    Container(
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
                          // Required fields section
                          Text(
                            '필수 정보',
                            style: AppTextStyles.sectionTitle(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Business Registration Number
                          _buildFormFieldWithError(
                            context: context,
                            label: '사업자등록번호',
                            controller: _registrationNumberCtl,
                            hint: '10자리 숫자 입력 (예: 1234567890)',
                            errorText: ref.watch(businessNumberValidationProvider(_registrationNumberCtl.text)),
                            keyboardType: TextInputType.number,
                            inputFormatters: [_BusinessNumberFormatter()],
                            onChanged: (value) => setState(() {}), // Trigger rebuild for button state
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Representative Name
                          _buildFormFieldWithError(
                            context: context,
                            label: '대표자명',
                            controller: _representativeNameCtl,
                            hint: '홍길동',
                            errorText: ref.watch(representativeNameValidationProvider(_representativeNameCtl.text)),
                            onChanged: (value) => setState(() {}), // Trigger rebuild for button state
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Opening Date
                          _buildFormFieldWithError(
                            context: context,
                            label: '개업일자',
                            controller: _openingDateCtl,
                            hint: '8자리 숫자 입력 (예: 20050302)',
                            errorText: ref.watch(openingDateValidationProvider(_openingDateCtl.text)),
                            keyboardType: TextInputType.number,
                            inputFormatters: [_DateFormatter()],
                            onChanged: (value) => setState(() {}), // Trigger rebuild for button state
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
                          
                          // Optional fields (conditionally shown)
                          if (_showOptionalFields) ...[
                            const SizedBox(height: 20),
                            
                            Text(
                              '선택 정보',
                              style: AppTextStyles.sectionTitle(context).copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Additional Representative Name
                            _buildFormFieldWithError(
                              context: context,
                              label: '대표자성명2',
                              controller: _representativeNameCtl2,
                              hint: '부대표자명',
                              isRequired: false,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Business Name
                            _buildFormFieldWithError(
                              context: context,
                              label: '상호',
                              controller: _businessNameCtl,
                              hint: '상호명을 입력하세요',
                              isRequired: false,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Corporate Number
                            _buildFormFieldWithError(
                              context: context,
                              label: '법인등록번호',
                              controller: _corporateNumberCtl,
                              hint: '000000-0000000',
                              isRequired: false,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Main Business
                            _buildFormFieldWithError(
                              context: context,
                              label: '주업태명',
                              controller: _mainBusinessCtl,
                              hint: '주요 업태를 입력하세요',
                              isRequired: false,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Sub Business
                            _buildFormFieldWithError(
                              context: context,
                              label: '주종목명',
                              controller: _subBusinessCtl,
                              hint: '주요 종목을 입력하세요',
                              isRequired: false,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Business Address
                            _buildFormFieldWithError(
                              context: context,
                              label: '사업장주소',
                              controller: _businessAddressCtl,
                              hint: '사업장 주소를 입력하세요',
                              isRequired: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
  XFile? _uploadedDocument;
  bool _isVerifying = false;
  String? _verificationResult;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        children: [
          // Action bar
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: _verificationResult == 'success'
                      ? [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        ]
                      : _uploadedDocument == null
                          ? [
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                            ]
                          : [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_verificationResult == 'success' || _uploadedDocument != null)
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _uploadedDocument == null && _verificationResult != 'success'
                      ? null
                      : () async {
                          if (_verificationResult == 'success') {
                            widget.onComplete();
                          } else if (_uploadedDocument != null && !_isVerifying) {
                            // Simulate AI verification
                            setState(() => _isVerifying = true);
                            await Future.delayed(const Duration(seconds: 2));
                            setState(() {
                              _verificationResult = 'success';
                              _isVerifying = false;
                            });
                            if (context.mounted) {
                              ToastHelper.success(context, 'AI 검증이 완료되었습니다');
                            }
                          }
                        },
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        _verificationResult == 'success'
                            ? '인증 완료'
                            : _uploadedDocument == null
                                ? '서류를 업로드해주세요'
                                : 'AI 검증 시작',
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Document upload content
          Expanded(
            child: _buildStep3Content(context, _uploadedDocument, _verificationResult,
                _isVerifying, (file) => setState(() => _uploadedDocument = file)),
          ),
        ],
      ),
    );
  }
}

// Helper function to build form fields with external error display
Widget _buildFormFieldWithError({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hint,
  String? errorText,
  bool isRequired = true,
  int maxLines = 1,
  ValueChanged<String>? onChanged,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
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
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: errorText != null 
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.primaryText(context),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.secondaryText(context),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ),
      if (errorText != null) ...[
        const SizedBox(height: 6),
        Text(
          errorText,
          style: AppTextStyles.captionText(context).copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    ],
  );
}

// Step 2: Business Information Confirmation
Widget _buildStep2Content(BuildContext context, BusinessVerificationResult? businessResult) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.65,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _getStatusContainerColor(context, businessResult),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusBorderColor(context, businessResult),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(businessResult),
                  color: _getStatusIconColor(context, businessResult),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(businessResult),
                        style: AppTextStyles.primaryText(context).copyWith(
                          color: _getStatusTextColor(context, businessResult),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusSubtitle(businessResult),
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
          
          // Business information display
          Container(
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
                Text(
                  '조회된 사업자 정보',
                  style: AppTextStyles.sectionTitle(context),
                ),
                const SizedBox(height: 20),
                
                if (businessResult != null) ...[
                  _buildInfoRow(context, '사업자등록번호', _formatBusinessNumber(businessResult.bNo)),
                  _buildInfoRow(context, '상호명', businessResult.requestParam.bNm ?? '-'),
                  _buildInfoRow(context, '대표자명', businessResult.requestParam.pNm),
                  if (businessResult.requestParam.pNm2?.isNotEmpty == true)
                    _buildInfoRow(context, '대표자명2', businessResult.requestParam.pNm2!),
                  if (businessResult.requestParam.corpNo?.isNotEmpty == true)
                    _buildInfoRow(context, '법인등록번호', _formatCorporateNumber(businessResult.requestParam.corpNo!)),
                  if (businessResult.requestParam.bSector?.isNotEmpty == true)
                    _buildInfoRow(context, '주업태명', businessResult.requestParam.bSector!),
                  if (businessResult.requestParam.bType?.isNotEmpty == true)
                    _buildInfoRow(context, '주종목명', businessResult.requestParam.bType!),
                  if (businessResult.requestParam.bAdr?.isNotEmpty == true)
                    _buildInfoRow(context, '사업장주소', businessResult.requestParam.bAdr!),
                  _buildInfoRow(context, '개업일자', _formatDate(businessResult.requestParam.startDt)),
                  if (businessResult.status != null) ...[
                    _buildInfoRow(context, '사업자상태', businessResult.status!.businessStatusDescription),
                    _buildInfoRow(context, '과세유형', businessResult.status!.taxType),
                    if (businessResult.status!.endDt?.isNotEmpty == true)
                      _buildInfoRow(context, '폐업일자', _formatDate(businessResult.status!.endDt!)),
                  ],
                  _buildInfoRow(context, '진위확인', businessResult.isValid ? '확인됨' : '확인불가', isLast: true),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Step 3: Document Upload & AI Verification
Widget _buildStep3Content(
  BuildContext context,
  XFile? uploadedDocument,
  String? verificationResult,
  bool isVerifying,
  ValueChanged<XFile?> onDocumentUploaded,
) {
  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: verificationResult == 'success'
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: verificationResult == 'success'
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                verificationResult == 'success'
                    ? Icons.verified_rounded
                    : Icons.upload_file_rounded,
                color: verificationResult == 'success'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verificationResult == 'success'
                          ? 'AI 검증 완료'
                          : '사업자등록증을 업로드하세요',
                      style: AppTextStyles.primaryText(context).copyWith(
                        color: verificationResult == 'success'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      verificationResult == 'success'
                          ? '서류가 정상적으로 검증되었습니다'
                          : 'JPG, PNG 파일을 지원합니다',
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
        
        // Document upload area
        Container(
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: uploadedDocument != null ? null : () async {
                try {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    onDocumentUploaded(image);
                    if (context.mounted) {
                      ToastHelper.success(context, '서류가 업로드되었습니다');
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastHelper.error(context, '파일 업로드 중 오류가 발생했습니다');
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    if (uploadedDocument == null) ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_rounded,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '서류를 선택하세요',
                        style: AppTextStyles.primaryText(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'JPG, PNG 파일 (최대 10MB)',
                        style: AppTextStyles.captionText(context),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        uploadedDocument.name,
                        style: AppTextStyles.primaryText(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '업로드 완료',
                        style: AppTextStyles.captionText(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => onDocumentUploaded(null),
                        child: Text(
                          '다시 선택',
                          style: AppTextStyles.primaryText(context).copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Verification status
        if (uploadedDocument != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: verificationResult == 'success'
                  ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: verificationResult == 'success'
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      verificationResult == 'success'
                          ? Icons.check_circle_rounded
                          : isVerifying
                              ? Icons.hourglass_empty_rounded
                              : Icons.smart_toy_rounded,
                      color: verificationResult == 'success'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      verificationResult == 'success'
                          ? 'AI 검증 성공'
                          : isVerifying
                              ? 'AI 검증 중...'
                              : 'AI 검증 대기',
                      style: AppTextStyles.primaryText(context).copyWith(
                        color: verificationResult == 'success'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  verificationResult == 'success'
                      ? '서류가 정상적으로 검증되었습니다. 사업자 인증을 완료할 수 있습니다.'
                      : isVerifying
                          ? 'AI가 업로드된 서류를 분석하고 있습니다. 잠시만 기다려주세요.'
                          : '업로드된 서류를 AI가 자동으로 검증합니다.',
                  style: AppTextStyles.captionText(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

// Business Registration Number Formatter (10 digits -> xxx-xx-xxxxx)
class _BusinessNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-numeric characters
    final numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 10 digits
    final limitedText = numericOnly.length > 10 ? numericOnly.substring(0, 10) : numericOnly;
    
    // Format as xxx-xx-xxxxx
    String formatted = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 3 || i == 5) {
        formatted += '-';
      }
      formatted += limitedText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Date Formatter (8 digits -> YYYY-MM-DD)
class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-numeric characters
    final numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 8 digits
    final limitedText = numericOnly.length > 8 ? numericOnly.substring(0, 8) : numericOnly;
    
    // Format as YYYY-MM-DD
    String formatted = '';
    for (int i = 0; i < limitedText.length; i++) {
      if (i == 4 || i == 6) {
        formatted += '-';
      }
      formatted += limitedText[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Helper functions for business status UI
Color _getStatusContainerColor(BuildContext context, BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3);
  } else if (result?.status?.isOnHiatus == true) {
    return Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3);
  } else {
    return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
  }
}

Color _getStatusBorderColor(BuildContext context, BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return Theme.of(context).colorScheme.error.withValues(alpha: 0.2);
  } else if (result?.status?.isOnHiatus == true) {
    return Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2);
  } else {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
  }
}

IconData _getStatusIcon(BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return Icons.cancel_rounded;
  } else if (result?.status?.isOnHiatus == true) {
    return Icons.pause_circle_rounded;
  } else {
    return Icons.check_circle_rounded;
  }
}

Color _getStatusIconColor(BuildContext context, BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return Theme.of(context).colorScheme.error;
  } else if (result?.status?.isOnHiatus == true) {
    return Theme.of(context).colorScheme.tertiary;
  } else {
    return Theme.of(context).colorScheme.primary;
  }
}

Color _getStatusTextColor(BuildContext context, BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return Theme.of(context).colorScheme.error;
  } else if (result?.status?.isOnHiatus == true) {
    return Theme.of(context).colorScheme.tertiary;
  } else {
    return Theme.of(context).colorScheme.primary;
  }
}

String _getStatusTitle(BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return '폐업된 사업자로 확인됨';
  } else if (result?.status?.isOnHiatus == true) {
    return '휴업 중인 사업자로 확인됨';
  } else {
    return '사업자 정보 조회 완료';
  }
}

String _getStatusSubtitle(BusinessVerificationResult? result) {
  if (result?.status?.isClosed == true) {
    return '폐업 처리된 사업자입니다';
  } else if (result?.status?.isOnHiatus == true) {
    return '현재 휴업 상태인 사업자입니다';
  } else {
    return '아래 정보가 정확한지 확인해주세요';
  }
}

// Helper functions for data formatting
String _formatBusinessNumber(String number) {
  if (number.length == 10) {
    return '${number.substring(0, 3)}-${number.substring(3, 5)}-${number.substring(5)}';
  }
  return number;
}

String _formatCorporateNumber(String number) {
  if (number.length == 13) {
    return '${number.substring(0, 6)}-${number.substring(6)}';
  }
  return number;
}

String _formatDate(String date) {
  if (date.length == 8) {
    return '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6)}';
  }
  return date;
}

// Helper function to build info rows
Widget _buildInfoRow(BuildContext context, String label, String value, {bool isLast = false}) {
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.secondaryText(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: AppTextStyles.primaryText(context),
            ),
          ),
        ],
      ),
      if (!isLast) ...[
        const SizedBox(height: 16),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 16),
      ],
    ],
  );
}