import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionPreferenceService {
  RegionPreferenceService._private();
  static final RegionPreferenceService instance = RegionPreferenceService._private();

  /// Save selected area groups to member_preferred_area_groups table
  Future<bool> savePreferredAreaGroups(List<int> areaGroupIds) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[RegionPreferenceService] No authenticated user');
        return false;
      }

      // Start transaction by first deleting existing preferences
      await client
          .from('member_preferred_area_groups')
          .delete()
          .eq('member_user_id', userId);

      // Insert new preferences if any selected
      if (areaGroupIds.isNotEmpty) {
        final insertData = areaGroupIds.map((groupId) => {
          'member_user_id': userId,
          'group_id': groupId,
        }).toList();

        await client
            .from('member_preferred_area_groups')
            .insert(insertData);
      }

      debugPrint('[RegionPreferenceService] Successfully saved ${areaGroupIds.length} area group preferences');
      return true;
    } catch (e) {
      debugPrint('[RegionPreferenceService] Error saving area group preferences: $e');
      return false;
    }
  }

  /// Load current user's preferred area groups
  Future<List<int>> loadPreferredAreaGroups() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[RegionPreferenceService] No authenticated user');
        return [];
      }

      final response = await client
          .from('member_preferred_area_groups')
          .select('group_id')
          .eq('member_user_id', userId);

      final List<int> groupIds = [];
      for (final row in response as List) {
        final groupId = row['group_id'];
        if (groupId != null) {
          groupIds.add(groupId as int);
        }
      }

      debugPrint('[RegionPreferenceService] Loaded ${groupIds.length} preferred area groups');
      return groupIds;
    } catch (e) {
      debugPrint('[RegionPreferenceService] Error loading area group preferences: $e');
      return [];
    }
  }
}