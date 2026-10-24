import 'package:flutter/material.dart';

class ProtectionCard extends StatelessWidget {
  const ProtectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF142A55), Color(0xFF1D4B91), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x202563EB),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.shield_moon_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF86EFAC)),
                    SizedBox(width: 7),
                    Text(
                      'SCANNER READY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Stay one step\nahead of scams.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Spot common warning signs before you reply, pay, or open an unexpected link.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 26),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
          const SizedBox(height: 22),
          const _ProtectionFeature(
            icon: Icons.text_snippet_outlined,
            title: 'Message pattern checks',
            subtitle: 'Look for configured scam phrases',
          ),
          const SizedBox(height: 18),
          const _ProtectionFeature(
            icon: Icons.link_outlined,
            title: 'Link awareness',
            subtitle: 'Highlight URLs for closer review',
          ),
          const SizedBox(height: 18),
          const _ProtectionFeature(
            icon: Icons.history_rounded,
            title: 'Saved scan history',
            subtitle: 'Review your recent checks',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 19),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This scanner uses configured rules. It cannot guarantee that a message is safe.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProtectionFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
