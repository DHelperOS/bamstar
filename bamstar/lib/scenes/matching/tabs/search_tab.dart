import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/match_profile.dart';
import 'package:bamstar/utils/toast_helper.dart';

/// Search Tab - Advanced filtering and search functionality
class SearchTab extends ConsumerStatefulWidget {
  final bool isMemberView;
  
  const SearchTab({
    super.key,
    required this.isMemberView,
  });

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> 
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<MatchProfile> _allProfiles = [];
  List<MatchProfile> _filteredProfiles = [];
  bool _isLoading = true;
  
  // Filter states
  RangeValues _distanceRange = const RangeValues(0, 10);
  RangeValues _matchScoreRange = const RangeValues(70, 100);
  String? _selectedLocation;
  String? _selectedSchedule;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    // TODO: Load profiles from Supabase
    setState(() {
      _allProfiles.clear();
      _allProfiles.addAll(_generateMockProfiles());
      _filteredProfiles = List.from(_allProfiles);
      _isLoading = false;
    });
  }

  List<MatchProfile> _generateMockProfiles() {
    if (widget.isMemberView) {
      // Member sees Place profiles
      return [
        MatchProfile(
          id: '1',
          name: '블루보틀 커피',
          subtitle: '성수점',
          imageUrl: null,
          matchScore: 88,
          location: '성동구 성수동',
          distance: 1.2,
          payInfo: '시급 14,000원',
          schedule: '평일 오전',
          tags: ['커피교육', '직원할인', '교통비지원'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '2',
          name: '폴바셋',
          subtitle: '강남점',
          imageUrl: null,
          matchScore: 82,
          location: '강남구 역삼동',
          distance: 3.5,
          payInfo: '시급 13,500원',
          schedule: '주말 가능',
          tags: ['바리스타교육', '식사제공'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '3',
          name: '이디야커피',
          subtitle: '홍대점',
          imageUrl: null,
          matchScore: 79,
          location: '마포구 서교동',
          distance: 5.8,
          payInfo: '시급 12,500원',
          schedule: '시간협의',
          tags: ['초보가능', '유니폼제공'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '4',
          name: '메가커피',
          subtitle: '신촌점',
          imageUrl: null,
          matchScore: 75,
          location: '서대문구 신촌동',
          distance: 6.2,
          payInfo: '시급 12,000원',
          schedule: '평일/주말',
          tags: ['주차가능', '대중교통편리'],
          type: ProfileType.place,
        ),
      ];
    } else {
      // Place sees Member profiles
      return [
        MatchProfile(
          id: '1',
          name: '박지훈',
          subtitle: '바리스타 5년차',
          imageUrl: null,
          matchScore: 91,
          location: '강남구 거주',
          distance: 0.5,
          payInfo: '희망시급 16,000원',
          schedule: '평일 오전',
          tags: ['SCA자격증', '로스팅경험', '매니저경험'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '2',
          name: '김유진',
          subtitle: '카페 경력 3년',
          imageUrl: null,
          matchScore: 86,
          location: '서초구 거주',
          distance: 2.1,
          payInfo: '희망시급 14,500원',
          schedule: '평일 오후',
          tags: ['친절', '라떼아트', '영어가능'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '3',
          name: '최민재',
          subtitle: '카페 경력 1년',
          imageUrl: null,
          matchScore: 78,
          location: '송파구 거주',
          distance: 4.3,
          payInfo: '희망시급 13,000원',
          schedule: '주말 가능',
          tags: ['성실', '팀워크', '빠른습득'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '4',
          name: '정하은',
          subtitle: '신입 열정',
          imageUrl: null,
          matchScore: 72,
          location: '강동구 거주',
          distance: 7.5,
          payInfo: '희망시급 12,000원',
          schedule: '풀타임 가능',
          tags: ['열정적', '장기근무가능'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProfiles = _allProfiles.where((profile) {
        // Search text filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          if (!profile.name.toLowerCase().contains(searchLower) &&
              !profile.subtitle.toLowerCase().contains(searchLower) &&
              !profile.tags.any((tag) => tag.toLowerCase().contains(searchLower))) {
            return false;
          }
        }
        
        // Distance filter
        if (profile.distance < _distanceRange.start || 
            profile.distance > _distanceRange.end) {
          return false;
        }
        
        // Match score filter
        if (profile.matchScore < _matchScoreRange.start || 
            profile.matchScore > _matchScoreRange.end) {
          return false;
        }
        
        // Location filter
        if (_selectedLocation != null && !profile.location.contains(_selectedLocation!)) {
          return false;
        }
        
        // Schedule filter
        if (_selectedSchedule != null && !profile.schedule.contains(_selectedSchedule!)) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Sort by match score
      _filteredProfiles.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        distanceRange: _distanceRange,
        matchScoreRange: _matchScoreRange,
        selectedLocation: _selectedLocation,
        selectedSchedule: _selectedSchedule,
        onApplyFilters: (distance, matchScore, location, schedule) {
          setState(() {
            _distanceRange = distance;
            _matchScoreRange = matchScore;
            _selectedLocation = location;
            _selectedSchedule = schedule;
          });
          _applyFilters();
          Navigator.pop(context);
          ToastHelper.info(context, '필터가 적용되었습니다');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        // Search bar and filter button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.primaryText(context),
                    decoration: InputDecoration(
                      hintText: widget.isMemberView ? '매장 검색...' : '인재 검색...',
                      hintStyle: AppTextStyles.secondaryText(context),
                      prefixIcon: Icon(
                        SolarIconsOutline.magnifier,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter button
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    SolarIconsBold.filter,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Results count
        if (_filteredProfiles.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '검색 결과',
                  style: AppTextStyles.captionText(context),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_filteredProfiles.length}개',
                    style: AppTextStyles.captionText(context).copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Profile list
        Expanded(
          child: _filteredProfiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        SolarIconsOutline.magnifierBug,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '검색 결과가 없습니다',
                        style: AppTextStyles.primaryText(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '다른 조건으로 검색해보세요',
                        style: AppTextStyles.secondaryText(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = _filteredProfiles[index];
                    return _ProfileCard(
                      profile: profile,
                      onTap: () => _showProfileDetail(profile),
                      onLike: () => _sendLike(profile),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showProfileDetail(MatchProfile profile) {
    // TODO: Navigate to profile detail
    ToastHelper.info(context, '${profile.name} 프로필 보기');
  }

  void _sendLike(MatchProfile profile) {
    // TODO: Send like via Supabase
    ToastHelper.success(context, '${profile.name}에게 좋아요를 보냈습니다');
  }
}

// Profile card widget
class _ProfileCard extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  profile.type == ProfileType.place
                      ? SolarIconsBold.shop
                      : SolarIconsBold.user,
                  size: 28,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Profile info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.name,
                          style: AppTextStyles.cardTitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Match score
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.scoreEmoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${profile.matchScore}%',
                              style: AppTextStyles.captionText(context).copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.subtitle,
                    style: AppTextStyles.secondaryText(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        SolarIconsOutline.mapPoint,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.location} · ${profile.formattedDistance}',
                        style: AppTextStyles.captionText(context),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        SolarIconsOutline.wallet,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.payInfo,
                          style: AppTextStyles.captionText(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Like button
            GestureDetector(
              onTap: onLike,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SolarIconsOutline.heart,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  final RangeValues distanceRange;
  final RangeValues matchScoreRange;
  final String? selectedLocation;
  final String? selectedSchedule;
  final Function(RangeValues, RangeValues, String?, String?) onApplyFilters;

  const _FilterBottomSheet({
    required this.distanceRange,
    required this.matchScoreRange,
    required this.selectedLocation,
    required this.selectedSchedule,
    required this.onApplyFilters,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late RangeValues _distanceRange;
  late RangeValues _matchScoreRange;
  String? _selectedLocation;
  String? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    _distanceRange = widget.distanceRange;
    _matchScoreRange = widget.matchScoreRange;
    _selectedLocation = widget.selectedLocation;
    _selectedSchedule = widget.selectedSchedule;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '필터',
                      style: AppTextStyles.sectionTitle(context),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _distanceRange = const RangeValues(0, 10);
                          _matchScoreRange = const RangeValues(70, 100);
                          _selectedLocation = null;
                          _selectedSchedule = null;
                        });
                      },
                      child: Text(
                        '초기화',
                        style: AppTextStyles.primaryText(context).copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Distance filter
                    Text(
                      '거리',
                      style: AppTextStyles.formLabel(context),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _distanceRange,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      labels: RangeLabels(
                        '${_distanceRange.start.toInt()}km',
                        '${_distanceRange.end.toInt()}km',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _distanceRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Match score filter
                    Text(
                      '매칭 점수',
                      style: AppTextStyles.formLabel(context),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _matchScoreRange,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      labels: RangeLabels(
                        '${_matchScoreRange.start.toInt()}%',
                        '${_matchScoreRange.end.toInt()}%',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _matchScoreRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Location filter
                    Text(
                      '지역',
                      style: AppTextStyles.formLabel(context),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        '강남구', '서초구', '송파구', '강동구', '마포구', '서대문구', '성동구'
                      ].map((location) {
                        final isSelected = _selectedLocation == location;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocation = isSelected ? null : location;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              location,
                              style: AppTextStyles.chipLabel(context).copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Schedule filter
                    Text(
                      '근무 시간',
                      style: AppTextStyles.formLabel(context),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        '평일 오전', '평일 오후', '주말', '시간협의', '풀타임'
                      ].map((schedule) {
                        final isSelected = _selectedSchedule == schedule;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSchedule = isSelected ? null : schedule;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              schedule,
                              style: AppTextStyles.chipLabel(context).copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      _distanceRange,
                      _matchScoreRange,
                      _selectedLocation,
                      _selectedSchedule,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '필터 적용',
                    style: AppTextStyles.buttonText(context).copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}