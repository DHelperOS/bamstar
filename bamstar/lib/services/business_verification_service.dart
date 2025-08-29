import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/business_verification_models.dart';

class BusinessVerificationService {
  static const String _baseUrl = 'https://api.odcloud.kr/api/nts-businessman/v1';
  static const String _validateEndpoint = '/validate';
  
  final Dio _dio;
  
  BusinessVerificationService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// 사업자등록정보 진위확인 API 호출
  /// 성공시 상태조회 정보도 함께 반환됨
  Future<BusinessVerificationResult> validateBusinessInfo({
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
      final serviceKey = dotenv.env['PLACE_API_KEY'];
      if (serviceKey == null || serviceKey.isEmpty) {
        throw Exception('API 키가 설정되지 않았습니다');
      }

      // 사업자번호 형식 변환 (하이픈 제거)
      final cleanBusinessNumber = businessNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanBusinessNumber.length != 10) {
        throw Exception('사업자등록번호는 10자리 숫자여야 합니다');
      }

      // 개업일자 형식 변환 (하이픈 제거)
      final cleanOpeningDate = openingDate.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanOpeningDate.length != 8) {
        throw Exception('개업일자는 8자리 숫자여야 합니다 (YYYYMMDD)');
      }

      // 요청 데이터 구성
      final businessData = BusinessData(
        bNo: cleanBusinessNumber,
        startDt: cleanOpeningDate,
        pNm: representativeName,
        pNm2: representativeName2?.isNotEmpty == true ? representativeName2 : null,
        bNm: businessName?.isNotEmpty == true ? businessName : null,
        corpNo: corporateNumber?.isNotEmpty == true ? corporateNumber?.replaceAll(RegExp(r'[^0-9]'), '') : null,
        bSector: mainBusinessType?.isNotEmpty == true ? mainBusinessType : null,
        bType: subBusinessType?.isNotEmpty == true ? subBusinessType : null,
        bAdr: businessAddress?.isNotEmpty == true ? businessAddress : null,
      );

      final request = BusinessVerificationRequest(businesses: [businessData]);

      // API 호출
      final response = await _dio.post(
        '$_baseUrl$_validateEndpoint',
        queryParameters: {
          'serviceKey': serviceKey,
          'returnType': 'JSON',
        },
        data: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final businessResponse = BusinessVerificationResponse.fromJson(response.data);
        
        if (businessResponse.data.isNotEmpty) {
          return businessResponse.data.first;
        } else {
          throw Exception('조회 결과가 없습니다');
        }
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic>) {
          final error = BusinessVerificationError.fromJson(errorData);
          throw Exception(error.errorMessage);
        }
        throw Exception('잘못된 요청입니다');
      } else if (e.response?.statusCode == 411) {
        throw Exception('필수 파라미터가 누락되었습니다');
      } else if (e.response?.statusCode == 413) {
        throw Exception('요청 데이터가 너무 큽니다');
      } else if (e.response?.statusCode == 500) {
        throw Exception('서버 내부 오류가 발생했습니다');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('연결 시간이 초과되었습니다');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('응답 시간이 초과되었습니다');
      } else {
        throw Exception('네트워크 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw Exception('사업자 정보 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 입력 데이터 검증
  static String? validateBusinessNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '사업자등록번호를 입력하세요';
    }
    
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length != 10) {
      return '사업자등록번호는 10자리 숫자여야 합니다';
    }
    
    return null;
  }

  static String? validateRepresentativeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '대표자명을 입력하세요';
    }
    
    return null;
  }

  static String? validateOpeningDate(String? value) {
    if (value == null || value.isEmpty) {
      return '개업일자를 입력하세요';
    }
    
    final cleanDate = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDate.length != 8) {
      return '개업일자는 8자리 숫자여야 합니다 (YYYYMMDD)';
    }
    
    // 날짜 유효성 검증 (기본적인)
    try {
      final year = int.parse(cleanDate.substring(0, 4));
      final month = int.parse(cleanDate.substring(4, 6));
      final day = int.parse(cleanDate.substring(6, 8));
      
      if (year < 1900 || year > DateTime.now().year) {
        return '올바른 연도를 입력하세요';
      }
      if (month < 1 || month > 12) {
        return '올바른 월을 입력하세요';
      }
      if (day < 1 || day > 31) {
        return '올바른 일을 입력하세요';
      }
    } catch (e) {
      return '올바른 날짜 형식을 입력하세요';
    }
    
    return null;
  }
}