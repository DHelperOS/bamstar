import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CenterButtonNavbar extends StatefulWidget {
  final Function(int)? onItemTapped;
  final Color? primaryColor;
  final int initialIndex;

  const CenterButtonNavbar({
    Key? key,
    this.onItemTapped,
    this.primaryColor,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<CenterButtonNavbar> createState() => _CenterButtonNavbarState();
}

class _CenterButtonNavbarState extends State<CenterButtonNavbar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _handleItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Call the optional callback if provided
    if (widget.onItemTapped != null) {
      widget.onItemTapped!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        widget.primaryColor ?? Theme.of(context).primaryColor;

    // Determine nav bar background and inactive color based on screen
    final bool isShortsScreen = _selectedIndex == 3;
    final Color navBarColor = isShortsScreen ? Colors.black : Colors.white;
    final Color inactiveIconColor =
        isShortsScreen ? Colors.white : Colors.grey[700]!;

    return BottomAppBar(
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
          onTap: () => _handleItemTapped(index),
          borderRadius: BorderRadius.circular(20), // Circular border radius
          splashColor: activeColor.withValues(
            alpha: 0.2,
          ), // Custom splash color
          highlightColor: activeColor.withValues(
            alpha: 0.1,
          ), // Custom highlight color
          hoverColor: activeColor.withValues(alpha: 0.08), // Custom hover color
          radius: 50, // Splash radius for circular effect
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
            onTap: () => _handleItemTapped(2),
            borderRadius: BorderRadius.circular(22), // Circular border radius
            splashColor: Colors.white.withValues(
              alpha: 0.3,
            ), // White splash on colored background
            highlightColor: Colors.white.withValues(
              alpha: 0.2,
            ), // White highlight
            hoverColor: Colors.white.withValues(
              alpha: 0.1,
            ), // White hover effect
            radius: 50, // Splash radius matching button size
            child: Container(
              width: 44,
              height: 64,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? primaryColor.withValues(alpha: 0.8)
                        : primaryColor,
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
