import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/match_profile.dart';
import 'package:bamstar/utils/toast_helper.dart';

/// Map Tab - Nearby matches with visual map interface
class MapTab extends ConsumerStatefulWidget {
  final bool isMemberView;
  
  const MapTab({
    super.key,
    required this.isMemberView,
  });

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> 
    with AutomaticKeepAliveClientMixin {
  final List<MatchProfile> _nearbyProfiles = [];
  bool _isLoading = true;
  double _searchRadius = 5.0; // km
  String _selectedProfileId = '';
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadNearbyProfiles();
  }

  Future<void> _loadNearbyProfiles() async {
    // TODO: Load nearby profiles from Supabase using PostGIS
    // In production, this would use the user's actual location
    setState(() {
      _nearbyProfiles.clear();
      _nearbyProfiles.addAll(_generateMockNearbyProfiles());
      _isLoading = false;
    });
  }

  List<MatchProfile> _generateMockNearbyProfiles() {
    if (widget.isMemberView) {
      // Member sees nearby Place profiles
      return [
        MatchProfile(
          id: '1',
          name: '커피빈',
          subtitle: '강남역점',
          imageUrl: null,
          matchScore: 95,
          location: '강남구 역삼동',
          distance: 0.3,
          payInfo: '시급 14,500원',
          schedule: '평일 오전',
          tags: ['5분거리', '바리스타교육', '즉시근무가능'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '2',
          name: '할리스커피',
          subtitle: '삼성점',
          imageUrl: null,
          matchScore: 88,
          location: '강남구 삼성동',
          distance: 0.8,
          payInfo: '시급 13,500원',
          schedule: '시간협의',
          tags: ['도보10분', '친절한매니저', '팀워크좋음'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '3',
          name: '탐앤탐스',
          subtitle: '선릉점',
          imageUrl: null,
          matchScore: 82,
          location: '강남구 대치동',
          distance: 1.5,
          payInfo: '시급 13,000원',
          schedule: '주말근무',
          tags: ['지하철역근처', '식사제공'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '4',
          name: '파스쿠찌',
          subtitle: '역삼점',
          imageUrl: null,
          matchScore: 79,
          location: '강남구 역삼동',
          distance: 2.2,
          payInfo: '시급 12,500원',
          schedule: '평일/주말',
          tags: ['버스정류장앞', '유니폼제공'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '5',
          name: '엔제리너스',
          subtitle: '강남점',
          imageUrl: null,
          matchScore: 76,
          location: '서초구 서초동',
          distance: 3.1,
          payInfo: '시급 12,000원',
          schedule: '풀타임',
          tags: ['대로변위치', '초보가능'],
          type: ProfileType.place,
        ),
      ];
    } else {
      // Place sees nearby Member profiles
      return [
        MatchProfile(
          id: '1',
          name: '이준호',
          subtitle: '바리스타 4년차',
          imageUrl: null,
          matchScore: 93,
          location: '강남구 역삼동',
          distance: 0.2,
          payInfo: '희망시급 15,000원',
          schedule: '즉시 가능',
          tags: ['도보5분', 'SCA자격증', '즉시출근가능'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '2',
          name: '김서윤',
          subtitle: '카페 경력 2년',
          imageUrl: null,
          matchScore: 87,
          location: '강남구 삼성동',
          distance: 0.6,
          payInfo: '희망시급 14,000원',
          schedule: '평일 오전',
          tags: ['자전거10분', '라떼아트', '친절'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '3',
          name: '박지민',
          subtitle: '신입 열정',
          imageUrl: null,
          matchScore: 81,
          location: '서초구 서초동',
          distance: 1.8,
          payInfo: '희망시급 12,500원',
          schedule: '시간협의',
          tags: ['대중교통15분', '성실', '장기근무희망'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '4',
          name: '최수진',
          subtitle: '카페 경력 1년',
          imageUrl: null,
          matchScore: 78,
          location: '강남구 대치동',
          distance: 2.5,
          payInfo: '희망시급 13,000원',
          schedule: '주말가능',
          tags: ['버스20분', '팀워크', '빠른습득'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '5',
          name: '정민규',
          subtitle: '바리스타 3년차',
          imageUrl: null,
          matchScore: 75,
          location: '송파구 잠실동',
          distance: 4.2,
          payInfo: '희망시급 14,500원',
          schedule: '평일 오후',
          tags: ['지하철25분', '로스팅가능', '매니저경험'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  void _updateSearchRadius(double radius) {
    setState(() {
      _searchRadius = radius;
    });
    _loadNearbyProfiles(); // Reload with new radius
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
    
    return Stack(
      children: [
        // Map placeholder
        Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              // Map area
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Map background placeholder
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Grid pattern to simulate map
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 10,
                            ),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colorScheme.outline.withValues(alpha: 0.05),
                                    width: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Center user location
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary,
                                  ),
                                  child: Icon(
                                    SolarIconsBold.user,
                                    size: 14,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Profile markers
                          ..._nearbyProfiles.map((profile) {
                            final isSelected = profile.id == _selectedProfileId;
                            final angle = _nearbyProfiles.indexOf(profile) * 
                                (360 / _nearbyProfiles.length) * 
                                (3.14159 / 180);
                            final distance = 40 + (profile.distance * 20);
                            
                            return Positioned(
                              left: MediaQuery.of(context).size.width / 2 - 40 + 
                                    (distance * (angle.toString().contains('1') ? 1 : -1)),
                              top: MediaQuery.of(context).size.height / 4 - 20 + 
                                   (distance * (angle.toString().contains('2') ? 1 : -1)),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedProfileId = profile.id;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 48 : 40,
                                  height: isSelected ? 48 : 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected 
                                        ? colorScheme.primary 
                                        : colorScheme.secondaryContainer,
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline.withValues(alpha: 0.3),
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary.withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      profile.scoreEmoji,
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    // Map controls
                    Positioned(
                      top: 24,
                      right: 24,
                      child: Column(
                        children: [
                          // Current location button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                SolarIconsBold.mapPointWave,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              onPressed: () {
                                ToastHelper.info(context, '현재 위치로 이동');
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Zoom in button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                SolarIconsBold.addCircle,
                                size: 20,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () {
                                if (_searchRadius > 1) {
                                  _updateSearchRadius(_searchRadius - 1);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Zoom out button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                SolarIconsBold.minusCircle,
                                size: 20,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () {
                                if (_searchRadius < 10) {
                                  _updateSearchRadius(_searchRadius + 1);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search radius indicator
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              SolarIconsOutline.radar2,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '반경 ${_searchRadius.toInt()}km',
                              style: AppTextStyles.captionText(context).copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Profile list
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              SolarIconsBold.mapPointWave,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '내 주변',
                              style: AppTextStyles.sectionTitle(context),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_nearbyProfiles.length}개',
                                style: AppTextStyles.captionText(context).copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Nearby profiles list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _nearbyProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = _nearbyProfiles[index];
                            final isSelected = profile.id == _selectedProfileId;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedProfileId = profile.id;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withValues(alpha: 0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Distance indicator
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _getDistanceColor(profile.distance, colorScheme)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            profile.formattedDistance.replaceAll('km', '').replaceAll('m', ''),
                                            style: AppTextStyles.captionText(context).copyWith(
                                              color: _getDistanceColor(profile.distance, colorScheme),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            profile.formattedDistance.contains('km') ? 'km' : 'm',
                                            style: AppTextStyles.captionText(context).copyWith(
                                              color: _getDistanceColor(profile.distance, colorScheme),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
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
                                              Text(
                                                profile.name,
                                                style: AppTextStyles.primaryText(context).copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                profile.scoreEmoji,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                ' ${profile.matchScore}%',
                                                style: AppTextStyles.captionText(context).copyWith(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            profile.tags.first,
                                            style: AppTextStyles.secondaryText(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Action button
                                    IconButton(
                                      icon: Icon(
                                        SolarIconsOutline.heart,
                                        size: 20,
                                        color: Colors.pink,
                                      ),
                                      onPressed: () {
                                        ToastHelper.success(
                                          context,
                                          '${profile.name}에게 좋아요를 보냈습니다',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Map integration notice
        if (_nearbyProfiles.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    SolarIconsOutline.mapPointWave,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '지도 기능 준비 중',
                    style: AppTextStyles.sectionTitle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Google Maps 연동 후\n주변 매칭을 확인할 수 있습니다',
                    style: AppTextStyles.secondaryText(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getDistanceColor(double distance, ColorScheme colorScheme) {
    if (distance < 1.0) return Colors.green;
    if (distance < 3.0) return colorScheme.primary;
    if (distance < 5.0) return Colors.orange;
    return Colors.red;
  }
}