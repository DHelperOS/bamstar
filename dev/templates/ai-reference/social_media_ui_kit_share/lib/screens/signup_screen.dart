import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:socialPixel/components/auth_textfields.dart';
import 'package:socialPixel/components/primary_text_button.dart';
import 'package:socialPixel/screens/feed_screen.dart';

import 'package:socialPixel/screens/login_screen.dart'; // For TapGestureRecognizer

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    // const Color buttonPink = Color(0xFFFF5270); // Specific pink from user's image, used for Sign up button

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Create your\nAccount',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 32, // Larger font size for main titles
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            AuthTextfields().buildTextField(
              controller: TextEditingController(),
              labelText: "Email",
            ),
            const SizedBox(height: 16),
            AuthTextfields().buildPasswordField(
              controller: TextEditingController(),
              labelText: "Password",
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 24, // Consistent size for checkbox to prevent overflow
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _rememberMe = newValue ?? false;
                      });
                    },
                    activeColor:
                        primaryColor, // Use primaryColor for active checkbox
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        4,
                      ), // Slightly rounded square checkbox
                    ),
                    side: BorderSide(
                      color:
                          _rememberMe
                              ? primaryColor
                              : Colors
                                  .grey[400]!, // Grey border when unselected
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember me',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            PrimaryTextButton(
              text: "Sign Up",
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder:
                        (_, __, ___) =>
                            const MainScreen(), // Navigate to your main app screen
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'or continue with',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CircularSocialButton(
                  icon: FontAwesomeIcons.facebookF,
                  iconColor: const Color(0xFF1877F2),
                  onPressed: () {},
                ),
                _CircularSocialButton(
                  icon: FontAwesomeIcons.google,
                  iconColor: const Color(0xFFDB4437),
                  onPressed: () {},
                ),
                _CircularSocialButton(
                  icon: FontAwesomeIcons.apple,
                  iconColor: Colors.black,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: primaryColor, // Changed to primaryColor
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to LoginEntryScreen or appropriate login screen
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => LoginScreen(),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CircularSocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  const _CircularSocialButton({
    required this.icon,
    required this.onPressed,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, // Fixed width for circular button
      height: 50, // Fixed height for circular button
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.0,
        ), // Light grey border
      ),
      child: IconButton(
        icon: FaIcon(icon, size: 24, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
