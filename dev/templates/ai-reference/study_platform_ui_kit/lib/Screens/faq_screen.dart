import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  // List of FAQ items, with a boolean to track their expanded state
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'Is it accessible or not by internet?',
      'answer':
          'Cannot be accessed if there is no internet. All courses here are online based and require an internet connection.',
      'isExpanded': true, // First item is expanded by default as per image
    },
    {
      'question': 'How do I buy a course?',
      'answer':
          'You can buy a course by navigating to the course details page and clicking the "Buy Course" button. Follow the prompts to complete your purchase.',
      'isExpanded': false,
    },
    {
      'question': 'Are there any free courses?',
      'answer':
          'Yes, we offer a selection of free courses to get you started. Look for courses marked "Free" in our catalog.',
      'isExpanded': false,
    },
    {
      'question': 'On what devices can the application be used?',
      'answer':
          'Our application is compatible with iOS and Android mobile devices, as well as tablets and desktop browsers.',
      'isExpanded': false,
    },
    {
      'question': 'How many mentors are available?',
      'answer':
          'We have over 500 experienced mentors across various fields ready to guide you in your learning journey.',
      'isExpanded': false,
    },
    {
      'question': 'How to refund a course',
      'answer':
          'Refunds are processed according to our refund policy. Please visit the "Help & Support" section or contact our customer service for assistance.',
      'isExpanded': false,
    },
  ];

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
          'FAQ',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 16.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Something',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
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
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                final faq = _faqItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Colors
                              .white, // White background for FAQ item container
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.05,
                          ), // Subtle shadow
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: ExpansionTile(
                        key: PageStorageKey(
                          'faq_$index',
                        ), // Important for state persistence
                        initiallyExpanded: faq['isExpanded'],
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            faq['isExpanded'] = expanded;
                          });
                        },
                        // Explicitly remove default borders/lines from ExpansionTile itself
                        shape: const Border.fromBorderSide(
                          BorderSide.none,
                        ), // No border when collapsed
                        collapsedShape: const Border.fromBorderSide(
                          BorderSide.none,
                        ), // No border when collapsed
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        title: Text(
                          faq['question'],
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Icon(
                          faq['isExpanded']
                              ? Icons.remove_circle
                              : Icons.add_circle,
                          color:
                              primaryColor, // Primary color for the add/remove icon
                          size: 28, // Adjust size as needed to match screenshot
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              0.0,
                              16.0,
                              16.0,
                            ),
                            child: Text(
                              faq['answer'],
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
