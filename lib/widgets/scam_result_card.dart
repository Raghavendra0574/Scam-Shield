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
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ScamResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riskScore != widget.riskScore ||
        oldWidget.isSuspicious != widget.isSuspicious ||
        oldWidget.matchedWords != widget.matchedWords) {
      _controller
        ..reset()
        ..forward();
    }
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
    final Color resultColor = !suspicious
        ? const Color(0xFF138A58)
        : highRisk
            ? const Color(0xFFCF3038)
            : const Color(0xFFC57917);
    final Color backgroundColor = !suspicious
        ? const Color(0xFFF0FBF5)
        : highRisk
            ? const Color(0xFFFFF2F2)
            : const Color(0xFFFFF8EB);
    final title = !suspicious
        ? 'No Configured Scam Indicators Found'
        : highRisk
            ? 'High-Risk Indicators Found'
            : 'Potential Scam Indicators Found';
    final description = !suspicious
        ? 'No configured warning phrases matched this message. Stay cautious with unexpected requests.'
        : 'Review this message carefully before responding, paying, or opening any links.';
    final score = widget.riskScore.clamp(0, 100).toDouble();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: resultColor.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: resultColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      suspicious
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded,
                      color: resultColor,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: resultColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: score / 100,
                              strokeWidth: 7,
                              strokeCap: StrokeCap.round,
                              backgroundColor: const Color(0xFFE7EAF0),
                              valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${score.toInt()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'of 100',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RULE-BASED RISK SCORE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.55,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Risk level: ${widget.riskLevel}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: resultColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Risk score: ${widget.riskScore}/100',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            suspicious
                                ? 'Warning signs were detected.'
                                : 'No configured indicators matched.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.categories.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _DetailHeading(
                  icon: Icons.category_outlined,
                  label: 'Indicator categories',
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: widget.categories
                      .map((category) => _ResultChip(
                            label: category,
                            color: resultColor,
                          ))
                      .toList(),
                ),
              ],
              if (widget.matchedWords.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _DetailHeading(
                  icon: Icons.manage_search_rounded,
                  label: 'Matched indicators',
                ),
                const SizedBox(height: 8),
                ...widget.matchedWords.map(
                  (phrase) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 7, color: resultColor),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            phrase,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (widget.detectedUrls.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _DetailHeading(
                  icon: Icons.link_rounded,
                  label: 'Links found',
                ),
                const SizedBox(height: 8),
                ...widget.detectedUrls.map(
                  (url) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SelectableText(
                      url,
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'A link is not automatically a scam. Check the domain carefully and do not open unexpected links.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 17, color: Color(0xFF64748B)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This score comes from simple configured rules. It is not a probability of fraud and cannot prove a message is safe or fraudulent.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.45,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHeading extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailHeading({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF475569)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ResultChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
