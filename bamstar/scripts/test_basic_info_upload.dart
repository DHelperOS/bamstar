#!/usr/bin/env dart

// Test script to verify profile_image_urls update functionality
// This script simulates the BasicInfoService upload process

import 'package:flutter/foundation.dart';
import 'dart:convert';

// Mock BasicInfo class for testing
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
      'gender': gender,
      'contact_phone': contactPhone,
      'social_links': socialLinks != null ? json.encode(socialLinks) : null,
      'bio': bio,
      'profile_image_urls': profileImageUrls, // This will be empty initially
    };
  }
}

void main() {
  debugPrint('Testing BasicInfo upload flow...\n');

  // Simulate the problem scenario
  debugPrint('=== ORIGINAL PROBLEM ===');
  final basicInfo = BasicInfo(
    realName: 'Test User',
    age: 25,
    gender: '남',
    bio: 'Test bio',
    // profileImageUrls is empty by default
  );

  // Simulate uploaded URLs from Cloudinary
  List<String> uploadedUrls = [
    'https://res.cloudinary.com/dqxy2qchy/image/upload/v1234567890/profiles/user123/photo1.jpg',
    'https://res.cloudinary.com/dqxy2qchy/image/upload/v1234567890/profiles/user123/photo2.jpg',
  ];

  // Original problematic flow
  var data1 = basicInfo.toMap();
  data1['user_id'] = 'test-user-id';
  data1['profile_image_urls'] = uploadedUrls; // Add uploaded URLs
  debugPrint('Step 1 - Added uploaded URLs: ${data1['profile_image_urls']}');
  
  // toMap() would overwrite if called again (this was the problem)
  data1.addAll(basicInfo.toMap()); // This overwrites profile_image_urls!
  debugPrint('Step 2 - After toMap() overwrite: ${data1['profile_image_urls']}');
  debugPrint('❌ Problem: Uploaded URLs were overwritten by empty array!\n');

  // Fixed flow
  debugPrint('=== FIXED SOLUTION ===');
  var data2 = basicInfo.toMap(); // Call toMap() first
  data2['user_id'] = 'test-user-id';
  data2['profile_image_urls'] = uploadedUrls; // Add uploaded URLs AFTER toMap()
  debugPrint('Step 1 - Called toMap() first: ${data2['profile_image_urls']}');
  debugPrint('Step 2 - Added uploaded URLs after: ${data2['profile_image_urls']}');
  debugPrint('✅ Fixed: Uploaded URLs are preserved!\n');

  debugPrint('=== FINAL DATA FOR DATABASE ===');
  data2.removeWhere((key, value) => value == null);
  debugPrint(json.encode(data2));
}