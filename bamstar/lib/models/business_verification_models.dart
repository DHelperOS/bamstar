class BusinessVerificationRequest {
  final List<BusinessData> businesses;

  BusinessVerificationRequest({required this.businesses});

  Map<String, dynamic> toJson() {
    return {
      'businesses': businesses.map((e) => e.toJson()).toList(),
    };
  }
}

class BusinessData {
  final String bNo; // 사업자등록번호 (필수)
  final String startDt; // 개업일자 (필수) YYYYMMDD
  final String pNm; // 대표자성명 (필수)
  final String? pNm2; // 대표자성명2 (선택)
  final String? bNm; // 상호 (선택)
  final String? corpNo; // 법인등록번호 (선택)
  final String? bSector; // 주업태명 (선택)
  final String? bType; // 주종목명 (선택)
  final String? bAdr; // 사업장주소 (선택)

  BusinessData({
    required this.bNo,
    required this.startDt,
    required this.pNm,
    this.pNm2,
    this.bNm,
    this.corpNo,
    this.bSector,
    this.bType,
    this.bAdr,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'b_no': bNo,
      'start_dt': startDt,
      'p_nm': pNm,
    };

    // 선택 필드들은 빈 문자열로 포함
    if (pNm2 != null) json['p_nm2'] = pNm2!;
    if (bNm != null) json['b_nm'] = bNm!;
    if (corpNo != null) json['corp_no'] = corpNo!;
    if (bSector != null) json['b_sector'] = bSector!;
    if (bType != null) json['b_type'] = bType!;
    if (bAdr != null) json['b_adr'] = bAdr!;

    return json;
  }
}

class BusinessVerificationResponse {
  final String statusCode;
  final int requestCnt;
  final int validCnt;
  final List<BusinessVerificationResult> data;

  BusinessVerificationResponse({
    required this.statusCode,
    required this.requestCnt,
    required this.validCnt,
    required this.data,
  });

  factory BusinessVerificationResponse.fromJson(Map<String, dynamic> json) {
    return BusinessVerificationResponse(
      statusCode: json['status_code'] ?? '',
      requestCnt: json['request_cnt'] ?? 0,
      validCnt: json['valid_cnt'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BusinessVerificationResult.fromJson(e))
          .toList(),
    );
  }
}

class BusinessVerificationResult {
  final String bNo;
  final String valid; // "01": Valid, "02": Invalid
  final String? validMsg;
  final BusinessData requestParam;
  final BusinessStatus? status;

  BusinessVerificationResult({
    required this.bNo,
    required this.valid,
    this.validMsg,
    required this.requestParam,
    this.status,
  });

  bool get isValid => valid == '01';

  factory BusinessVerificationResult.fromJson(Map<String, dynamic> json) {
    return BusinessVerificationResult(
      bNo: json['b_no'] ?? '',
      valid: json['valid'] ?? '',
      validMsg: json['valid_msg'],
      requestParam: BusinessData(
        bNo: json['request_param']['b_no'] ?? '',
        startDt: json['request_param']['start_dt'] ?? '',
        pNm: json['request_param']['p_nm'] ?? '',
        pNm2: json['request_param']['p_nm2'],
        bNm: json['request_param']['b_nm'],
        corpNo: json['request_param']['corp_no'],
        bSector: json['request_param']['b_sector'],
        bType: json['request_param']['b_type'],
        bAdr: json['request_param']['b_adr'],
      ),
      status: json['status'] != null ? BusinessStatus.fromJson(json['status']) : null,
    );
  }
}

class BusinessStatus {
  final String bNo;
  final String bStt; // 납세자상태명칭
  final String bSttCd; // 납세자상태코드 ("01": 계속사업자, "02": 휴업자, "03": 폐업자)
  final String taxType; // 과세유형메세지명칭
  final String taxTypeCd; // 과세유형메세지코드
  final String? endDt; // 폐업일 (YYYYMMDD)
  final String? utccYn; // 단위과세전환폐업여부
  final String? taxTypeChangeDt; // 최근과세유형전환일자
  final String? invoiceApplyDt; // 세금계산서적용일자
  final String? rbfTaxType; // 직전과세유형메세지명칭
  final String? rbfTaxTypeCd; // 직전과세유형메세지코드

  BusinessStatus({
    required this.bNo,
    required this.bStt,
    required this.bSttCd,
    required this.taxType,
    required this.taxTypeCd,
    this.endDt,
    this.utccYn,
    this.taxTypeChangeDt,
    this.invoiceApplyDt,
    this.rbfTaxType,
    this.rbfTaxTypeCd,
  });

  bool get isContinuingBusiness => bSttCd == '01';
  bool get isClosed => bSttCd == '03';
  bool get isOnHiatus => bSttCd == '02';

  String get businessStatusDescription {
    switch (bSttCd) {
      case '01':
        return '계속사업자';
      case '02':
        return '휴업자';
      case '03':
        return '폐업자';
      default:
        return bStt;
    }
  }

  factory BusinessStatus.fromJson(Map<String, dynamic> json) {
    return BusinessStatus(
      bNo: json['b_no'] ?? '',
      bStt: json['b_stt'] ?? '',
      bSttCd: json['b_stt_cd'] ?? '',
      taxType: json['tax_type'] ?? '',
      taxTypeCd: json['tax_type_cd'] ?? '',
      endDt: json['end_dt'],
      utccYn: json['utcc_yn'],
      taxTypeChangeDt: json['tax_type_change_dt'],
      invoiceApplyDt: json['invoice_apply_dt'],
      rbfTaxType: json['rbf_tax_type'],
      rbfTaxTypeCd: json['rbf_tax_type_cd'],
    );
  }
}

class BusinessVerificationError {
  final String statusCode;
  final String? message;

  BusinessVerificationError({
    required this.statusCode,
    this.message,
  });

  factory BusinessVerificationError.fromJson(Map<String, dynamic> json) {
    return BusinessVerificationError(
      statusCode: json['status_code'] ?? 'UNKNOWN_ERROR',
      message: json['message'],
    );
  }

  String get errorMessage {
    switch (statusCode) {
      case 'BAD_JSON_REQUEST':
        return 'JSON 형식이 올바르지 않습니다';
      case 'REQUEST_DATA_MALFORMED':
        return '필수 파라미터가 누락되었습니다';
      case 'TOO_LARGE_REQUEST':
        return '요청 데이터가 너무 큽니다 (최대 100개)';
      case 'INTERNAL_ERROR':
        return '서버 내부 오류가 발생했습니다';
      case 'HTTP_ERROR':
        return 'HTTP 오류가 발생했습니다';
      default:
        return message ?? '알 수 없는 오류가 발생했습니다';
    }
  }
}