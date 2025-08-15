import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(decoration: InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Create account')),
          ],
        ),
      ),
    );
  }
}
