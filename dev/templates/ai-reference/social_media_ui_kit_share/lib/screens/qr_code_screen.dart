import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color primaryColorLight = primaryColor.withValues(
      alpha: 0.8,
    ); // A slightly lighter shade for gradient

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allow body to extend behind app bar for gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColorLight,
            ], // Gradient from primaryColor
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor:
                  Colors.transparent, // Transparent AppBar to show gradient
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back), // Back arrow
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.white, // White icons on colored background
              ),
              title: Text(
                'QR Code',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white, // White title
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.send_outlined), // Share icon
                  onPressed: () {},
                  color: Colors.white, // White icon
                ),
                const SizedBox(width: 8),
              ],
              centerTitle: false,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QR Code Display Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Rounded corners for QR code image
                          child: Image.network(
                            'https://picsum.photos/300/300?grayscale', // Placeholder resembling a QR code
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 250,
                                  height: 250,
                                  color:
                                      Colors
                                          .black, // Fallback to black for QR effect
                                  child: Center(
                                    child: Text(
                                      'QR Code Placeholder',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '@john_doe', // Username
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50), // Space above the button
                ],
              ),
            ),
            // Scan QR Code Button (bottom aligned)
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 40.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // White background
                    foregroundColor:
                        primaryColor, // Primary color for text and icon
                    side: BorderSide(
                      color: primaryColor,
                    ), // Primary color border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        25,
                      ), // Fully rounded button
                    ),
                  ),
                  icon: Icon(
                    Icons.qr_code_scanner,
                    size: 24,
                    color: primaryColor,
                  ), // Scanner icon
                  label: Text(
                    'Scan QR Code',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
