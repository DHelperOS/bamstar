import 'package:canwa/Screens/login_screen.dart';
import 'package:canwa/Screens/verification_code_screen.dart';
import 'package:canwa/Widgets/auth_fields.dart';
import 'package:canwa/Widgets/primary_text_button.dart';
import 'package:canwa/Widgets/social_auth_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // No back button needed for a signup screen
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.book,
              color: primaryColor,
              size: 16,
            ), // SkillUp logo icon
            const SizedBox(width: 8),
            Text(
              'SkillUp',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign up for an account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Creating an account can make you learn and grow quickly.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            AuthTextfields().buildTextField(
              labelText: "Full Name",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 20),

            AuthTextfields().buildTextField(
              labelText: "Email",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 20),

            AuthTextfields().buildPasswordField(
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _agreeToTerms = newValue ?? false;
                    });
                  },
                  activeColor: primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeToTerms = !_agreeToTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'I agree to the Skillup ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryTextButton(
              text: "Sign Up",
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => OtpScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'or',
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),

            SocialAuthButton(type: ButtonType.google, onPressed: () {}),
            const SizedBox(height: 16),
            SocialAuthButton(type: ButtonType.apple, onPressed: () {}),
            const SizedBox(height: 24),

            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: textTheme.bodyLarge?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              // 🧭 Navigate to SignUp screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
