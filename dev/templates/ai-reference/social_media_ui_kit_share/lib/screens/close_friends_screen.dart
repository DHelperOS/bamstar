import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialPixel/components/primary_text_button.dart';
import 'package:socialPixel/components/search_field.dart';

class CloseFriendsScreen extends StatelessWidget {
  const CloseFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    final List<Map<String, dynamic>> selectedFriends = [
      {
        'name': 'anita_q',
        'profession': 'Student',
        'imageUrl': 'https://picsum.photos/100/100?random=1',
        'selected': true,
      },
      {
        'name': 'nita_webb',
        'profession': 'Student',
        'imageUrl': 'https://picsum.photos/100/100?random=2',
        'selected': true,
      },
      {
        'name': 'tia_j',
        'profession': 'Student',
        'imageUrl': 'https://picsum.photos/100/100?random=11',
        'selected': true,
      },
      {
        'name': 'julia_wilson',
        'profession': 'Web Designer',
        'imageUrl': 'https://picsum.photos/100/100?random=8',
        'selected': true,
      },
      {
        'name': 'natasha_wilana',
        'profession': 'Medical Assistant',
        'imageUrl': 'https://picsum.photos/100/100?random=9',
        'selected': true,
      },
    ];

    final List<Map<String, dynamic>> suggestedFriends = [
      {
        'name': 'sarah_hawky',
        'profession': 'Marketing Coordinator',
        'imageUrl': 'https://picsum.photos/100/100?random=6',
        'selected': false,
      },
      {
        'name': 'sarah_hawky',
        'profession': 'Marketing Coordinator',
        'imageUrl': 'https://picsum.photos/100/100?random=4',
        'selected': false,
      },
      {
        'name': 'steven_patrick',
        'profession': 'Dog Trainer',
        'imageUrl': 'https://picsum.photos/100/100?random=11',
        'selected': false,
      },
      {
        'name': 'andrew_nguyen',
        'profession': 'CEO & Co-founder',
        'imageUrl': 'https://picsum.photos/100/100?random=12',
        'selected': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ), // Black arrow as per image
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Close Friends',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, // Extra-bold for title
            fontSize: 20,
            color: Colors.black, // Dark title
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SearchTextField3(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedFriends.length} Persons',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle clear all
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedFriends.length,
                    itemBuilder: (context, index) {
                      final friend = selectedFriends[index];
                      return CloseFriendListItem(
                        imageUrl: friend['imageUrl'],
                        name: friend['name'],
                        profession: friend['profession'],
                        initialSelected: friend['selected'],
                        onSelected: (bool isSelected) {
                          // Handle selection change
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suggested',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle see all
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                      child: Text(
                        'See All',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    // To allow outer SingleChildScrollView
                    shrinkWrap: true,
                    itemCount: suggestedFriends.length,
                    itemBuilder: (context, index) {
                      final friend = suggestedFriends[index];
                      return CloseFriendListItem(
                        imageUrl: friend['imageUrl'],
                        name: friend['name'],
                        profession: friend['profession'],
                        initialSelected: friend['selected'],
                        onSelected: (bool isSelected) {
                          // Handle selection change
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100), // Space for the floating button
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PrimaryTextButton(text: "Done"),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusing CustomSearchTextField from previous task
class CustomSearchTextField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const CustomSearchTextField({
    super.key,
    this.hintText = 'Search',
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF4F6F7,
        ), // Lighter grey background as per UIKit template
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// Custom widget for a single close friend list item with selection
class CloseFriendListItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String profession;
  final bool initialSelected;
  final ValueChanged<bool>? onSelected;

  const CloseFriendListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.profession,
    this.initialSelected = false,
    this.onSelected,
  });

  @override
  State<CloseFriendListItem> createState() => _CloseFriendListItemState();
}

class _CloseFriendListItemState extends State<CloseFriendListItem> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onSelected?.call(_isSelected);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, // Semi-bold for names
                      fontSize: 16,
                      color: Colors.black, // Dark text
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.profession,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600], // Lighter text for profession
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: _isSelected ? primaryColor : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                border: Border.all(
                  color: _isSelected ? primaryColor : Colors.grey,
                  width: 1.0,
                ),
              ),
              child:
                  _isSelected
                      ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 16.0,
                          color: Colors.white,
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
