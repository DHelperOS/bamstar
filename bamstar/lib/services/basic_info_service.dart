import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Basic info data model
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

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      realName: json['real_name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      contactPhone: json['contact_phone'] as String?,
      socialService: json['social_service'] as String?,
      socialHandle: json['social_handle'] as String?,
      bio: json['bio'] as String?,
      profileImageUrls: (json['profile_image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'real_name': realName,
      'age': age,
      'gender': gender,
      'contact_phone': contactPhone,
      'social_service': socialService,
      'social_handle': socialHandle,
      'bio': bio,
      'profile_image_urls': profileImageUrls,
    };
  }
}

/// Service for managing basic info
class BasicInfoService {
  BasicInfoService._();
  static final instance = BasicInfoService._();

  final _supabase = Supabase.instance.client;

  /// Load basic info from database
  Future<BasicInfo?> loadBasicInfo() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      if (response == null) return null;

      // Parse profile images from JSON
      List<String> imageUrls = [];
      if (response['profile_images'] != null) {
        final images = response['profile_images'] as List<dynamic>;
        imageUrls = images.map((e) => e.toString()).toList();
      }

      return BasicInfo(
        realName: response['real_name'] as String?,
        age: response['age'] as int?,
        gender: response['gender'] as String?,
        contactPhone: response['contact_phone'] as String?,
        socialService: response['social_service'] as String?,
        socialHandle: response['social_handle'] as String?,
        bio: response['bio'] as String?,
        profileImageUrls: imageUrls,
      );
    } catch (e) {
      debugPrint('Error loading basic info: $e');
      return null;
    }
  }

  /// Save basic info to database
  Future<bool> saveBasicInfo(BasicInfo info, List<Uint8List> newPhotos) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Upload new photos if any
      List<String> newPhotoUrls = [];
      if (newPhotos.isNotEmpty) {
        for (int i = 0; i < newPhotos.length; i++) {
          final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final path = 'profiles/$userId/$fileName';
          
          final uploadResponse = await _supabase.storage
              .from('user-images')
              .uploadBinary(path, newPhotos[i]);

          if (uploadResponse.isNotEmpty) {
            final publicUrl = _supabase.storage
                .from('user-images')
                .getPublicUrl(path);
            newPhotoUrls.add(publicUrl);
          }
        }
      }

      // Combine existing and new photo URLs
      final allPhotoUrls = [...info.profileImageUrls, ...newPhotoUrls];

      // Update user record
      final updateData = {
        'real_name': info.realName,
        'age': info.age,
        'gender': info.gender,
        'contact_phone': info.contactPhone,
        'social_service': info.socialService,
        'social_handle': info.socialHandle,
        'bio': info.bio,
        'profile_images': allPhotoUrls,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error saving basic info: $e');
      return false;
    }
  }
}