import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/center_button_navbar.dart';
import 'package:socialPixel/components/search_field.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController(
    text: 'angelina',
  );
  int _selectedBottomNavItem = 1; // Index for 'Search' bottom nav item

  late TabController _tabController;

  // Tab labels
  final List<String> _tabs = [
    'All',
    'People',
    'Audio',
    'Hashtags',
    'Locations',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Move cursor to the end when the screen loads, mimicking the image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedBottomNavItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Dummy data for search results (users)
    final List<Map<String, dynamic>> searchResults = [
      {
        'imageUrl': 'https://picsum.photos/100/100?random=13',
        'name': 'angelinaa__',
        'profession': 'Web Designer',
        'following': false,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=14',
        'name': 'angelina_tamara',
        'profession': 'President of Sales',
        'following': true,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=15',
        'name': 'angelina_77',
        'profession': 'Web Designer',
        'following': false,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=16',
        'name': 'angelina_angie',
        'profession': 'Nursing Assistant',
        'following': true,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=17',
        'name': 'angelina_hawky',
        'profession': 'Dog Trainer',
        'following': false,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=18',
        'name': 'angelina_cooper',
        'profession': 'Medical Assistant',
        'following': false,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=19',
        'name': 'angelina_nguyen',
        'profession': 'Marketing Coordinator',
        'following': false,
      },
      {
        'imageUrl': 'https://picsum.photos/100/100?random=20',
        'name': 'angelina_lane',
        'profession': 'Web Developer',
        'following': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            100,
          ), // Height for search bar + tab bar
          child: Column(
            children: [
              // Custom Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: SearchTextField3(),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tabs:
                    _tabs.map((String tab) {
                      return Tab(text: tab);
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            _tabs.map((String tab) {
              // For now, all tabs show the same content
              // You can customize each tab's content based on the tab name
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return FollowListItem(
                    imageUrl: result['imageUrl'],
                    name: result['name'],
                    profession: result['profession'],
                    initialFollowing: result['following'],
                  );
                },
              );
            }).toList(),
      ),
      bottomNavigationBar: CenterButtonNavbar(),
    );
  }
}

// Adapted CustomSearchTextField for a simpler search bar in search results
class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onSubmitted;

  const CustomSearchTextField({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7), // Lighter grey background
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (_) {},
        style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// Reusing FollowListItem from lib/screens/follow_someone_screen.dart
class FollowListItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String profession; // Using profession for the smaller text
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
            radius: 28,
            backgroundImage: NetworkImage(widget.imageUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, // Semi-bold for names
                    fontSize: 16,
                    color: Colors.black, // Dark text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget
                      .profession, // Changed to profession to match the image's subtitle
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[600], // Lighter text for profession
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
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
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
                  backgroundColor: primaryColor, // Use primaryColor
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
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
