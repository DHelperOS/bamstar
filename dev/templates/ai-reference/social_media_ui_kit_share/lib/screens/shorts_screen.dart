import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  int _selectedIndex = 3; // Renamed from _selectedBottomNavItem for consistency
  bool _isLiked = false;
  int _likesCount = 12267;
  bool _isPlayingVideo = true;

  // Define colors for the bottom navigation
  Color get navBarColor => Colors.black;
  Color get inactiveIconColor => Colors.grey[600]!;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here if needed
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });
  }

  void _toggleVideoPlayback() {
    setState(() {
      _isPlayingVideo = !_isPlayingVideo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    const Color heartRed = Color(0xFFFF5270);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Shorts',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen video placeholder
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/800/1200?random=1',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.grey,
                        size: 100,
                      ),
                    ),
                  ),
            ),
          ),
          // Centered Play/Pause button
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: _toggleVideoPlayback,
              child: Icon(
                _isPlayingVideo ? Icons.pause : Icons.play_circle_fill,
                size: 80,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),

          // Engagement Metrics (Right Side)
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? heartRed : Colors.white,
                        size: 32,
                      ),
                      Text(
                        _likesCount.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {},
                    ),
                    Text(
                      '9.287',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // User Info and Audio Attribution (Bottom Left)
          Positioned(
            bottom: 120,
            left: 16,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FollowListItem(
                  imageUrl: 'https://picsum.photos/100/100?random=2',
                  name: 'jenny_wirosa',
                  profession: 'Videographer',
                  initialFollowing: false,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Favorite Girl by Justin Bieber',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: navBarColor,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                0,
                Icons.home,
                'Home',
                primaryColor,
                inactiveIconColor,
              ),
              _buildNavItem(
                1,
                Icons.search,
                'Search',
                primaryColor,
                inactiveIconColor,
              ),
              _buildPlusButton(primaryColor),
              _buildNavItem(
                3,
                Icons.play_circle_outline,
                'Shorts',
                primaryColor,
                inactiveIconColor,
              ),
              _buildNavItem(
                4,
                Icons.person_outline,
                'Profile',
                primaryColor,
                inactiveIconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(20),
          splashColor: activeColor.withOpacity(0.2),
          highlightColor: activeColor.withOpacity(0.1),
          hoverColor: activeColor.withOpacity(0.08),
          radius: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlusButton(Color primaryColor) {
    final bool isSelected = _selectedIndex == 2;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onItemTapped(2),
            borderRadius: BorderRadius.circular(22),
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.2),
            hoverColor: Colors.white.withOpacity(0.1),
            radius: 50,
            child: Container(
              width: 44,
              height: 64,
              decoration: BoxDecoration(
                color:
                    isSelected ? primaryColor.withOpacity(0.8) : primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusing FollowListItem from lib/screens/follow_someone_screen.dart and search_results_screen.dart
class FollowListItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String profession;
  final bool initialFollowing;

  const FollowListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.profession,
    this.initialFollowing = false,
  });

  @override
  State<FollowListItem> createState() => _FollowListItemState();
}

class _FollowListItemState extends State<FollowListItem> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialFollowing;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.imageUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.profession,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _isFollowing
              ? OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isFollowing = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 36),
                ),
                child: Text(
                  'Following',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isFollowing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 36),
                ),
                child: Text(
                  'Follow',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
