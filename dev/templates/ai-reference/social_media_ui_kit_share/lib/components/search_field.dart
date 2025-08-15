// ICON FIXES ARE LEFT IN THIS WIDGET IN THE SEARCH BAR

import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller = TextEditingController();
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  SearchTextField({
    super.key,
    this.hintText = 'Search "pizza"',
    this.onTap,
    this.readOnly = false,

    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,

        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          border: InputBorder.none,
          prefixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.grey, size: 22),
          ),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.mic_none,
              size: 22,
              color: Color(0xFF6E7375),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class SearchTextField2 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const SearchTextField2({
    super.key,
    required this.controller,
    this.hintText = 'Search for your next adventure',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Icon(Icons.search, color: primaryColor),
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(Icons.location_on, color: primaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      style: textTheme.bodyLarge?.copyWith(color: Colors.grey[850]),
    );
  }
}

class SearchTextField3 extends StatefulWidget {
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final TextEditingController? controller;

  SearchTextField3({
    Key? key,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search Something',
    this.controller,
  }) : super(key: key);

  @override
  State<SearchTextField3> createState() => _SearchTextField3State();
}

class _SearchTextField3State extends State<SearchTextField3> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.grey[500]),
        hintText: widget.hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Icon(Icons.search, color: Colors.grey[500]),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: () {
              _searchController.clear();
              if (widget.onClear != null) {
                widget.onClear!();
              }
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
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        // Perform search as user types
      },
    );
  }
}
