import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).primaryColor; // Get primary color from theme

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allows the body to extend behind the app bar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white, // White color for icons on dark background
        ),
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
      ),
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/800/1200?random=101', // Large placeholder image for full screen
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
            ),
          ),
          // Local video preview (smaller window)
          Positioned(
            bottom: 180, // Position above action buttons
            right: 20,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Rounded corners for local video
                  child: Image.network(
                    'https://picsum.photos/200/200?random=102', // Placeholder for local video
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 120,
                          height: 160,
                          color: Colors.grey[600],
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                  ),
                ),
                // Camera switch icon
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.5,
                      ), // Semi-transparent black background
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.switch_camera_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Action Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 50.0,
              ), // Padding from the bottom as seen in image
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                children: [
                  _CallActionButton(
                    backgroundColor: primaryColor, // Use primaryColor
                    icon: Icons.close, // Close icon for hang up
                    onPressed: () {},
                    iconColor: Colors.white, // Ensure white icon for contrast
                  ),
                  _CallActionButton(
                    backgroundColor: primaryColor, // Use primaryColor
                    icon: Icons.videocam, // Video camera icon
                    onPressed: () {},
                    iconColor: Colors.white, // Ensure white icon for contrast
                  ),
                  _CallActionButton(
                    backgroundColor: primaryColor, // Use primaryColor
                    icon: Icons.volume_up, // Volume icon
                    onPressed: () {},
                    iconColor: Colors.white, // Ensure white icon for contrast
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the circular action buttons
class _CallActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  const _CallActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
    this.iconColor =
        Colors.white, // Default to white, explicitly set for clarity
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 2.0, // Slight shadow as seen in image
      fillColor: backgroundColor,
      padding: const EdgeInsets.all(18.0), // Adjust padding for button size
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: 30.0, // Icon size matching the image
        color: iconColor,
      ),
    );
  }
}
