import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 20,
        ),
        title: Text(
          'Review',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Rating Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4.4',
                          style: textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on 532 review',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingBar(
                            1,
                            0.1,
                            primaryColor,
                          ), // 10% for 1 star
                          _buildRatingBar(
                            2,
                            0.2,
                            primaryColor,
                          ), // 20% for 2 stars
                          _buildRatingBar(
                            3,
                            0.3,
                            primaryColor,
                          ), // 30% for 3 stars
                          _buildRatingBar(
                            4,
                            0.7,
                            primaryColor,
                          ), // 70% for 4 stars
                          _buildRatingBar(
                            5,
                            0.9,
                            primaryColor,
                          ), // 90% for 5 stars
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Individual Reviews List
                ListView.builder(
                  shrinkWrap:
                      true, // Important for nested ListView in SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for this inner list
                  itemCount: _sampleReviews.length,
                  itemBuilder: (context, index) {
                    final review = _sampleReviews[index];
                    return _buildReviewItem(
                      context,
                      review['rating']!,
                      review['date']!,
                      review['text']!,
                      review['author']!,
                      textTheme,
                    );
                  },
                ),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
          // Floating Action Button
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showGiveAReviewBottomSheet(context);
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Write a Review',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ), // Rounded capsule shape
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
    int starCount,
    double fillPercentage,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$starCount',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: fillPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    double rating,
    String date,
    String text,
    String author,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: () {},
                constraints: const BoxConstraints(), // Removes default padding
                padding: EdgeInsets.zero, // Removes default padding
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              color: Colors.black,
              height: 1.5,
            ),
            maxLines: 4, // Limit lines for review text
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            author,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showGiveAReviewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return _GiveAReviewBottomSheet();
      },
    );
  }

  // Sample data for reviews
  final List<Map<String, dynamic>> _sampleReviews = [
    {
      'rating': 4.4,
      'date': '27/06/2022',
      'text':
          'Lorem ipsum dolor sit amet, adipiscing elit. Sed at gravida nulla tempor, neque. Duis quam ut netus donec enim vitae ac diam.',
      'author': 'Carter Botosh',
    },
    {
      'rating': 4.2,
      'date': '23/06/2022',
      'text':
          'Lorem ipsum dolor sit amet, adipiscing elit. Sed at gravida nulla tempor, neque. Duis quam ut netus donec enim vitae ac diam.',
      'author': 'Jaxson Septimus',
    },
    {
      'rating': 4.1,
      'date': '22/06/2022',
      'text':
          'Lorem ipsum dolor sit amet, adipiscing elit. Sed at gravida nulla tempor, neque. Duis quam ut netus donec enim vitae ac diam.',
      'author': 'Carla Press',
    },
    {
      'rating': 4.4,
      'date': '20/06/2022',
      'text':
          'Lorem ipsum dolor sit amet, adipiscing elit. Sed at gravida nulla tempor, neque. Duis quam ut netus donec enim vitae ac diam.',
      'author': 'Alex Johnson',
    },
    {
      'rating': 3.9,
      'date': '18/06/2022',
      'text':
          'This course was insightful and well-structured. I learned a lot!',
      'author': 'Maria Garcia',
    },
  ];
}

class _GiveAReviewBottomSheet extends StatefulWidget {
  const _GiveAReviewBottomSheet();

  @override
  State<_GiveAReviewBottomSheet> createState() =>
      __GiveAReviewBottomSheetState();
}

class __GiveAReviewBottomSheetState extends State<_GiveAReviewBottomSheet> {
  int _selectedStars = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _sendReview() {
    if (_selectedStars > 0 && _reviewController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context); // Close the bottom sheet
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select stars and write your review.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            24.0, // Adjust for keyboard
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                'Give a Review',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance the close button
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedStars ? Icons.star : Icons.star_border,
                    color: Colors.amber, // Amber color for stars
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedStars = index + 1;
                    });
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Detail Review',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Lorem ipsum dolor sit amet, adipiscing elit. Sed at gravida nulla tempor, neque. Duis quam ut netus donec enim vitae ac diam.',
              hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendReview,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Send Review',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
