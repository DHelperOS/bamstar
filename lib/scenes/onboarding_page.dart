import 'package:flutter/material.dart';
import 'package:animated_introduction/animated_introduction.dart';
import 'login_page.dart';
import 'register_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pages = <SingleIntroScreen>[
      const SingleIntroScreen(
        title: 'Welcome to Bamstar !',
        description: 'You plans your Events, We\'ll do the rest and will be the best! Guaranteed!',
        imageAsset: 'assets/onboard_one.png',
      ),
      const SingleIntroScreen(
        title: 'Book tickets',
        description: 'Tickets to the latest movies, crickets matches, concerts, comedy shows, plus lots more !',
        imageAsset: 'assets/onboard_two.png',
      ),
      const SingleIntroScreen(
        title: 'Grab events',
        description: 'All events are now in your hands, just a click away !',
        imageAsset: 'assets/onboard_three.png',
      ),
    ];

    // Create a local Theme that forces button styles to match app color scheme (purple)
    final themed = theme.copyWith(
      // ensure internal Scaffolds use primary as background
      colorScheme: theme.colorScheme.copyWith(
        background: theme.colorScheme.primary,
        surface: theme.colorScheme.primary,
      ),
      scaffoldBackgroundColor: theme.colorScheme.primary,
      canvasColor: theme.colorScheme.primary,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );

    return Theme(
      data: themed,
      child: Container(
        color: theme.colorScheme.primary,
        child: SafeArea(
          child: SizedBox.expand(
            child: AnimatedIntroduction(
              slides: pages,
              indicatorType: IndicatorType.circle,
              onDone: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              onSkip: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}


