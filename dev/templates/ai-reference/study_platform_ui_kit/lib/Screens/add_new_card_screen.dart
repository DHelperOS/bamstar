import 'package:canwa/Widgets/auth_fields.dart';
import 'package:canwa/Widgets/primary_text_button.dart';
import 'package:flutter/material.dart';

class AddNewCardScreen extends StatefulWidget {
  const AddNewCardScreen({super.key});

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _expiredController = TextEditingController();
  final TextEditingController _cvvCodeController = TextEditingController();

  String _displayCardNumber =
      '2894 - 4389 - 4432 - 9432'; // Initial placeholder from image
  String _displayCardHolderName =
      'Natalie Vernandez'; // Initial placeholder from image

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_updateCardNumber);
    _cardHolderNameController.addListener(_updateCardHolderName);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_updateCardNumber);
    _cardHolderNameController.removeListener(_updateCardHolderName);
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiredController.dispose();
    _cvvCodeController.dispose();
    super.dispose();
  }

  void _updateCardNumber() {
    setState(() {
      String rawNumber = _cardNumberController.text.replaceAll(' ', '');
      if (rawNumber.length > 16) {
        rawNumber = rawNumber.substring(0, 16);
      }
      _displayCardNumber = _formatCardNumber(rawNumber);
    });
  }

  String _formatCardNumber(String number) {
    String formatted = '';
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' - ';
      }
      formatted += number[i];
    }
    return formatted.isEmpty ? '•••• - •••• - •••• - ••••' : formatted;
  }

  void _updateCardHolderName() {
    setState(() {
      _displayCardHolderName =
          _cardHolderNameController.text.isEmpty
              ? 'Holder Name'
              : _cardHolderNameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Add New Card',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Preview Widget
            _buildCardPreview(context, textTheme),
            const SizedBox(
              height: 32,
            ), // Increased spacing for visual separation
            // Card Number Input
            const SizedBox(height: 8),
            AuthTextfields().buildTextField(
              controller: TextEditingController(),
              labelText: "Enter Card Number",
            ),
            const SizedBox(height: 20),

            // Card Holder Name Input
            AuthTextfields().buildTextField(
              controller: TextEditingController(),
              labelText: "Enter Holder Name",
            ),
            const SizedBox(height: 20),

            // Expired and CVV Code
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthTextfields().buildTextField(
                        controller: TextEditingController(),
                        labelText: "MM/YY",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthTextfields().buildTextField(
                        controller: TextEditingController(),
                        labelText: "CVV",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Spacer(), // Pushes the button to the bottom
            // Add Card Button
            PrimaryTextButton(text: "Add Card"),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context, TextTheme textTheme) {
    final primaryColor =
        Theme.of(context).primaryColor; // Get primary color from theme
    return Container(
      width: double.infinity,
      height: 200, // Fixed height for the card
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor, // Use primary color as the base
            primaryColor.withValues(
              alpha: 0.7,
            ), // A lighter shade of primary color for the gradient
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  4.0,
                ), // Slight rounding for logo
                child: Image.network(
                  'https://picsum.photos/id/406/40/25', // Placeholder for Maestro/Generic Card Logo
                  color: Colors.white, // Tint logo white if needed
                  colorBlendMode: BlendMode.srcIn,
                  height: 25,
                  width: 40,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Maestro Kard', // Card type
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(), // Pushes content towards bottom
          Text(
            _displayCardNumber,
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Holder Name',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            _displayCardHolderName,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
