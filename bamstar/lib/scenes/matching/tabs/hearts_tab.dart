import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bamstar/theme/app_text_styles.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/match_profile.dart';
import 'package:bamstar/utils/toast_helper.dart';

/// Hearts Tab - Manage likes received, sent, and mutual matches
class HeartsTab extends ConsumerStatefulWidget {
  final bool isMemberView;
  final Function(int) onUnreadCountChanged;
  
  const HeartsTab({
    super.key,
    required this.isMemberView,
    required this.onUnreadCountChanged,
  });

  @override
  ConsumerState<HeartsTab> createState() => _HeartsTabState();
}

class _HeartsTabState extends ConsumerState<HeartsTab> 
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  
  final List<MatchProfile> _receivedLikes = [];
  final List<MatchProfile> _sentLikes = [];
  final List<MatchProfile> _mutualMatches = [];
  
  bool _isLoading = true;
  int _unreadCount = 0;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHearts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHearts() async {
    // TODO: Load hearts data from Supabase
    setState(() {
      _receivedLikes.clear();
      _sentLikes.clear();
      _mutualMatches.clear();
      
      _receivedLikes.addAll(_generateMockReceivedLikes());
      _sentLikes.addAll(_generateMockSentLikes());
      _mutualMatches.addAll(_generateMockMutualMatches());
      
      _unreadCount = _receivedLikes.where((p) => p.isVerified).length;
      _isLoading = false;
    });
    
    widget.onUnreadCountChanged(_unreadCount);
  }

  List<MatchProfile> _generateMockReceivedLikes() {
    if (widget.isMemberView) {
      return [
        MatchProfile(
          id: '1',
          name: '커피스미스',
          subtitle: '청담점',
          imageUrl: null,
          matchScore: 96,
          location: '강남구 청담동',
          distance: 1.5,
          payInfo: '시급 15,000원',
          schedule: '평일 오전',
          tags: ['프리미엄카페', '바리스타교육', '즉시채용'],
          type: ProfileType.place,
          isVerified: true, // New like
        ),
        MatchProfile(
          id: '2',
          name: '드롭탑',
          subtitle: '압구정점',
          imageUrl: null,
          matchScore: 91,
          location: '강남구 압구정동',
          distance: 2.3,
          payInfo: '시급 14,000원',
          schedule: '시간협의',
          tags: ['스페셜티커피', '로스팅교육'],
          type: ProfileType.place,
          isVerified: true, // New like
        ),
        MatchProfile(
          id: '3',
          name: '더벤티',
          subtitle: '강남역점',
          imageUrl: null,
          matchScore: 85,
          location: '강남구 역삼동',
          distance: 0.8,
          payInfo: '시급 13,000원',
          schedule: '주말근무',
          tags: ['대형카페', '팀워크좋음'],
          type: ProfileType.place,
        ),
      ];
    } else {
      return [
        MatchProfile(
          id: '1',
          name: '김태현',
          subtitle: '바리스타 6년차',
          imageUrl: null,
          matchScore: 97,
          location: '강남구 거주',
          distance: 0.5,
          payInfo: '희망시급 17,000원',
          schedule: '평일 오전',
          tags: ['매니저경험', 'SCA마스터', '로스팅전문'],
          type: ProfileType.member,
          isVerified: true, // New like
        ),
        MatchProfile(
          id: '2',
          name: '이수빈',
          subtitle: '카페 경력 4년',
          imageUrl: null,
          matchScore: 92,
          location: '서초구 거주',
          distance: 1.8,
          payInfo: '희망시급 15,000원',
          schedule: '평일 가능',
          tags: ['라떼아트전문', '친절', '영어가능'],
          type: ProfileType.member,
          isVerified: true, // New like
        ),
        MatchProfile(
          id: '3',
          name: '박지우',
          subtitle: '바리스타 2년차',
          imageUrl: null,
          matchScore: 86,
          location: '송파구 거주',
          distance: 3.2,
          payInfo: '희망시급 14,000원',
          schedule: '주말가능',
          tags: ['성실', '빠른습득', '팀워크'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  List<MatchProfile> _generateMockSentLikes() {
    if (widget.isMemberView) {
      return [
        MatchProfile(
          id: '4',
          name: '아티제',
          subtitle: '삼성점',
          imageUrl: null,
          matchScore: 88,
          location: '강남구 삼성동',
          distance: 1.2,
          payInfo: '시급 13,500원',
          schedule: '평일/주말',
          tags: ['베이커리카페', '직원할인'],
          type: ProfileType.place,
        ),
        MatchProfile(
          id: '5',
          name: '카페노티드',
          subtitle: '역삼점',
          imageUrl: null,
          matchScore: 82,
          location: '강남구 역삼동',
          distance: 0.5,
          payInfo: '시급 13,000원',
          schedule: '시간협의',
          tags: ['브런치카페', '팁문화'],
          type: ProfileType.place,
        ),
      ];
    } else {
      return [
        MatchProfile(
          id: '4',
          name: '정하늘',
          subtitle: '카페 경력 3년',
          imageUrl: null,
          matchScore: 89,
          location: '강동구 거주',
          distance: 4.5,
          payInfo: '희망시급 14,500원',
          schedule: '평일 오후',
          tags: ['디저트제조', '친절', '책임감'],
          type: ProfileType.member,
        ),
        MatchProfile(
          id: '5',
          name: '최민서',
          subtitle: '신입 열정',
          imageUrl: null,
          matchScore: 77,
          location: '성동구 거주',
          distance: 2.8,
          payInfo: '희망시급 12,500원',
          schedule: '풀타임가능',
          tags: ['열정적', '장기근무희망'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  List<MatchProfile> _generateMockMutualMatches() {
    if (widget.isMemberView) {
      return [
        MatchProfile(
          id: '6',
          name: '블루보틀',
          subtitle: '성수점',
          imageUrl: null,
          matchScore: 94,
          location: '성동구 성수동',
          distance: 3.5,
          payInfo: '시급 16,000원',
          schedule: '평일 오전',
          tags: ['프리미엄', '커피교육', '매칭성공'],
          type: ProfileType.place,
          isPremium: true,
        ),
        MatchProfile(
          id: '7',
          name: '앤트러사이트',
          subtitle: '한남점',
          imageUrl: null,
          matchScore: 90,
          location: '용산구 한남동',
          distance: 4.2,
          payInfo: '시급 15,000원',
          schedule: '시간협의',
          tags: ['로스터리카페', '매칭성공'],
          type: ProfileType.place,
        ),
      ];
    } else {
      return [
        MatchProfile(
          id: '6',
          name: '강지호',
          subtitle: '바리스타 5년차',
          imageUrl: null,
          matchScore: 95,
          location: '강남구 거주',
          distance: 1.0,
          payInfo: '희망시급 16,000원',
          schedule: '즉시가능',
          tags: ['매니저경험', '로스팅', '매칭성공'],
          type: ProfileType.member,
          isPremium: true,
        ),
        MatchProfile(
          id: '7',
          name: '송예진',
          subtitle: '카페 경력 3년',
          imageUrl: null,
          matchScore: 88,
          location: '서초구 거주',
          distance: 2.5,
          payInfo: '희망시급 14,500원',
          schedule: '평일가능',
          tags: ['라떼아트', '친절', '매칭성공'],
          type: ProfileType.member,
        ),
      ];
    }
  }

  void _markAsRead() {
    setState(() {
      for (var profile in _receivedLikes) {
        profile = MatchProfile(
          id: profile.id,
          name: profile.name,
          subtitle: profile.subtitle,
          imageUrl: profile.imageUrl,
          matchScore: profile.matchScore,
          location: profile.location,
          distance: profile.distance,
          payInfo: profile.payInfo,
          schedule: profile.schedule,
          tags: profile.tags,
          type: profile.type,
          lastActive: profile.lastActive,
          isVerified: false,
          isPremium: profile.isPremium,
        );
      }
      _unreadCount = 0;
    });
    widget.onUnreadCountChanged(0);
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
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.primaryText(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTextStyles.primaryText(context),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('받은 좋아요'),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _unreadCount.toString(),
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('보낸 좋아요'),
                    const SizedBox(width: 4),
                    Text(
                      '${_sentLikes.length}',
                      style: AppTextStyles.captionText(context).copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      SolarIconsBold.hearts,
                      size: 16,
                      color: Colors.pink,
                    ),
                    const SizedBox(width: 4),
                    const Text('매칭'),
                    const SizedBox(width: 4),
                    Text(
                      '${_mutualMatches.length}',
                      style: AppTextStyles.captionText(context).copyWith(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onTap: (index) {
              if (index == 0 && _unreadCount > 0) {
                _markAsRead();
              }
            },
          ),
        ),
        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Received likes
              _buildLikesList(_receivedLikes, true),
              // Sent likes
              _buildLikesList(_sentLikes, false),
              // Mutual matches
              _buildMatchesList(_mutualMatches),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLikesList(List<MatchProfile> profiles, bool isReceived) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReceived ? SolarIconsOutline.heartBroken : SolarIconsOutline.heartAngle,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isReceived ? '아직 받은 좋아요가 없습니다' : '아직 보낸 좋아요가 없습니다',
              style: AppTextStyles.primaryText(context),
            ),
            const SizedBox(height: 8),
            Text(
              isReceived ? '프로필을 개선해보세요' : '마음에 드는 프로필에 좋아요를 보내보세요',
              style: AppTextStyles.secondaryText(context),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _HeartCard(
          profile: profile,
          isReceived: isReceived,
          onAccept: isReceived
              ? () {
                  ToastHelper.success(context, '${profile.name}와 매칭되었습니다! 💕');
                  setState(() {
                    _receivedLikes.remove(profile);
                    _mutualMatches.add(profile);
                  });
                }
              : null,
          onReject: isReceived
              ? () {
                  ToastHelper.info(context, '좋아요를 거절했습니다');
                  setState(() {
                    _receivedLikes.remove(profile);
                  });
                }
              : () {
                  ToastHelper.info(context, '좋아요를 취소했습니다');
                  setState(() {
                    _sentLikes.remove(profile);
                  });
                },
          onTap: () {
            // TODO: Navigate to profile detail
            ToastHelper.info(context, '${profile.name} 프로필 보기');
          },
        );
      },
    );
  }

  Widget _buildMatchesList(List<MatchProfile> matches) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              SolarIconsOutline.hearts,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 매칭이 없습니다',
              style: AppTextStyles.primaryText(context),
            ),
            const SizedBox(height: 8),
            Text(
              '서로 좋아요를 보내면 매칭됩니다',
              style: AppTextStyles.secondaryText(context),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final profile = matches[index];
        return _MatchCard(
          profile: profile,
          onChat: () {
            ToastHelper.info(context, '채팅 기능은 곧 오픈됩니다');
          },
          onTap: () {
            // TODO: Navigate to profile detail
            ToastHelper.info(context, '${profile.name} 프로필 보기');
          },
        );
      },
    );
  }
}

// Heart card widget for likes
class _HeartCard extends StatelessWidget {
  final MatchProfile profile;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback onTap;

  const _HeartCard({
    required this.profile,
    required this.isReceived,
    this.onAccept,
    required this.onReject,
    required this.onTap,
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
            color: profile.isVerified
                ? Colors.pink.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.1),
            width: profile.isVerified ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Profile image
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          profile.type == ProfileType.place
                              ? SolarIconsBold.shop
                              : SolarIconsBold.user,
                          size: 32,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (profile.isVerified)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
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
                            style: AppTextStyles.cardTitle(context),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(profile.matchScore).withValues(alpha: 0.1),
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
                                    color: _getScoreColor(profile.matchScore),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (profile.isVerified) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  color: colorScheme.surface,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.subtitle,
                        style: AppTextStyles.secondaryText(context),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Action buttons
            if (isReceived && onAccept != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '거절',
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            SolarIconsBold.heart,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '수락',
                            style: AppTextStyles.buttonText(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.red;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return Colors.blue;
    return Colors.grey;
  }
}

// Match card widget for mutual matches
class _MatchCard extends StatelessWidget {
  final MatchProfile profile;
  final VoidCallback onChat;
  final VoidCallback onTap;

  const _MatchCard({
    required this.profile,
    required this.onChat,
    required this.onTap,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.withValues(alpha: 0.05),
              Colors.purple.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.pink.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Profile image with match indicator
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      profile.type == ProfileType.place
                          ? SolarIconsBold.shop
                          : SolarIconsBold.user,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      SolarIconsBold.hearts,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
                        style: AppTextStyles.cardTitle(context),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        SolarIconsBold.verifiedCheck,
                        size: 16,
                        color: Colors.pink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '매칭 성공!',
                        style: AppTextStyles.captionText(context).copyWith(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.subtitle,
                    style: AppTextStyles.secondaryText(context),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: profile.tags.take(2).map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.captionText(context).copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Chat button
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  SolarIconsBold.chatRound,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                onPressed: onChat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}