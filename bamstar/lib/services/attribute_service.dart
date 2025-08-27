import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Attribute {
  final int id;
  final String type;
  final String typeKor;
  final String name;
  final String? description;
  final String? iconName;
  final bool isActive;

  Attribute({
    required this.id,
    required this.type,
    required this.typeKor,
    required this.name,
    this.description,
    this.iconName,
    required this.isActive,
  });

  factory Attribute.fromMap(Map<String, dynamic> map) {
    return Attribute(
      id: map['id'] as int,
      type: map['type'] as String,
      typeKor: map['type_kor'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      iconName: map['icon_name'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'type_kor': typeKor,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'is_active': isActive,
    };
  }
}

class AttributeService {
  AttributeService._private();
  static final AttributeService instance = AttributeService._private();

  // Cache for attributes by type to avoid repeated API calls
  final Map<String, List<Attribute>> _attributeCache = {};
  final Map<String, String> _typeTitleCache = {};

  /// Get all attributes for a specific type (e.g., 'INDUSTRY', 'JOB_ROLE', etc.)
  Future<List<Attribute>> getAttributesByType(String type) async {
    // Check cache first
    if (_attributeCache.containsKey(type)) {
      return _attributeCache[type]!;
    }

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('attributes')
          .select('*')
          .eq('type', type)
          .eq('is_active', true)
          .order('id');

      final List<Attribute> attributes = (response as List)
          .map((item) => Attribute.fromMap(item as Map<String, dynamic>))
          .toList();

      // Cache the results
      _attributeCache[type] = attributes;

      // Cache the type title (type_kor) if we have attributes
      if (attributes.isNotEmpty) {
        _typeTitleCache[type] = attributes.first.typeKor;
      }

      debugPrint('[AttributeService] Fetched ${attributes.length} attributes for type: $type');
      return attributes;
    } catch (e) {
      debugPrint('[AttributeService] Error fetching attributes for type $type: $e');
      return [];
    }
  }

  /// Get the Korean title for an attribute type
  Future<String> getTypeTitle(String type) async {
    // Check cache first
    if (_typeTitleCache.containsKey(type)) {
      return _typeTitleCache[type]!;
    }

    // If not cached, fetch attributes to populate cache
    await getAttributesByType(type);
    
    return _typeTitleCache[type] ?? type;
  }

  /// Get multiple attribute types at once for better performance
  Future<Map<String, List<Attribute>>> getMultipleAttributeTypes(List<String> types) async {
    final Map<String, List<Attribute>> result = {};
    
    // Separate cached and uncached types
    final List<String> uncachedTypes = [];
    for (String type in types) {
      if (_attributeCache.containsKey(type)) {
        result[type] = _attributeCache[type]!;
      } else {
        uncachedTypes.add(type);
      }
    }

    // Fetch uncached types in batch
    if (uncachedTypes.isNotEmpty) {
      try {
        final client = Supabase.instance.client;
        final response = await client
            .from('attributes')
            .select('*')
            .inFilter('type', uncachedTypes)
            .eq('is_active', true)
            .order('type')
            .order('id');

        // Group by type
        final Map<String, List<Map<String, dynamic>>> groupedData = {};
        for (var item in response as List) {
          final map = item as Map<String, dynamic>;
          final type = map['type'] as String;
          if (!groupedData.containsKey(type)) {
            groupedData[type] = [];
          }
          groupedData[type]!.add(map);
        }

        // Convert to Attribute objects and cache
        for (String type in uncachedTypes) {
          final List<Attribute> attributes = (groupedData[type] ?? [])
              .map((item) => Attribute.fromMap(item))
              .toList();
          
          _attributeCache[type] = attributes;
          result[type] = attributes;

          // Cache type title
          if (attributes.isNotEmpty) {
            _typeTitleCache[type] = attributes.first.typeKor;
          }
        }

        debugPrint('[AttributeService] Batch fetched attributes for types: $uncachedTypes');
      } catch (e) {
        debugPrint('[AttributeService] Error batch fetching attributes: $e');
        
        // Return empty lists for failed types
        for (String type in uncachedTypes) {
          if (!result.containsKey(type)) {
            result[type] = [];
          }
        }
      }
    }

    return result;
  }

  /// Clear cache - useful for refreshing data
  void clearCache() {
    _attributeCache.clear();
    _typeTitleCache.clear();
  }

  /// Get attributes formatted for UI chips (with icons if available)
  Future<List<Map<String, dynamic>>> getAttributesForUI(String type, {Map<int, String>? iconOverrides}) async {
    final attributes = await getAttributesByType(type);
    
    return attributes.map((attr) {
      final icon = iconOverrides?[attr.id] ?? attr.iconName ?? _getDefaultIconForType(type);
      debugPrint('[AttributeService] ${attr.name}: iconName=${attr.iconName}, finalIcon=$icon');
      return {
        'id': attr.id.toString(),
        'name': attr.name,
        'icon': icon,
      };
    }).toList();
  }

  /// Get default icons for different attribute types
  String _getDefaultIconForType(String type) {
    switch (type) {
      case 'INDUSTRY':
        return '🏢';
      case 'JOB_ROLE':
        return '💼';
      case 'WELFARE':
        return '🎁';
      case 'PLACE_FEATURE':
        return '🏪';
      case 'MEMBER_STYLE':
        return '✨';
      default:
        return '📋';
    }
  }

  /// Preload commonly used attribute types for better performance
  Future<void> preloadCommonAttributes() async {
    const commonTypes = [
      'INDUSTRY',
      'JOB_ROLE', 
      'WELFARE',
      'PLACE_FEATURE',
      'MEMBER_STYLE',
    ];

    await getMultipleAttributeTypes(commonTypes);
    debugPrint('[AttributeService] Preloaded common attribute types');
  }
}