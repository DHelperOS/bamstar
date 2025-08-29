import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/business_verification_models.dart';
import '../../services/business_verification_service.dart';

/// 사업자 인증 입력 데이터 상태 클래스
class BusinessVerificationInput {
  final String businessNumber;
  final String representativeName;
  final String openingDate;
  final String? representativeName2;
  final String? businessName;
  final String? corporateNumber;
  final String? mainBusinessType;
  final String? subBusinessType;
  final String? businessAddress;

  const BusinessVerificationInput({
    required this.businessNumber,
    required this.representativeName,
    required this.openingDate,
    this.representativeName2,
    this.businessName,
    this.corporateNumber,
    this.mainBusinessType,
    this.subBusinessType,
    this.businessAddress,
  });

  BusinessVerificationInput copyWith({
    String? businessNumber,
    String? representativeName,
    String? openingDate,
    String? representativeName2,
    String? businessName,
    String? corporateNumber,
    String? mainBusinessType,
    String? subBusinessType,
    String? businessAddress,
  }) {
    return BusinessVerificationInput(
      businessNumber: businessNumber ?? this.businessNumber,
      representativeName: representativeName ?? this.representativeName,
      openingDate: openingDate ?? this.openingDate,
      representativeName2: representativeName2 ?? this.representativeName2,
      businessName: businessName ?? this.businessName,
      corporateNumber: corporateNumber ?? this.corporateNumber,
      mainBusinessType: mainBusinessType ?? this.mainBusinessType,
      subBusinessType: subBusinessType ?? this.subBusinessType,
      businessAddress: businessAddress ?? this.businessAddress,
    );
  }

  bool get hasRequiredFields {
    return businessNumber.trim().isNotEmpty &&
           representativeName.trim().isNotEmpty &&
           openingDate.trim().isNotEmpty;
  }

  /// JSON으로 변환 (캐싱용)
  Map<String, dynamic> toJson() {
    return {
      'businessNumber': businessNumber,
      'representativeName': representativeName,
      'openingDate': openingDate,
      'representativeName2': representativeName2,
      'businessName': businessName,
      'corporateNumber': corporateNumber,
      'mainBusinessType': mainBusinessType,
      'subBusinessType': subBusinessType,
      'businessAddress': businessAddress,
    };
  }

  /// JSON에서 생성 (캐싱용)
  factory BusinessVerificationInput.fromJson(Map<String, dynamic> json) {
    return BusinessVerificationInput(
      businessNumber: json['businessNumber'] ?? '',
      representativeName: json['representativeName'] ?? '',
      openingDate: json['openingDate'] ?? '',
      representativeName2: json['representativeName2'],
      businessName: json['businessName'],
      corporateNumber: json['corporateNumber'],
      mainBusinessType: json['mainBusinessType'],
      subBusinessType: json['subBusinessType'],
      businessAddress: json['businessAddress'],
    );
  }
}

/// 사업자 인증 상태 클래스
class BusinessVerificationState {
  final BusinessVerificationInput? input;
  final BusinessVerificationResult? result;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final Map<String, String>? extractedData; // Gemini에서 추출한 데이터

  const BusinessVerificationState({
    this.input,
    this.result,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.extractedData,
  });

  BusinessVerificationState copyWith({
    BusinessVerificationInput? input,
    BusinessVerificationResult? result,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    Map<String, String>? extractedData,
  }) {
    return BusinessVerificationState(
      input: input ?? this.input,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      extractedData: extractedData ?? this.extractedData,
    );
  }

  BusinessVerificationState clearError() {
    return copyWith(error: null);
  }

  BusinessVerificationState setLoading() {
    return copyWith(isLoading: true, error: null);
  }
}

/// 사업자 인증 상태 관리자
class BusinessVerificationNotifier extends StateNotifier<BusinessVerificationState> {
  BusinessVerificationNotifier() : super(const BusinessVerificationState()) {
    _loadCachedInput();
  }

  final _service = BusinessVerificationService();
  static const String _cacheKey = 'business_verification_input';

  /// 캐시된 입력값 로드
  Future<void> _loadCachedInput() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      
      if (cachedJson != null) {
        final json = jsonDecode(cachedJson) as Map<String, dynamic>;
        final input = BusinessVerificationInput.fromJson(json);
        state = state.copyWith(input: input);
      }
    } catch (e) {
      // 캐시 로드 실패는 무시 (첫 실행 등)
    }
  }

  /// 성공한 입력값을 캐시에 저장
  Future<void> _saveCachedInput(BusinessVerificationInput input) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(input.toJson());
      await prefs.setString(_cacheKey, json);
    } catch (e) {
      // 캐시 저장 실패는 무시
    }
  }

  /// 캐시 삭제
  Future<void> _clearCachedInput() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      // 캐시 삭제 실패는 무시
    }
  }

  /// 입력값 업데이트
  void updateInput(BusinessVerificationInput input) {
    state = state.copyWith(input: input);
  }

  /// 사업자 인증 실행
  Future<void> verify() async {
    if (state.input == null || !state.input!.hasRequiredFields) {
      state = state.copyWith(error: '필수 정보를 모두 입력해주세요');
      return;
    }

    state = state.setLoading();

    try {
      final result = await _service.validateBusinessInfo(
        businessNumber: state.input!.businessNumber,
        representativeName: state.input!.representativeName,
        openingDate: state.input!.openingDate,
        representativeName2: state.input!.representativeName2,
        businessName: state.input!.businessName,
        corporateNumber: state.input!.corporateNumber,
        mainBusinessType: state.input!.mainBusinessType,
        subBusinessType: state.input!.subBusinessType,
        businessAddress: state.input!.businessAddress,
      );

      state = state.copyWith(
        result: result,
        isLoading: false,
        isSuccess: result.isValid,
        error: result.isValid ? null : (result.validMsg ?? '사업자 정보를 확인할 수 없습니다'),
      );

      // 성공 시 입력값을 캐시에 저장
      if (result.isValid && state.input != null) {
        await _saveCachedInput(state.input!);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 상태 초기화
  void reset() {
    state = const BusinessVerificationState();
    _clearCachedInput();
  }

  /// 에러 클리어
  void clearError() {
    state = state.clearError();
  }

  /// 캐시된 입력값이 있는지 확인
  bool get hasCachedInput {
    return state.input != null && state.input!.hasRequiredFields;
  }

  /// 성공한 입력값 가져오기 (캐싱용)
  BusinessVerificationInput? get successfulInput {
    return state.isSuccess ? state.input : null;
  }

  /// Gemini에서 추출한 데이터 저장
  void setExtractedData(Map<String, String> extractedData) {
    state = state.copyWith(extractedData: extractedData);
  }
}

/// 사업자 인증 프로바이더
final businessVerificationProvider = StateNotifierProvider<BusinessVerificationNotifier, BusinessVerificationState>((ref) {
  return BusinessVerificationNotifier();
});

/// 사업자 인증 서비스 프로바이더
final businessVerificationServiceProvider = Provider<BusinessVerificationService>((ref) {
  return BusinessVerificationService();
});

/// 입력값 유효성 검증 프로바이더
final businessVerificationInputValidProvider = Provider<bool>((ref) {
  final state = ref.watch(businessVerificationProvider);
  return state.input?.hasRequiredFields ?? false;
});

/// 로딩 상태 프로바이더
final businessVerificationLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(businessVerificationProvider);
  return state.isLoading;
});

/// 에러 상태 프로바이더
final businessVerificationErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(businessVerificationProvider);
  return state.error;
});

/// 성공 상태 프로바이더
final businessVerificationSuccessProvider = Provider<bool>((ref) {
  final state = ref.watch(businessVerificationProvider);
  return state.isSuccess;
});

/// 결과 데이터 프로바이더
/// 사업자등록번호 유효성 검증 프로바이더
final businessNumberValidationProvider = Provider.family<String?, String?>((ref, value) {
  return BusinessVerificationService.validateBusinessNumber(value);
});

/// 대표자명 유효성 검증 프로바이더  
final representativeNameValidationProvider = Provider.family<String?, String?>((ref, value) {
  return BusinessVerificationService.validateRepresentativeName(value);
});

/// 개업일자 유효성 검증 프로바이더
final openingDateValidationProvider = Provider.family<String?, String?>((ref, value) {
  return BusinessVerificationService.validateOpeningDate(value);
});

/// 결과 데이터 프로바이더 (수정됨)
final businessVerificationResultProvider = Provider<BusinessVerificationResult?>((ref) {
  final state = ref.watch(businessVerificationProvider);
  return state.result;
});