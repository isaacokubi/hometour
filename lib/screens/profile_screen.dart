import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user ?? <String, dynamic>{};
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 48)),
          const SizedBox(height: 16),
          Center(child: Text((user['name'] ?? user['fullName'] ?? 'Customer').toString(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
          Center(child: Text((user['email'] ?? '').toString())),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.business), title: const Text('Tenant'), subtitle: Text((user['tenantSlug'] ?? 'Global Tours').toString())),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.security), title: const Text('Role'), subtitle: Text((user['role'] ?? 'customer').toString())),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(onPressed: state.logout, icon: const Icon(Icons.logout), label: const Text('Sign out')),
        ],
      ),
    );
  }
}
