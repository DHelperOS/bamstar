import 'package:canwa/Widgets/primary_text_button.dart';
import 'package:flutter/material.dart';
import 'package:canwa/Screens/add_new_card_screen.dart'; // Import the new screen

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // Sample data for payment methods
  final List<Map<String, String>> _paymentMethods = [
    {
      'name': 'Mastercard',
      'logo':
          'https://picsum.photos/id/1084/60/40', // Placeholder for Mastercard
      'details': 'Master Card ****2',
    },
    {
      'name': 'Gopay',
      'logo': 'https://picsum.photos/id/403/60/40', // Placeholder for Gopay
      'details': 'Master Card ****2',
    },
    {
      'name': 'Qris',
      'logo': 'https://picsum.photos/id/402/60/40', // Placeholder for Qris
      'details': 'Master Card ****2',
    },
    {
      'name': 'Shopee Pay',
      'logo':
          'https://picsum.photos/id/401/60/40', // Placeholder for Shopee Pay
      'details': 'Master Card ****2',
    },
    {
      'name': 'Visa',
      'logo': 'https://picsum.photos/id/405/60/40', // Placeholder for Visa
      'details': 'Master Card ****2',
    },
  ];

  void _addPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewCardScreen()),
    );
  }

  void _editPaymentMethod(String methodName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing $methodName (logic not implemented).'),
        duration: const Duration(seconds: 2),
      ),
    );
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
          'Payment Method',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),

            child: IconButton(
              icon: Icon(Icons.add, color: primaryColor, size: 20), // Plus icon
              onPressed: _addPaymentMethod,
              iconSize: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return _buildPaymentMethodTile(
                  context,
                  method['name']!,
                  method['logo']!,
                  method['details']!,
                  textTheme,
                  () => _editPaymentMethod(method['name']!),
                );
              },
              separatorBuilder:
                  (context, index) => const Divider(
                    height: 24, // Space between items
                    thickness: 1,
                    color:
                        Colors
                            .transparent, // Invisible divider for spacing, or can be a very light grey
                  ),
            ),
          ),
          // Confirmation Button at the bottom
          PrimaryTextButton(
            text: 'Confirmation',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => AddNewCardScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    String name,
    String logoUrl,
    String details,
    TextTheme textTheme,
    VoidCallback onEdit,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color:
                  Colors.grey[100], // Light grey background for logo container
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Image.network(
                logoUrl,
                height: 28, // Adjust logo size as per image
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  details,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Colors.grey[600],
            ), // Edit icon
            onPressed: onEdit,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
