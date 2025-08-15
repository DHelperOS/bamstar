import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  int _selectedContentTypeIndex = 0; // 'Articles' selected by default

  final List<String> _contentTypes = ['Articles', 'Guides', 'Videos'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background for the screen
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),

          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: primaryColor,
              size: 20,
            ), // Black icon
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(
          'Help & Support',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Types',
              style: textTheme.titleMedium?.copyWith(
                // Reduced font size to titleMedium
                fontWeight: FontWeight.w900, // Increased weight
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_contentTypes.length, (index) {
                return Expanded(
                  // Ensure chips take equal width
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == _contentTypes.length - 1 ? 0 : 8.0,
                    ),
                    child: _ContentTypeChip(
                      label: _contentTypes[index],
                      isSelected: index == _selectedContentTypeIndex,
                      onTap: () {
                        setState(() {
                          _selectedContentTypeIndex = index;
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Help & Support Cards
            _SupportCard(
              icon: Icons.school, // Graduation cap icon
              title: 'Get to Know SkillUp',
              description:
                  'SkillUp is an online course platform that can make it easier for you to learn various fields. You can study with experienced mentors.',
              onLearnMore: () => {},
            ),
            const SizedBox(height: 16),
            _SupportCard(
              icon: Icons.chat_bubble_outline, // Chat bubble icon
              title: 'Documentation',
              description:
                  'Our documentation can make it easier for you to access and use application.',
              onLearnMore: () => {},
            ),
            const SizedBox(height: 16), // Additional spacing at the bottom
          ],
        ),
      ),
    );
  }
}

class _ContentTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : Colors.transparent,
        foregroundColor:
            isSelected
                ? Colors.white
                : primaryColor, // Text color: white when selected
        side: BorderSide(
          color: isSelected ? Colors.transparent : primaryColor, // Border color
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        elevation: 0, // No shadow
      ),
      child: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onLearnMore;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white, // White background for the card
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Subtle shadow
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor, // Icon color matches primary theme
            size: 30, // Reduced icon size
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
            maxLines: 3, // Limit description lines
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onLearnMore,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Wrap content tightly
              children: [
                Text(
                  'Learn More',
                  style: textTheme.bodyLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: primaryColor, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
