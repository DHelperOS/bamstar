import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Changed default selection to Spanish (index 2) to match the provided screenshot
  int _selectedLanguageIndex = 2;

  final List<Map<String, String>> _languages = [
    {
      'name': 'English',
      'flag': 'https://picsum.photos/id/20/40/25',
    }, // Abstract placeholder for US flag
    {
      'name': 'Bahasa Indonesia',
      'flag': 'https://picsum.photos/id/21/40/25',
    }, // Abstract placeholder for Indonesia flag
    {
      'name': 'Spanish',
      'flag': 'https://picsum.photos/id/22/40/25',
    }, // Abstract placeholder for Spain flag
    {
      'name': 'Italian',
      'flag': 'https://picsum.photos/id/23/40/25',
    }, // Abstract placeholder for Italy flag
    {
      'name': 'French',
      'flag': 'https://picsum.photos/id/24/40/25',
    }, // Abstract placeholder for France flag
    {
      'name': 'Russian',
      'flag': 'https://picsum.photos/id/25/40/25',
    }, // Abstract placeholder for Russia flag
    {
      'name': 'Portuguese',
      'flag': 'https://picsum.photos/id/26/40/25',
    }, // Abstract placeholder for Portugal flag
    {
      'name': 'Deutsch',
      'flag': 'https://picsum.photos/id/27/40/25',
    }, // Abstract placeholder for Germany flag
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
      backgroundColor:
          Colors
              .white, // Screen background should be white/light grey as per image
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
          'Language',
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
              horizontal: 24.0,
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
            child: Container(
              // Wrap ListView with a Container to apply background color to the scrollable area
              color: Colors.grey[50], // Light grey background for the list area
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = index == _selectedLanguageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguageIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ), // Adjusted padding
                      decoration: BoxDecoration(
                        color:
                            Colors
                                .white, // Darker grey for selected, white for unselected
                        borderRadius: BorderRadius.circular(12.0),
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
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              4.0,
                            ), // Slightly rounded corners for flags
                            child: Image.network(
                              language['flag']!,
                              width: 40,
                              height: 25,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              language['name']!,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width:
                                  25, // Adjust size as needed for the square container
                              height:
                                  25, // Adjust size as needed for the square container
                              decoration: BoxDecoration(
                                color:
                                    primaryColor, // Light background for the container
                                borderRadius: BorderRadius.circular(
                                  8.0,
                                ), // Apply radius to the container
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
