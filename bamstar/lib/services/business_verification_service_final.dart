import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_verification_models.dart';
import 'cloudinary.dart';

/// 사업자 인증 서비스 - 최종 버전
/// 비즈니스 로직에 맞는 상태 관리 및 데이터베이스 연동
class BusinessVerificationServiceFinal {
  static final BusinessVerificationServiceFinal _instance = 
      BusinessVerificationServiceFinal._internal();
  factory BusinessVerificationServiceFinal() => _instance;
  BusinessVerificationServiceFinal._internal();

  static BusinessVerificationServiceFinal get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;
  final CloudinaryService _cloudinary = CloudinaryService.instance;

  /// ================================================
  /// 1. 사업자 인증 기록 생성 (Step 1: 정보입력)
  /// ================================================
  Future<String?> createBusinessVerification({
    required String businessNumber,
    required String representativeName,
    required String openingDate,
    String? representativeName2,
    String? businessName,
    String? corporateNumber,
    String? mainBusinessType,
    String? subBusinessType,
    String? businessAddress,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다');
      }

      print('=== 사업자 인증 기록 생성 ===');
      print('User ID: ${currentUser.id}');
      print('Business Number: $businessNumber');

      // 사업자번호 유효성 검사
      final isValidBusiness = await _validateBusinessNumber(businessNumber);
      if (!isValidBusiness) {
        throw Exception('올바르지 않은 사업자등록번호입니다');
      }

      // 새 인증 기록 생성 (이전 기록은 자동으로 is_latest = false가 됨)
      final response = await _supabase
          .from('business_verifications')
          .insert({
            'user_id': currentUser.id,
            'is_latest': true,
            'business_number': businessNumber,
            'representative_name': representativeName,
            'opening_date': openingDate,
            'representative_name2': representativeName2?.isNotEmpty == true ? representativeName2 : null,
            'business_name': businessName?.isNotEmpty == true ? businessName : null,
            'corporate_number': corporateNumber?.isNotEmpty == true ? corporateNumber : null,
            'main_business_type': mainBusinessType?.isNotEmpty == true ? mainBusinessType : null,
            'sub_business_type': subBusinessType?.isNotEmpty == true ? subBusinessType : null,
            'business_address': businessAddress?.isNotEmpty == true ? businessAddress : null,
            'overall_status': 'draft',
          })
          .select('id')
          .single();

      final verificationId = response['id'] as String;
      print('✅ 인증 기록 생성 완료: $verificationId');

      return verificationId;
    } catch (e) {
      print('❌ 사업자 인증 기록 생성 실패: $e');
      throw Exception('사업자 정보 저장에 실패했습니다: $e');
    }
  }

  /// ================================================
  /// 2. 국세청 API 조회 및 결과 저장 (Step 2: 조회결과)
  /// ================================================
  Future<bool> verifyWithNTS({
    required String verificationId,
    required Map<String, String> businessData,
  }) async {
    try {
      print('=== 국세청 API 조회 시작 ===');
      print('Verification ID: $verificationId');

      // 국세청 API 호출 (실제 API 연동)
      final ntsResponse = await _callNTSApi(businessData);
      
      if (ntsResponse['success'] == true) {
        // 국세청 조회 성공
        await _supabase
            .from('business_verifications')
            .update({
              'nts_verification_status': 'success',
              'nts_response': ntsResponse,
              'nts_verified_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', verificationId);

        print('✅ 국세청 조회 성공');
        return true;
      } else {
        // 국세청 조회 실패
        await _supabase
            .from('business_verifications')
            .update({
              'nts_verification_status': 'failed',
              'nts_error_message': ntsResponse['error'] ?? '국세청 조회에 실패했습니다',
              'overall_status': 'nts_failed',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', verificationId);

        print('❌ 국세청 조회 실패: ${ntsResponse['error']}');
        return false;
      }
    } catch (e) {
      print('❌ 국세청 API 호출 오류: $e');
      
      // 오류 발생 시 실패 상태로 업데이트
      await _supabase
          .from('business_verifications')
          .update({
            'nts_verification_status': 'failed',
            'nts_error_message': e.toString(),
            'overall_status': 'nts_failed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', verificationId);
      
      return false;
    }
  }

  /// ================================================
  /// 3. 문서 업로드 및 AI 검증 (Step 3: 서류제출)
  /// ================================================
  Future<bool> uploadAndVerifyDocument({
    required String verificationId,
    required File imageFile,
  }) async {
    try {
      print('=== 문서 업로드 및 AI 검증 시작 ===');
      print('Verification ID: $verificationId');

      // 1. 파일 업로드 (Supabase Storage)
      final storageResult = await _uploadDocument(verificationId, imageFile);
      if (storageResult == null) {
        throw Exception('문서 업로드에 실패했습니다');
      }

      // 2. 문서 기록 생성
      final documentRecord = await _supabase
          .from('business_registration_documents')
          .insert({
            'verification_id': verificationId,
            'file_name': storageResult['fileName'],
            'file_size': storageResult['fileSize'],
            'file_type': storageResult['fileType'],
            'storage_path': storageResult['storagePath'],
            'storage_bucket': 'business-documents',
            'processing_status': 'pending',
          })
          .select('id')
          .single();

      print('✅ 문서 기록 생성 완료: ${documentRecord['id']}');

      // 3. AI 검증 수행
      final aiResult = await _performAIVerification(verificationId, imageFile);
      
      // 4. AI 결과에 따른 상태 업데이트
      final newStatus = _determineStatusFromAI(aiResult['matchPercentage']);
      
      await _supabase
          .from('business_verifications')
          .update({
            'document_verification_status': 'success',
            'ai_match_percentage': aiResult['matchPercentage'],
            'ai_extracted_data': aiResult['extractedData'],
            'ai_verified_at': DateTime.now().toIso8601String(),
            'overall_status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', verificationId);

      // 5. 문서 처리 완료 업데이트
      await _supabase
          .from('business_registration_documents')
          .update({
            'ocr_text': aiResult['extractedText'],
            'processing_status': 'processed',
            'processed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', documentRecord['id']);

      print('✅ AI 검증 완료: $newStatus (${aiResult['matchPercentage']}%)');
      return true;

    } catch (e) {
      print('❌ 문서 업로드/AI 검증 실패: $e');
      
      // 실패 상태로 업데이트
      await _supabase
          .from('business_verifications')
          .update({
            'document_verification_status': 'failed',
            'ai_error_message': e.toString(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', verificationId);
      
      return false;
    }
  }

  /// ================================================
  /// 4. 사용자 최신 인증 정보 조회
  /// ================================================
  Future<Map<String, dynamic>?> getUserLatestVerification() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _supabase
          .from('business_verifications')
          .select('''
            id,
            business_number,
            representative_name,
            opening_date,
            representative_name2,
            business_name,
            corporate_number,
            main_business_type,
            sub_business_type,
            business_address,
            overall_status,
            nts_verification_status,
            document_verification_status,
            ai_match_percentage,
            nts_response,
            ai_extracted_data,
            created_at,
            updated_at
          ''')
          .eq('user_id', currentUser.id)
          .eq('is_latest', true)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ 사용자 인증 정보 조회 실패: $e');
      return null;
    }
  }

  /// ================================================
  /// 5. 인증 이력 조회
  /// ================================================
  Future<List<Map<String, dynamic>>> getVerificationHistory(String verificationId) async {
    try {
      final response = await _supabase
          .from('business_verification_history')
          .select('''
            id,
            action,
            previous_status,
            new_status,
            details,
            created_at
          ''')
          .eq('verification_id', verificationId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ 인증 이력 조회 실패: $e');
      return [];
    }
  }

  /// ================================================
  /// 6. 상태별 안내 메시지 조회
  /// ================================================
  String getStatusMessage(String status) {
    switch (status) {
      case 'draft':
        return '인증 신청을 진행해주세요';
      case 'nts_failed':
        return '국세청 조회에 실패했습니다. 고객센터로 문의해주세요';
      case 'ai_low_score':
        return '사업자등록증 이미지를 다시 업로드해주세요 (인식률 부족)';
      case 'pending_admin_review':
        return '관리자 검토 중입니다. 영업일 기준 1-2일 소요됩니다';
      case 'auto_verified':
        return '사업자 인증이 완료되었습니다';
      case 'admin_approved':
        return '관리자 승인으로 사업자 인증이 완료되었습니다';
      case 'admin_rejected':
        return '관리자 검토 결과 인증이 거부되었습니다';
      default:
        return '알 수 없는 상태입니다';
    }
  }

  /// ================================================
  /// 내부 헬퍼 메서드들
  /// ================================================

  /// 사업자번호 유효성 검사
  Future<bool> _validateBusinessNumber(String businessNumber) async {
    try {
      final response = await _supabase
          .rpc('validate_business_number', params: {'business_number': businessNumber});
      return response == true;
    } catch (e) {
      print('사업자번호 검증 오류: $e');
      return false;
    }
  }

  /// 국세청 API 호출
  Future<Map<String, dynamic>> _callNTSApi(Map<String, String> businessData) async {
    // TODO: 실제 국세청 API 연동
    // 현재는 모의 응답 반환
    await Future.delayed(const Duration(seconds: 2));
    
    // 임시: 90% 확률로 성공
    final isSuccess = DateTime.now().millisecondsSinceEpoch % 10 != 0;
    
    if (isSuccess) {
      return {
        'success': true,
        'bNo': businessData['business_number'],
        'requestParam': {
          'pNm': businessData['representative_name'],
          'startDt': businessData['opening_date'],
        },
        'status': {
          'taxType': '일반과세자',
          'bStt': '계속사업자',
        }
      };
    } else {
      return {
        'success': false,
        'error': '국세청 시스템 오류 또는 사업자정보 불일치'
      };
    }
  }

  /// 문서 업로드 (Cloudinary)
  Future<Map<String, dynamic>?> _uploadDocument(String verificationId, File imageFile) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      final fileName = '${verificationId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await imageFile.readAsBytes();
      
      // Upload to Cloudinary with business-documents folder
      final cloudinaryUrl = await _cloudinary.uploadImageFromBytes(
        fileBytes,
        fileName: fileName,
        folder: 'business-documents/${currentUser.id}',
      );

      return {
        'fileName': fileName,
        'fileSize': fileBytes.length,
        'fileType': 'image/jpeg',
        'cloudinaryUrl': cloudinaryUrl,
        'storagePath': 'business-documents/${currentUser.id}/$fileName',
      };
    } catch (e) {
      print('문서 업로드 실패: $e');
      return null;
    }
  }



  /// AI 검증 수행
  Future<Map<String, dynamic>> _performAIVerification(String verificationId, File imageFile) async {
    try {
      // TODO: 실제 Gemini AI 연동
      // 현재는 모의 검증 결과 반환
      await Future.delayed(const Duration(seconds: 3));
      
      // 임시: 랜덤 AI 점수 생성
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      final matchPercentage = (random < 10) ? 25.0 : // 10% 확률로 낮은 점수
                             (random < 40) ? 50.0 : // 30% 확률로 중간 점수  
                             85.0; // 60% 확률로 높은 점수

      return {
        'matchPercentage': matchPercentage,
        'extractedData': {
          'businessNumber': '1234567890',
          'representativeName': '홍길동',
          'openingDate': '20200101',
        },
        'extractedText': '사업자등록증\n사업자등록번호: 123-45-67890\n성명(대표자): 홍길동\n개업일: 2020년 01월 01일'
      };
    } catch (e) {
      print('AI 검증 실패: $e');
      throw Exception('AI 검증에 실패했습니다: $e');
    }
  }

  /// AI 결과에 따른 상태 결정
  String _determineStatusFromAI(double matchPercentage) {
    if (matchPercentage <= 30) {
      return 'ai_low_score';
    } else if (matchPercentage < 70) {
      return 'pending_admin_review';
    } else {
      return 'auto_verified';
    }
  }

  /// ================================================
  /// 7. 유효성 검사 메서드들 (기존 호환성 유지)
  /// ================================================
  
  static String? validateBusinessNumber(String value) {
    if (value.isEmpty) {
      return '사업자등록번호를 입력해주세요';
    }
    if (value.length != 10) {
      return '사업자등록번호는 10자리여야 합니다';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '숫자만 입력 가능합니다';
    }
    return null;
  }

  static String? validateRepresentativeName(String value) {
    if (value.isEmpty) {
      return '대표자명을 입력해주세요';
    }
    if (value.length < 2) {
      return '대표자명은 2자 이상이어야 합니다';
    }
    return null;
  }

  static String? validateOpeningDate(String value) {
    if (value.isEmpty) {
      return '개업일자를 입력해주세요';
    }
    if (value.length != 8) {
      return '개업일자는 8자리여야 합니다 (YYYYMMDD)';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '숫자만 입력 가능합니다';
    }
    
    // 날짜 유효성 검사
    try {
      final year = int.parse(value.substring(0, 4));
      final month = int.parse(value.substring(4, 6));
      final day = int.parse(value.substring(6, 8));
      
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return '미래 날짜는 입력할 수 없습니다';
      }
      if (year < 1900) {
        return '1900년 이후 날짜를 입력해주세요';
      }
    } catch (e) {
      return '올바르지 않은 날짜입니다';
    }
    
    return null;
  }
}