import 'package:flutter/material.dart';

class ScamResultCard extends StatefulWidget {
  final bool isSuspicious;
  final List<String> matchedWords;
  final int riskScore;
  final String riskLevel;
  final List<String> categories;
  final List<String> detectedUrls;

  const ScamResultCard({
    super.key,
    required this.isSuspicious,
    required this.matchedWords,
    this.riskScore = 0,
    this.riskLevel = 'No indicators found',
    this.categories = const [],
    this.detectedUrls = const [],
  });

  @override
  State<ScamResultCard> createState() => _ScamResultCardState();
}

class _ScamResultCardState extends State<ScamResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suspicious = widget.isSuspicious;
    final highRisk = widget.riskScore >= 60;

    final resultColor = !suspicious
        ? Colors.green
        : highRisk
        ? Colors.red
        : Colors.orange;

    final backgroundColor = !suspicious
        ? Colors.green.shade50
        : highRisk
        ? Colors.red.shade50
        : Colors.orange.shade50;

    final title = !suspicious
        ? 'No Configured Scam Indicators Found'
        : highRisk
        ? 'High-Risk Indicators Found'
        : 'Potential Scam Indicators Found';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  suspicious
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  size: 42,
                  color: resultColor,
                ),

                const SizedBox(height: 10),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: resultColor.shade800,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Risk score: ${widget.riskScore}/100',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text('Risk level: ${widget.riskLevel}'),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: widget.riskScore.clamp(0, 100) / 100,
                  color: resultColor,
                  backgroundColor: Colors.black12,
                ),

                if (widget.categories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Indicator categories',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.categories
                        .map((category) => Chip(label: Text(category)))
                        .toList(),
                  ),
                ],

                if (widget.matchedWords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Matched indicators',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...widget.matchedWords.map(
                    (phrase) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(phrase)),
                        ],
                      ),
                    ),
                  ),
                ],

                if (widget.detectedUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Links found',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...widget.detectedUrls.map(
                    (url) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SelectableText(url),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A link is not automatically a scam. '
                    'Check its domain carefully and do not open '
                    'unexpected links.',
                  ),
                ],

                const SizedBox(height: 16),

                const Text(
                  'This score is based on simple configured rules. '
                  'It is not a probability of fraud and cannot '
                  'prove that a message is safe or fraudulent.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
