// import 'package:flutter/material.dart';
// // Reusing for consistency, though we'll make a new chip type to include icons

// class MyCourseScreen extends StatefulWidget {
//   const MyCourseScreen({super.key});

//   @override
//   State<MyCourseScreen> createState() => _MyCourseScreenState();
// }

// class _MyCourseScreenState extends State<MyCourseScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedCategoryIndex =
//       1; // "Science" is selected by default as per image

//   final List<Map<String, dynamic>> _categoryChipsWithIcons = [
//     {'name': 'Programming', 'icon': Icons.laptop_mac}, // Placeholder icon
//     {'name': 'Science', 'icon': Icons.public}, // Placeholder icon
//     {'name': 'Design', 'icon': Icons.palette}, // Placeholder icon
//     {'name': 'Business', 'icon': Icons.business_center}, // Placeholder icon
//     {'name': 'Art', 'icon': Icons.brush}, // Placeholder icon
//   ];

//   final List<Map<String, dynamic>> _myCourses = [
//     {
//       'image': 'https://picsum.photos/id/1045/100/80',
//       'title': 'Complete 3D Animation Using Blender',
//       'author': 'Jane Cooper',
//       'members': 420,
//       'num_courses': 43,
//       'status': 'not_started', // or 'completed', 'in_progress'
//       'progress': 0.0,
//     },
//     {
//       'image': 'https://picsum.photos/id/237/100/80',
//       'title': 'Fitness Training : Basic Workouts & Body Building',
//       'author': 'Esther Howard',
//       'members': 100,
//       'num_courses': 16,
//       'status': 'completed',
//       'progress': 1.0, // 100%
//     },
//     {
//       'image': 'https://picsum.photos/id/1014/100/80',
//       'title': 'Advance Trading : Forex Trading/Stock Trading',
//       'author': 'Courtney Henry',
//       'members': 221,
//       'num_courses': 12,
//       'status': 'in_progress',
//       'progress': 0.52, // 52%
//     },
//     {
//       'image': 'https://picsum.photos/id/100/100/80',
//       'title': 'Introduction to Digital Photography',
//       'author': 'Emily White',
//       'members': 350,
//       'num_courses': 25,
//       'status': 'in_progress',
//       'progress': 0.70, // 70%
//     },
//   ];

//   int _selectedIndex =
//       2; // 0 for Home, 1 for Wishlist, 2 for My Course, 3 for Profile

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     // In a real app, you would navigate to different screens here.
//     // For now, it just highlights the selected tab.
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;
//     final textTheme = Theme.of(context).textTheme;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: primaryColor,
//             size: 20,
//           ), // Black icon, transparent background
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         scrolledUnderElevation: 0,
//         title: Text(
//           'My Course',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.more_vert,
//               color: Colors.black,
//             ), // Black icon, transparent background
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 16.0,
//             ),
//             child: Column(
//               children: [
//                 // Search Bar
//                 TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search Something',
//                     prefixIcon: Padding(
//                       padding: const EdgeInsets.only(
//                         left: 16.0,
//                         top: 8,
//                         bottom: 8,
//                       ),
//                       child: Icon(Icons.search, color: Colors.grey[600]),
//                     ),
//                     suffixIcon: Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: IconButton(
//                         icon: Icon(Icons.close, color: Colors.grey[600]),
//                         onPressed: () {
//                           _searchController.clear();
//                           // Perform search clear logic
//                         },
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: primaryColor),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white, // White background for the input
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 16.0,
//                       horizontal: 16.0,
//                     ),
//                   ),
//                   onChanged: (value) {
//                     // Perform search as user types
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Category Chips
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _categoryChipsWithIcons.length,
//                     itemBuilder: (context, index) {
//                       final chipData = _categoryChipsWithIcons[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 12.0),
//                         child: _CategoryChipWithIcon(
//                           name: chipData['name']!,
//                           icon: chipData['icon']!,
//                           isSelected: index == _selectedCategoryIndex,
//                           onTap: () {
//                             setState(() {
//                               _selectedCategoryIndex = index;
//                             });
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // My Course List
//           Expanded(
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24.0,
//                 vertical: 8.0,
//               ),
//               itemCount: _myCourses.length,
//               itemBuilder: (context, index) {
//                 final course = _myCourses[index];
//                 return _buildMyCourseCard(
//                   context,
//                   course,
//                   primaryColor,
//                   textTheme,
//                 );
//               },
//               separatorBuilder:
//                   (context, index) =>
//                       const SizedBox(height: 16), // Spacing between cards
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(
//               _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
//             ),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               _selectedIndex == 1 ? Icons.bookmark : Icons.bookmark_border,
//             ),
//             label: 'Wishlist',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               _selectedIndex == 2
//                   ? Icons.play_circle_fill
//                   : Icons.play_circle_outline,
//             ),
//             label: 'My Course',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               _selectedIndex == 3 ? Icons.person : Icons.person_outline,
//             ),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: primaryColor,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed, // Ensures all labels are shown
//         selectedLabelStyle: textTheme.bodySmall?.copyWith(
//           fontWeight: FontWeight.bold,
//         ),
//         unselectedLabelStyle: textTheme.bodySmall,
//       ),
//     );
//   }

//   Widget _buildMyCourseCard(
//     BuildContext context,
//     Map<String, dynamic> course,
//     Color primaryColor,
//     TextTheme textTheme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.0),
//         border: Border.all(
//           width: 0.5,
//           color: Colors.grey.withValues(alpha: 0.5),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.network(
//                   course['image']!,
//                   height: 64,
//                   width: 64,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       course['title']!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       course['author']!,
//                       style: textTheme.bodyMedium?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.people_alt,
//                           color: Colors.grey[600],
//                           size: 18,
//                         ),
//                         const SizedBox(width: 4),
//                         // Wrap with Flexible or Expanded to prevent overflow
//                         Flexible(
//                           child: Text(
//                             '${course['members']} Members',
//                             style: textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Icon(
//                           Icons.play_circle_outline,
//                           color: Colors.grey[600],
//                           size: 18,
//                         ),
//                         const SizedBox(width: 4),
//                         // Wrap with Flexible or Expanded to prevent overflow
//                         Flexible(
//                           child: Text(
//                             '${course['num_courses']} Courses',
//                             style: textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     if (course['status'] == 'not_started')
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: TextButton(
//                           onPressed: () {},
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size.zero,
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: Text(
//                             'Start Course',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       )
//                     else if (course['status'] == 'completed')
//                       Row(
//                         children: [
//                           Text(
//                             'Complete',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Spacer(),
//                           // Explicitly constrain width if overflow still occurs, or ensure enough space
//                           Text(
//                             '${(course['progress'] * 100).toInt()}%',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             // Removed softWrap: false and overflow: TextOverflow.visible, let Expanded handle it
//                           ),
//                         ],
//                       ),
//                     if (course['status'] == 'in_progress')
//                       Row(
//                         children: [
//                           Text(
//                             'Course is in progress',
//                             style: textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           const Spacer(),
//                           Text(
//                             '${(course['progress'] * 100).toInt()}%',
//                             style: textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                             // Removed softWrap: false and overflow: TextOverflow.visible
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (course['status'] == 'in_progress' ||
//               course['status'] == 'completed')
//             SliderTheme(
//               data: SliderThemeData(
//                 padding: EdgeInsets.all(8),
//                 activeTrackColor: primaryColor,
//                 inactiveTrackColor: Colors.grey[200],
//                 trackHeight: 4.0,
//                 thumbColor: primaryColor,
//                 overlayColor: Colors.transparent, // Remove overlay
//                 thumbShape: _RoundSliderThumbShape(
//                   thumbRadius: 6.0,
//                   primaryColor: primaryColor,
//                 ), // Custom thumb
//                 trackShape:
//                     const RoundedRectSliderTrackShape(), // Rounded track
//                 showValueIndicator: ShowValueIndicator.never,
//               ),
//               child: Slider(
//                 value: course['progress'],
//                 onChanged: (newValue) {
//                   // This slider is for display, so onChanged doesn't update course progress
//                 },
//                 min: 0.0,
//                 max: 1.0,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Custom thumb shape for the Slider to match the image
// class _RoundSliderThumbShape extends SliderComponentShape {
//   final double thumbRadius;
//   final Color primaryColor;

//   const _RoundSliderThumbShape({
//     required this.thumbRadius,
//     required this.primaryColor,
//   });

//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) {
//     return Size.fromRadius(thumbRadius);
//   }

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     required Animation<double> activationAnimation,
//     required Animation<double> enableAnimation,
//     required bool isDiscrete, // The slider itself, not the thumb, is discrete
//     required TextPainter labelPainter,
//     required RenderBox parentBox,
//     required Size sizeWithOverflow,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required double textScaleFactor,
//     required double value,
//   }) {
//     final Canvas canvas = context.canvas;

//     final paint =
//         Paint()
//           ..color =
//               primaryColor // Thumb color
//           ..style = PaintingStyle.fill;

//     canvas.drawCircle(center, thumbRadius, paint);
//   }
// }

// // Reusing and adapting the CategoryChip for icons
// class _CategoryChipWithIcon extends StatelessWidget {
//   final String name;
//   final IconData icon;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _CategoryChipWithIcon({
//     required this.name,
//     required this.icon,
//     this.isSelected = false,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;
//     final textTheme = Theme.of(context).textTheme;

//     final ButtonStyle style = Theme.of(
//       context,
//     ).outlinedButtonTheme.style!.copyWith(
//       backgroundColor: WidgetStateProperty.resolveWith<Color>((
//         Set<WidgetState> states,
//       ) {
//         if (isSelected) {
//           return primaryColor;
//         }
//         return Colors.white; // White background for unselected
//       }),
//       foregroundColor: WidgetStateProperty.resolveWith<Color>((
//         Set<WidgetState> states,
//       ) {
//         if (isSelected) {
//           return Colors.white;
//         }
//         return Colors.black; // Black text for unselected
//       }),
//       side: WidgetStateProperty.resolveWith<BorderSide>((
//         Set<WidgetState> states,
//       ) {
//         if (isSelected) {
//           return BorderSide(color: primaryColor, width: 1.5);
//         }
//         return BorderSide(
//           color: Colors.grey[300]!,
//           width: 1.5,
//         ); // Light grey border for unselected
//       }),
//       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
//       ),
//       padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
//         const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//       ),
//     );

//     return OutlinedButton(
//       onPressed: onTap,
//       style: style,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 18),
//           const SizedBox(width: 8),
//           Text(
//             name,
//             style: TextStyle(
//               fontSize: 14,
//               color: isSelected ? Colors.white : Colors.black,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:canwa/Screens/course_detail_screen.dart';
import 'package:flutter/material.dart';
// Reusing for consistency, though we'll make a new chip type to include icons

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex =
      1; // "Science" is selected by default as per image

  final List<Map<String, dynamic>> _categoryChipsWithIcons = [
    {'name': 'Programming', 'icon': Icons.laptop_mac}, // Placeholder icon
    {'name': 'Science', 'icon': Icons.public}, // Placeholder icon
    {'name': 'Design', 'icon': Icons.palette}, // Placeholder icon
    {'name': 'Business', 'icon': Icons.business_center}, // Placeholder icon
    {'name': 'Art', 'icon': Icons.brush}, // Placeholder icon
  ];

  final List<Map<String, dynamic>> _myCourses = [
    {
      'image': 'https://picsum.photos/id/1045/100/80',
      'title': 'Complete 3D Animation Using Blender',
      'author': 'Jane Cooper',
      'members': 420,
      'num_courses': 43,
      'status': 'not_started', // or 'completed', 'in_progress'
      'progress': 0.0,
    },
    {
      'image': 'https://picsum.photos/id/237/100/80',
      'title': 'Fitness Training : Basic Workouts & Body Building',
      'author': 'Esther Howard',
      'members': 100,
      'num_courses': 16,
      'status': 'completed',
      'progress': 1.0, // 100%
    },
    {
      'image': 'https://picsum.photos/id/1014/100/80',
      'title': 'Advance Trading : Forex Trading/Stock Trading',
      'author': 'Courtney Henry',
      'members': 221,
      'num_courses': 12,
      'status': 'in_progress',
      'progress': 0.52, // 52%
    },
    {
      'image': 'https://picsum.photos/id/100/100/80',
      'title': 'Introduction to Digital Photography',
      'author': 'Emily White',
      'members': 350,
      'num_courses': 25,
      'status': 'in_progress',
      'progress': 0.70, // 70%
    },
  ];

  int _selectedIndex =
      2; // 0 for Home, 1 for Wishlist, 2 for My Course, 3 for Profile

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different screens here.
    // For now, it just highlights the selected tab.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryColor,
            size: 20,
          ), // Black icon, transparent background
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        scrolledUnderElevation: 0,
        title: Text(
          'My Course',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ), // Black icon, transparent background
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Something',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Icon(Icons.search, color: Colors.grey[600]),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          // Perform search clear logic
                        },
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white, // White background for the input
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                  onChanged: (value) {
                    // Perform search as user types
                  },
                ),
                const SizedBox(height: 16),

                // Category Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryChipsWithIcons.length,
                    itemBuilder: (context, index) {
                      final chipData = _categoryChipsWithIcons[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _CategoryChipWithIcon(
                          name: chipData['name']!,
                          icon: chipData['icon']!,
                          isSelected: index == _selectedCategoryIndex,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // My Course List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _myCourses.length,
              itemBuilder: (context, index) {
                final course = _myCourses[index];
                return _buildMyCourseCard(
                  context,
                  course,
                  primaryColor,
                  textTheme,
                );
              },
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(height: 16), // Spacing between cards
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1 ? Icons.bookmark : Icons.bookmark_border,
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2
                  ? Icons.play_circle_fill
                  : Icons.play_circle_outline,
            ),
            label: 'My Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        selectedLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: textTheme.bodySmall,
      ),
    );
  }

  Widget _buildMyCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              width: 0.5,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => CourseDetailScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          course['image']!,
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course['author']!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                // Wrap with Flexible or Expanded to prevent overflow
                                Flexible(
                                  child: Text(
                                    '${course['members']} Members',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                // Wrap with Flexible or Expanded to prevent overflow
                                Flexible(
                                  child: Text(
                                    '${course['num_courses']} Courses',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (course['status'] == 'not_started')
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Start Course',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else if (course['status'] == 'completed')
                              Row(
                                children: [
                                  Text(
                                    'Complete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Explicitly constrain width if overflow still occurs, or ensure enough space
                                  Text(
                                    '${(course['progress'] * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // Removed softWrap: false and overflow: TextOverflow.visible, let Expanded handle it
                                  ),
                                ],
                              ),
                            if (course['status'] == 'in_progress')
                              Row(
                                children: [
                                  Text(
                                    'Course is in progress',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(course['progress'] * 100).toInt()}%',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    // Removed softWrap: false and overflow: TextOverflow.visible
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Progress Indicator (replacing the slider)
                  if (course['status'] == 'in_progress' ||
                      course['status'] == 'completed')
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: LinearProgressIndicator(
                        value: course['progress'],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 6.0,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusing and adapting the CategoryChip for icons
class _CategoryChipWithIcon extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChipWithIcon({
    required this.name,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final ButtonStyle style = Theme.of(
      context,
    ).outlinedButtonTheme.style!.copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (isSelected) {
          return primaryColor;
        }
        return Colors.white; // White background for unselected
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (isSelected) {
          return Colors.white;
        }
        return Colors.black; // Black text for unselected
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((
        Set<WidgetState> states,
      ) {
        if (isSelected) {
          return BorderSide(color: primaryColor, width: 1.5);
        }
        return BorderSide(
          color: Colors.grey[300]!,
          width: 1.5,
        ); // Light grey border for unselected
      }),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
    );

    return OutlinedButton(
      onPressed: onTap,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 18),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
