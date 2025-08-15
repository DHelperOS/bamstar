import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            Text('밤스타에 오신 것을 환영합니다', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('계정으로 로그인하거나 소셜 계정으로 빠르게 시작하세요.', style: theme.textTheme.bodyMedium),
            const Spacer(),

            FilledButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('이메일로 로그인'),
              onPressed: () {
                debugPrint('LoginPage: Email login pressed');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이메일 로그인 (샘플)')));
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text('소셜로 계속하기'),
              onPressed: () {
                debugPrint('LoginPage: Social login pressed');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('소셜 로그인 (샘플)')));
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                debugPrint('LoginPage: Continue as guest');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게스트로 계속하기')));
              },
              child: const Text('게스트로 계속하기'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
