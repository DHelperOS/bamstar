import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

/// Service for managing matching conditions via Edge Function API
class MatchingConditionsService {
  MatchingConditionsService._private();
  static final MatchingConditionsService instance = MatchingConditionsService._private();

  /// Update matching conditions via Edge Function
  Future<MatchingConditionsResponse> updateMatchingConditions({
    String? bio,
    String? desiredPayType,
    int? desiredPayAmount,
    List<String>? desiredWorkingDays,
    String? experienceLevel,
    List<int>? selectedStyleAttributeIds,
    List<int>? selectedPreferenceAttributeIds,
    List<int>? selectedAreaGroupIds,
  }) async {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      
      if (session == null) {
        return MatchingConditionsResponse(
          success: false,
          error: '로그인이 필요합니다.',
        );
      }

      // Prepare request body (only include non-null values)
      final Map<String, dynamic> requestBody = {};
      
      if (bio != null) requestBody['bio'] = bio;
      if (desiredPayType != null) requestBody['desired_pay_type'] = desiredPayType;
      if (desiredPayAmount != null) requestBody['desired_pay_amount'] = desiredPayAmount;
      if (desiredWorkingDays != null) requestBody['desired_working_days'] = desiredWorkingDays;
      if (experienceLevel != null) requestBody['experience_level'] = experienceLevel;
      if (selectedStyleAttributeIds != null) requestBody['selected_style_attribute_ids'] = selectedStyleAttributeIds;
      if (selectedPreferenceAttributeIds != null) requestBody['selected_preference_attribute_ids'] = selectedPreferenceAttributeIds;
      if (selectedAreaGroupIds != null) requestBody['selected_area_group_ids'] = selectedAreaGroupIds;

      debugPrint('[MatchingConditionsService] Sending request: ${requestBody.keys.toList()}');

      // Create Dio instance
      final dio = Dio();
      
      // Make HTTP request to Edge Function
      final response = await dio.post(
        'https://tflvicpgyycvhttctcek.supabase.co/functions/v1/update-matching-conditions',
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('[MatchingConditionsService] Response status: ${response.statusCode}');
      debugPrint('[MatchingConditionsService] Response data: ${response.data}');

      // Parse response
      final Map<String, dynamic> responseData = response.data;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return MatchingConditionsResponse(
          success: true,
          message: responseData['message'] ?? '매칭 조건이 성공적으로 업데이트되었습니다.',
        );
      } else {
        return MatchingConditionsResponse(
          success: false,
          error: responseData['error'] ?? '알 수 없는 오류가 발생했습니다.',
        );
      }
    } catch (e) {
      debugPrint('[MatchingConditionsService] Error: $e');
      return MatchingConditionsResponse(
        success: false,
        error: '네트워크 오류가 발생했습니다: $e',
      );
    }
  }
}

/// Response model for matching conditions API
class MatchingConditionsResponse {
  final bool success;
  final String? message;
  final String? error;

  MatchingConditionsResponse({
    required this.success,
    this.message,
    this.error,
  });

  factory MatchingConditionsResponse.fromMap(Map<String, dynamic> map) {
    return MatchingConditionsResponse(
      success: map['success'] ?? false,
      message: map['message'],
      error: map['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'error': error,
    };
  }

  @override
  String toString() {
    return 'MatchingConditionsResponse(success: $success, message: $message, error: $error)';
  }
}