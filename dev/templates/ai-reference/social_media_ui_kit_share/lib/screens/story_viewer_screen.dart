// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class StoryViewerScreen extends StatefulWidget {
//   const StoryViewerScreen({super.key});

//   @override
//   State<StoryViewerScreen> createState() => _StoryViewerScreenState();
// }

// class _StoryViewerScreenState extends State<StoryViewerScreen> {
//   final List<String> _stories = [
//     'https://picsum.photos/800/1200?random=1',
//     'https://picsum.photos/800/1200?random=2',
//     'https://picsum.photos/800/1200?random=3',
//     'https://picsum.photos/800/1200?random=4',
//     'https://picsum.photos/800/1200?random=5',
//   ];
//   final int _currentStoryIndex = 0;
//   // This could be controlled by a timer in a real app
//   final double _storyProgress =
//       0.5; // Example: half-way through the current story

//   final TextEditingController _messageController = TextEditingController();

//   void _sendMessage() {
//     if (_messageController.text.isNotEmpty) {
//       _messageController.clear();
//       // In a real app, send reply to backend
//     }
//   }

//   void _handleCameraTap() {
//     // Handle image selection/capture for reply
//   }

//   void _showStoryOptionsMenu(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               // Handle for the draggable sheet
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 height: 4,
//                 width: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.warning_amber_outlined,
//                   color: Colors.red,
//                 ), // Warning icon
//                 title: Text(
//                   'Report...',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 16,
//                     color: Colors.red,
//                     fontWeight: FontWeight.w500,
//                   ), // Red text for report
//                 ),
//                 onTap: () {
//                   Navigator.pop(bc); // Close the bottom sheet
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.list_alt,
//                   color: Colors.black,
//                 ), // List icon
//                 title: Text(
//                   'Copy Link',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 16,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(bc);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.send_outlined,
//                   color: Colors.black,
//                 ), // Share icon
//                 title: Text(
//                   'Share to...',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 16,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(bc);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.volume_off_outlined,
//                   color: Colors.black,
//                 ), // Mute icon
//                 title: Text(
//                   'Mute',
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 16,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.pop(bc);
//                 },
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color primaryColor = Theme.of(context).primaryColor;
//     const Color progressBackground =
//         Colors.white54; // Translucent white for unviewed progress

//     return Scaffold(
//       backgroundColor:
//           Colors.black, // Background behind story if aspect ratio differs
//       body: Stack(
//         children: [
//           // Full-screen Story Image
//           Positioned.fill(
//             child: Image.network(
//               _stories[_currentStoryIndex],
//               fit: BoxFit.cover,
//               errorBuilder:
//                   (context, error, stackTrace) => Container(
//                     color: Colors.black,
//                     child: const Center(
//                       child: Icon(
//                         Icons.broken_image,
//                         color: Colors.grey,
//                         size: 100,
//                       ),
//                     ),
//                   ),
//             ),
//           ),
//           // Top Progress Indicators
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8, // Below status bar
//             left: 8,
//             right: 8,
//             child: Row(
//               children: List.generate(_stories.length, (index) {
//                 return Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(2),
//                       child: LinearProgressIndicator(
//                         value:
//                             index < _currentStoryIndex
//                                 ? 1.0 // Completed stories
//                                 : (index == _currentStoryIndex
//                                     ? _storyProgress
//                                     : 0.0), // Current or upcoming story
//                         backgroundColor: progressBackground,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           primaryColor,
//                         ), // Primary color for progress
//                         minHeight: 3, // Height of the progress bar
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//           // User Info Overlay
//           Positioned(
//             top:
//                 MediaQuery.of(context).padding.top +
//                 28, // Below progress indicators
//             left: 20,
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(
//                     'https://picsum.photos/100/100?random=10',
//                   ), // User avatar
//                   backgroundColor: Colors.grey[300],
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Sarah Wilona', // Username
//                       style: GoogleFonts.plusJakartaSans(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       '1 hour ago', // Timestamp
//                       style: GoogleFonts.plusJakartaSans(
//                         fontSize: 13,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // More options icon
//           Positioned(
//             top:
//                 MediaQuery.of(context).padding.top + 28, // Align with user info
//             right: 12,
//             child: IconButton(
//               icon: const Icon(
//                 Icons.more_horiz,
//                 color: Colors.white,
//                 size: 28,
//               ), // Three dots icon
//               onPressed: () => _showStoryOptionsMenu(context),
//             ),
//           ),
//           // Story Reply Input Field at the Bottom
//           Positioned(
//             // bottom: MediaQuery.of(context).padding.bottom + 8, // Old positioning
//             bottom:
//                 20 +
//                 MediaQuery.of(
//                   context,
//                 ).padding.bottom, // Add explicit padding and safe area
//             left: 0, // Will be overridden by Padding below
//             right: 0, // Will be overridden by Padding below
//             child: Padding(
//               // Add padding here to constrain it within screen bounds
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: _StoryMessageInput(
//                 controller: _messageController,
//                 onSend: _sendMessage,
//                 onCameraTap: _handleCameraTap,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper widget for the message input field, adapted for story viewer
// class _StoryMessageInput extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback onSend;
//   final VoidCallback onCameraTap;

//   const _StoryMessageInput({
//     required this.controller,
//     required this.onSend,
//     required this.onCameraTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color primaryColor = Theme.of(context).primaryColor;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       color: Colors.transparent, // Transparent background to show story behind
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(
//                   alpha: 0.2,
//                 ), // Semi-transparent white background
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: Colors.white38,
//                 ), // Subtle white border
//               ),
//               child: TextField(
//                 controller: controller,
//                 style: GoogleFonts.plusJakartaSans(
//                   fontSize: 16,
//                   color: Colors.white,
//                 ), // White text
//                 decoration: InputDecoration(
//                   hintText: 'Type message...',
//                   hintStyle: GoogleFonts.plusJakartaSans(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ), // Light hint text
//                   border: InputBorder.none,
//                   suffixIcon: IconButton(
//                     icon: const Icon(
//                       Icons.camera_alt_outlined,
//                       color: Colors.white,
//                     ), // White icon
//                     onPressed: onCameraTap,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 minLines: 1,
//                 maxLines: 5,
//                 keyboardType: TextInputType.multiline,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           RawMaterialButton(
//             onPressed: onSend,
//             fillColor: primaryColor, // Primary color for send button
//             shape: const CircleBorder(),
//             padding: const EdgeInsets.all(12),
//             child: const Icon(Icons.send, color: Colors.white, size: 24),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({super.key});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  final List<String> _stories = [
    'https://picsum.photos/800/1200?random=1',
    'https://picsum.photos/800/1200?random=2',
    'https://picsum.photos/800/1200?random=3',
    'https://picsum.photos/800/1200?random=4',
    'https://picsum.photos/800/1200?random=5',
  ];

  int _currentStoryIndex = 0;
  final double _storyProgress = 0.5;
  final TextEditingController _messageController = TextEditingController();

  void _nextStory() {
    if (_currentStoryIndex < _stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _messageController.clear();
    }
  }

  void _handleCameraTap() {}

  void _showStoryOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.red,
                ),
                title: Text(
                  'Report...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(bc),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.black),
                title: Text(
                  'Copy Link',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(bc),
              ),
              ListTile(
                leading: const Icon(Icons.send_outlined, color: Colors.black),
                title: Text(
                  'Share to...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(bc),
              ),
              ListTile(
                leading: const Icon(
                  Icons.volume_off_outlined,
                  color: Colors.black,
                ),
                title: Text(
                  'Mute',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(bc),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextStory,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                _stories[_currentStoryIndex],
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 100,
                        ),
                      ),
                    ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(_stories.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value:
                              index < _currentStoryIndex
                                  ? 1.0
                                  : (index == _currentStoryIndex
                                      ? _storyProgress
                                      : 0.0),
                          backgroundColor: Colors.white54,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 28,
              left: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: const NetworkImage(
                      'https://picsum.photos/100/100?random=10',
                    ),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sarah Wilona',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '1 hour ago',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 28,
              right: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => _showStoryOptionsMenu(context),
              ),
            ),
            Positioned(
              bottom: 20 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: IgnorePointer(
                  ignoring: false,
                  child: _StoryMessageInput(
                    controller: _messageController,
                    onSend: _sendMessage,
                    onCameraTap: _handleCameraTap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCameraTap;

  const _StoryMessageInput({
    required this.controller,
    required this.onSend,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white38),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                    ),
                    onPressed: onCameraTap,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          RawMaterialButton(
            onPressed: onSend,
            fillColor: primaryColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.send, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}
