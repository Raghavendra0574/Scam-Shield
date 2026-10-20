import 'package:flutter/material.dart';

class ScamResultCard extends StatefulWidget {
  final bool isSuspicious;
  final List<String> matchedWords;

  const ScamResultCard({
    super.key,
    required this.isSuspicious,
    required this.matchedWords,
  });

  @override
  State<ScamResultCard> createState() =>
      _ScamResultCardState();
}

class _ScamResultCardState extends State<ScamResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Controls the animation duration.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Fade animation: transparent to fully visible.
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Slide animation: slightly below to the original position.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start both animations.
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: suspicious
              ? Colors.red.shade50
              : Colors.green.shade50,
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
                  color: suspicious
                      ? Colors.red