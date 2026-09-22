import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLoggedIn});
  final VoidCallback onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => busy = true);
    final success = await context.read<AppState>().login(email.text, password.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (success) widget.onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AppState>().error;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.travel_explore, size: 64, color: Color(0xFF15803D)),
                      const SizedBox(height: 12),
                      Text('Global Tours', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      const Text('Explore Kenya. Book unforgettable journeys.', textAlign: TextAlign.center),
                      const SizedBox(height: 28),
                      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                      const SizedBox(height: 12),
                      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                      const SizedBox(height: 16),
                      if (error != null) Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: busy ? null : _submit,
                        icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
                        label: const Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
