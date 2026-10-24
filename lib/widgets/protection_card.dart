import 'package:flutter/material.dart';

class ProtectionCard extends StatelessWidget {
  const ProtectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user,
              size: 60,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            const Text(
              'You are protected',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scam Shield helps you identify '
              'suspicious messages and links.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}