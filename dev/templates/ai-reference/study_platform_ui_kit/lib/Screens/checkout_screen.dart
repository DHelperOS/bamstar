import 'package:canwa/Screens/payment_method_screen.dart';
import 'package:canwa/Widgets/primary_text_button.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _discountCodeController = TextEditingController();
  bool _isFavorited = false; // State for the heart icon in the course card

  @override
  void dispose() {
    _discountCodeController.dispose();
    super.dispose();
  }

  void _applyDiscount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Discount code "${_discountCodeController.text}" applied (logic not implemented).',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _changePaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Navigating to change payment method (logic not implemented).',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

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
          'Checkout',
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
            // Summary Section
            Text(
              'Summary',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildCourseSummaryCard(context, primaryColor, textTheme),
            const SizedBox(height: 24),

            // Payment Method Section
            Text(
              'Payment Method',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(context, primaryColor, textTheme),
            const SizedBox(height: 24),

            // Discount Code Section
            Text(
              'Discount Code',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildDiscountCodeInput(context, primaryColor, textTheme),
            const SizedBox(height: 24),

            // Total Summary Section
            _buildPriceRow(
              context,
              textTheme,
              'Subtotal',
              '\$200',
              Colors.black,
            ),
            const SizedBox(height: 12),
            _buildPriceRow(
              context,
              textTheme,
              'Discount',
              '-\$5.25',
              Colors.red,
            ),
            const Divider(height: 32, thickness: 1, color: Colors.grey),
            _buildPriceRow(
              context,
              textTheme,
              'Total',
              '\$194.75',
              Colors.black,
              isTotal: true,
            ),

            const Spacer(), // Pushes the button to the bottom
            // Checkout Button
            PrimaryTextButton(
              text: "Checkout Course",
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => PaymentMethodScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSummaryCard(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              'https://picsum.photos/id/600/100/80', // Placeholder course image
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Graphic Design',
                      style: textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFavorited = !_isFavorited;
                        });
                      },
                      child: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Expert Wireframing for Mobile Design',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4.9 • (12,990)',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$48', // Course price
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light grey background
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ), // Subtle border
      ),
      child: Row(
        children: [
          Image.network(
            'https://picsum.photos/id/405/60/40', // Placeholder for Visa logo
            height: 30,
            width: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visa',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '1234 ****',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: _changePaymentMethod,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Change',
              style: textTheme.bodyLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCodeInput(
    BuildContext context,
    Color primaryColor,
    TextTheme textTheme,
  ) {
    return TextField(
      controller: _discountCodeController,
      decoration: InputDecoration(
        hintText: 'UIUXNOW23', // Placeholder for discount code
        hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        prefixIcon: Icon(
          Icons.percent,
          color: Colors.grey[600],
        ), // Percent icon for discount
        suffixIcon: TextButton(
          onPressed: _applyDiscount,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // Adjust padding for button
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Apply Code',
            style: textTheme.bodyLarge?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    TextTheme textTheme,
    String label,
    String value,
    Color valueColor, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize:
                isTotal
                    ? textTheme.titleMedium?.fontSize
                    : textTheme.bodyLarge?.fontSize,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            color: valueColor,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize:
                isTotal
                    ? textTheme.titleMedium?.fontSize
                    : textTheme.bodyLarge?.fontSize,
          ),
        ),
      ],
    );
  }
}
