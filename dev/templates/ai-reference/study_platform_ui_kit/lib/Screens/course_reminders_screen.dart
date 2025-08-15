import 'package:flutter/material.dart';

class CourseRemindersScreen extends StatefulWidget {
  const CourseRemindersScreen({super.key});

  @override
  State<CourseRemindersScreen> createState() => _CourseRemindersScreenState();
}

class _CourseRemindersScreenState extends State<CourseRemindersScreen> {
  // Currently selected day index, corresponds to the data below.
  // 0 = Monday, 3 Feb; 1 = Tuesday, 4 Feb, etc.
  int _selectedDayIndex = 0;

  // Sample data for the date selector and reminders
  final List<Map<String, dynamic>> _weekDays = [
    {'dayNum': 3, 'dayName': 'Mon', 'fullDate': 'Monday, 3 Feb 2025'},
    {'dayNum': 4, 'dayName': 'Tue', 'fullDate': 'Tuesday, 4 Feb 2025'},
    {'dayNum': 5, 'dayName': 'Wed', 'fullDate': 'Wednesday, 5 Feb 2025'},
    {'dayNum': 6, 'dayName': 'Thu', 'fullDate': 'Thursday, 6 Feb 2025'},
    {'dayNum': 7, 'dayName': 'Fri', 'fullDate': 'Friday, 7 Feb 2025'},
    {'dayNum': 8, 'dayName': 'Sat', 'fullDate': 'Saturday, 8 Feb 2025'},
    {'dayNum': 9, 'dayName': 'Sun', 'fullDate': 'Sunday, 9 Feb 2025'},
  ];

  final List<Map<String, String>> _todayReminders = [
    {
      'time': '08.00 AM',
      'title': 'Role-Playing Activity',
      'description': 'Create simple dialogues using target vocabulary.',
    },
    {
      'time': '08.40 AM',
      'title': 'Group Discussion',
      'description': 'Begin your day with essential language basics',
    },
    {
      'time': '09.10 AM',
      'title': 'Q&A and Wrap-Up',
      'description': 'Give students time to ask questions and clarify doubts.',
    },
    {
      'time': '10.00 AM',
      'title': 'Break',
      'description': 'Short break before the next session.',
    },
    {
      'time': '10.30 AM',
      'title': 'Vocabulary Building',
      'description': 'Learn new words and phrases through interactive games.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background as per image
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent, // Transparent to match image
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white, // White background for the icon container
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, // White background for the icon container
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                // Handle add new reminder
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24), // Spacing from app bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weekDays[_selectedDayIndex]['fullDate']!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: primaryColor, // Primary color for the date
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Today\'s Reminder',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Date Selector Row
          SizedBox(
            height: 80, // Height to accommodate number and text
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: _weekDays.length,
              itemBuilder: (context, index) {
                final dayData = _weekDays[index];
                final isSelected = index == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    width: 55, // Fixed width for each day cell
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${dayData['dayNum']}',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          dayData['dayName']!,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Today's Reminders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: _todayReminders.length,
              itemBuilder: (context, index) {
                final reminder = _todayReminders[index];
                return _buildReminderItem(
                  context,
                  reminder['time']!,
                  reminder['title']!,
                  reminder['description']!,
                  primaryColor,
                  textTheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    String time,
    String title,
    String description,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80, // Fixed width for time column
            child: Text(
              time,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4, // Width of the green vertical line
                    height: 50, // Height of the green vertical line
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(
                        2,
                      ), // Rounded caps for the line
                    ),
                    margin: const EdgeInsets.only(right: 12.0),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
