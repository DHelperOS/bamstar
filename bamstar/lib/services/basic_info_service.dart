import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import 'cloudinary.dart';

class BasicInfo {
  final String? realName;
  final int? age;
  final String? gender;
  final String? contactPhone;
  final String? socialService;
  final String? socialHandle;
  final String? bio;
  final List<String> profileImageUrls;

  BasicInfo({
    this.realName,
    this.age,
    this.gender,
    this.contactPhone,
    this.socialService,
    this.socialHandle,
    this.bio,
    this.profileImageUrls = const [],
  });

  factory BasicInfo.fromMap(Map<String, dynamic> map) {
    // Parse social_links JSONB
    Map<String, dynamic> socialLinks = {};
    if (map['social_links'] != null) {
      if (map['social_links'] is String) {
        socialLinks = json.decode(map['social_links'] as String);
      } else {
        socialLinks = map['social_links'] as Map<String, dynamic>;
      }
    }

    return BasicInfo(
      realName: map['real_name'] as String?,
      age: map['age'] as int?,
      gender: _parseGender(map['gender']),
      contactPhone: map['contact_phone'] as String?,
      socialService: socialLinks['service'] as String?,
      socialHandle: socialLinks['handle'] as String?,
      bio: map['bio'] as String?,
      profileImageUrls: List<String>.from(map['profile_image_urls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    // Build social_links JSONB
    Map<String, dynamic>? socialLinks;
    if (socialService != null && socialService!.isNotEmpty) {
      socialLinks = {
        'service': socialService,
        'handle': socialHandle ?? '',
      };
    }

    return {
      'real_name': realName,
      'age': age,
      'gender': _parseGenderToEnum(gender),
      'contact_phone': contactPhone,
      'social_links': socialLinks != null ? json.encode(socialLinks) : null,
      'bio': bio,
      'profile_image_urls': profileImageUrls,
    };
  }

  static String? _parseGender(dynamic gender) {
    if (gender == null) return null;
    switch (gender.toString().toUpperCase()) {
      case 'MALE':
        return '남';
      case 'FEMALE':
        return '여';
      case 'OTHER':
        return '기타';
      default:
        return gender.toString();
    }
  }

  static String? _parseGenderToEnum(String? gender) {
    if (gender == null) return null;
    switch (gender) {
      case '남':
        return 'MALE';
      case '여':
        return 'FEMALE';
      case '기타':
        return 'OTHER';
      default:
        return null;
    }
  }
}

class BasicInfoService {
  BasicInfoService._private();
  static final BasicInfoService instance = BasicInfoService._private();

  /// Get current user's basic info from member_profiles table
  Future<BasicInfo?> loadBasicInfo() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[BasicInfoService] No authenticated user');
        return null;
      }

      final response = await client
          .from('member_profiles')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('[BasicInfoService] No profile found for user: $userId');
        return null;
      }

      final basicInfo = BasicInfo.fromMap(response);
      debugPrint('[BasicInfoService] Loaded basic info for user: $userId');
      return basicInfo;
    } catch (e) {
      debugPrint('[BasicInfoService] Error loading basic info: $e');
      return null;
    }
  }

  /// Save or update user's basic info to member_profiles table
  Future<bool> saveBasicInfo(BasicInfo basicInfo, List<Uint8List> photoBytes) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[BasicInfoService] No authenticated user');
        return false;
      }

      // Upload photos if provided
      List<String> uploadedUrls = [];
      if (photoBytes.isNotEmpty) {
        uploadedUrls = await _uploadPhotos(photoBytes, userId);
      }

      // Prepare data for upsert
      final data = basicInfo.toMap();
      data['user_id'] = userId;
      
      // Add uploaded photo URLs if any - this must come AFTER toMap()
      // to avoid being overwritten by the empty profileImageUrls from BasicInfo
      if (uploadedUrls.isNotEmpty) {
        data['profile_image_urls'] = uploadedUrls;
      }

      // Remove null values to avoid overwriting existing data with null
      data.removeWhere((key, value) => value == null);

      // Upsert to member_profiles table
      await client
          .from('member_profiles')
          .upsert(data);

      debugPrint('[BasicInfoService] Successfully saved basic info for user: $userId');
      debugPrint('[BasicInfoService] Uploaded URLs: $uploadedUrls');
      return true;
    } catch (e) {
      debugPrint('[BasicInfoService] Error saving basic info: $e');
      return false;
    }
  }
  /// Upload photo bytes to Cloudinary and return URLs
  Future<List<String>> _uploadPhotos(List<Uint8List> photoBytes, String userId) async {
    final List<String> urls = [];
    
    try {
      // Get Cloudinary service instance
      final cloudinary = CloudinaryService.instanceOrNull;
      if (cloudinary == null) {
        debugPrint('[BasicInfoService] Cloudinary not configured, skipping photo upload');
        return urls;
      }
      
      for (int i = 0; i < photoBytes.length; i++) {
        final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        try {
          // Upload to Cloudinary with progress tracking
          final url = await cloudinary.uploadImageFromBytes(
            photoBytes[i],
            fileName: fileName,
            folder: 'profiles/$userId', // Organize photos by user
            context: {
              'user_id': userId,
              'type': 'profile',
              'index': i.toString(),
            },
            onProgress: (progress) {
              debugPrint('[BasicInfoService] Uploading $fileName: ${(progress * 100).toStringAsFixed(0)}%');
            },
          );
          
          urls.add(url);
          debugPrint('[BasicInfoService] Successfully uploaded photo: $fileName → $url');
          
        } catch (e) {
          debugPrint('[BasicInfoService] Error uploading individual photo $fileName: $e');
          // Continue with other photos even if one fails
          if (e is UnsafeImageException) {
            debugPrint('[BasicInfoService] Unsafe image detected: ${e.reason}');
            // Could throw or show user-friendly error message
          }
        }
      }
    } catch (e) {
      debugPrint('[BasicInfoService] Error uploading photos: $e');
      // Continue with empty URLs - don't fail the entire save process
    }
    
    return urls;
  }

  /// Check if user has completed basic info setup
  Future<bool> hasBasicInfo() async {
    final basicInfo = await loadBasicInfo();
    return basicInfo != null && basicInfo.realName != null;
  }

}