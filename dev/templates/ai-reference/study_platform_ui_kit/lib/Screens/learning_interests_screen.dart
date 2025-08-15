import 'package:canwa/Screens/home_screen.dart';
import 'package:canwa/Widgets/primary_text_button.dart';
import 'package:flutter/material.dart';

class LearningInterestsScreen extends StatefulWidget {
  const LearningInterestsScreen({super.key});

  @override
  State<LearningInterestsScreen> createState() =>
      _LearningInterestsScreenState();
}

class _LearningInterestsScreenState extends State<LearningInterestsScreen> {
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Science', 'icon': Icons.public, 'isSelected': false},
    {'name': 'Art', 'icon': Icons.palette, 'isSelected': false},
    {'name': 'Gym', 'icon': Icons.fitness_center, 'isSelected': false},
    {'name': 'Design', 'icon': Icons.design_services, 'isSelected': false},
    {'name': 'Business', 'icon': Icons.business_center, 'isSelected': false},
    {'name': 'Psychology', 'icon': Icons.psychology, 'isSelected': false},
    {
      'name': '3D Design',
      'icon': Icons.ac_unit,
      'isSelected': false,
    }, // Placeholder icon
    {'name': 'Music', 'icon': Icons.music_note, 'isSelected': false},
    {'name': 'Trading', 'icon': Icons.trending_up, 'isSelected': false},
    {'name': 'Pharmacist', 'icon': Icons.medication, 'isSelected': false},
    {'name': 'Programming', 'icon': Icons.laptop_mac, 'isSelected': false},
    {
      'name': 'Lifestyle',
      'icon': Icons.wine_bar,
      'isSelected': false,
    }, // Placeholder icon
    {'name': 'Photography', 'icon': Icons.camera_alt, 'isSelected': false},
  ];

  void _toggleInterest(int index) {
    setState(() {
      _interests[index]['isSelected'] = !_interests[index]['isSelected'];
    });
  }

  void _onDonePressed() {
    List<String> selectedInterests =
        _interests
            .where((interest) => interest['isSelected'])
            .map((interest) => interest['name'] as String)
            .toList();

    if (selectedInterests.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose two or more interests.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Interests selected: ${selectedInterests.join(', ')}'),
          duration: const Duration(seconds: 3),
        ),
      );
      // Navigate to the next screen (e.g., home screen)
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // No back button
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you learning in?',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose two or more.',
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            Center(
              // Wrapped with Center widget to align the Wrap
              child: Wrap(
                spacing: 12.0, // horizontal space between chips
                runSpacing: 12.0, // vertical space between lines of chips
                children: List.generate(_interests.length, (index) {
                  return InterestChip(
                    name: _interests[index]['name'],
                    icon: _interests[index]['icon'],
                    isSelected: _interests[index]['isSelected'],
                    onTap: () => _toggleInterest(index),
                  );
                }),
              ),
            ),
            const Spacer(), // Pushes content to the top and button to the bottom
            PrimaryTextButton(
              text: 'Done',
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => MainScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InterestChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestChip({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Colors.white
                      : Colors.black, // Changed icon color
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: textTheme.bodyLarge?.copyWith(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
