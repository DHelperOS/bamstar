import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart'; // Required for TapGestureRecognizer

import 'package:socialPixel/components/auth_textfields.dart';
import 'package:socialPixel/components/primary_text_button.dart';
import 'package:socialPixel/components/social_auth_button.dart';
import 'package:socialPixel/screens/forgot_password_screen.dart'; // Assuming a forgot password screen
import 'package:socialPixel/screens/signup_screen.dart'; // Assuming a signup screen
import 'package:socialPixel/screens/feed_screen.dart'; // Placeholder for successful login navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'test@example.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    // Implement your sign-in logic here
    // For now, it navigates to the main feed screen.
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
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0, // Added this line
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
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
              'Login to your\nAccount',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 32, // Larger font size for main titles
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            AuthTextfields().buildTextField(
              controller: _emailController,
              labelText: "Email",
            ),
            const SizedBox(height: 16),
            AuthTextfields().buildPasswordField(
              controller: _passwordController,
              labelText: "Password",
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24, // Consistent size for checkbox
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
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (_, __, ___) => const ForgotPasswordScreen(),
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
                  child: Text(
                    'Forgot the password?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            PrimaryTextButton(text: "Sign In", onPressed: _handleSignIn),
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
            SocialAuthButton(
              type: ButtonType.google,
              onPressed: () {
                // Handle Google login
              },
            ),
            const SizedBox(height: 12),
            SocialAuthButton(
              type: ButtonType.apple,
              onPressed: () {
                // Handle Apple login
              },
            ),
            const SizedBox(height: 12),
            SocialAuthButton(
              type: ButtonType.facebook,
              onPressed: () {
                // Handle Facebook login
              },
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
                    const TextSpan(text: 'Don\'t have an account? '),
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, __, ___) => const SignupScreen(),
                                  transitionDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  transitionsBuilder: (
                                    _,
                                    animation,
                                    __,
                                    child,
                                  ) {
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
