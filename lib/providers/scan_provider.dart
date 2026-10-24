import 'package:flutter/foundation.dart';

class ScamIndicator {
  final String phrase;
  final String category;
  final int weight;

  const ScamIndicator({
    required this.phrase,
    required this.category,
    required this.weight,
  });
}

class ScanActivity {
  final bool isSuspicious;
  final List<String> matchedWords;
  final List<String> categories;
  final List<String> detectedUrls;
  final int riskScore;
  final String riskLevel;
  final DateTime scannedAt;

  ScanActivity({
    required this.isSuspicious,
    required List<String> matchedWords,
    required List<String> categories,
    required List<String> detectedUrls,
    required this.riskScore,
    required this.riskLevel,
    required this.scannedAt,
  }) : matchedWords = List.unmodifiable(matchedWords),
       categories = List.unmodifiable(categories),
       detectedUrls = List.unmodifiable(detectedUrls);
}

class _IndicatorRule {
  final String phrase;
  final String category;
  final int weight;

  const _IndicatorRule(this.phrase, this.category, this.weight);
}

class ScanProvider extends ChangeNotifier {
  bool? _isSuspicious;
  List<String> _matchedWords = [];
  List<String> _categories = [];
  List<String> _detectedUrls = [];

  int _riskScore = 0;
  String _riskLevel = 'Not scanned';

  int _totalScans = 0;
  int _warningsFound = 0;

  final List<ScanActivity> _recentActivity = [];

  static const List<_IndicatorRule> _rules = [
    // Urgency and pressure.
    _IndicatorRule('urgent', 'Urgency or pressure', 12),
    _IndicatorRule('act now', 'Urgency or pressure', 12),
    _IndicatorRule('act immediately', 'Urgency or pressure', 12),
    _IndicatorRule('last chance', 'Urgency or pressure', 12),
    _IndicatorRule('limited time', 'Urgency or pressure', 12),
    _IndicatorRule('within 24 hours', 'Urgency or pressure', 15),
    _IndicatorRule('final warning', 'Urgency or pressure', 18),
    _IndicatorRule('account will be suspended', 'Urgency or pressure', 22),
    _IndicatorRule('immediate action required', 'Urgency or pressure', 18),

    // Credentials and sensitive information.
    _IndicatorRule('share your otp', 'Sensitive information request', 30),
    _IndicatorRule('send your otp', 'Sensitive information request', 30),
    _IndicatorRule('tell me the otp', 'Sensitive information request', 30),
    _IndicatorRule('one-time password', 'Sensitive information request', 25),
    _IndicatorRule('verification code', 'Sensitive information request', 25),
    _IndicatorRule(
      'confirm your password',
      'Sensitive information request',
      30,
    ),
    _IndicatorRule('enter your pin', 'Sensitive information request', 30),
    _IndicatorRule('card cvv', 'Sensitive information request', 30),
    _IndicatorRule('bank details', 'Sensitive information request', 25),
    _IndicatorRule('account credentials', 'Sensitive information request', 30),
    _IndicatorRule('login credentials', 'Sensitive information request', 30),

    // Money and payment pressure.
    _IndicatorRule('send money', 'Payment request', 25),
    _IndicatorRule('transfer money', 'Payment request', 25),
    _IndicatorRule('processing fee', 'Payment request', 25),
    _IndicatorRule('pay a fee', 'Payment request', 25),
    _IndicatorRule('payment required', 'Payment request', 22),
    _IndicatorRule('pay now', 'Payment request', 20),
    _IndicatorRule('gift card', 'Payment request', 25),
    _IndicatorRule('wire transfer', 'Payment request', 25),
    _IndicatorRule('refund fee', 'Payment request', 25),
    _IndicatorRule('deposit now', 'Payment request', 25),
    _IndicatorRule('crypto wallet', 'Payment request', 25),
    _IndicatorRule('upi pin', 'Payment request', 30),
    _IndicatorRule('upi collect request', 'Payment request', 25),

    // Unexpected prizes and rewards.
    _IndicatorRule('prize', 'Unexpected reward', 12),
    _IndicatorRule('winner', 'Unexpected reward', 12),
    _IndicatorRule('won a prize', 'Unexpected reward', 18),
    _IndicatorRule('claim your prize', 'Unexpected reward', 18),
    _IndicatorRule('claim now', 'Unexpected reward', 15),
    _IndicatorRule('free gift', 'Unexpected reward', 15),
    _IndicatorRule('lottery winner', 'Unexpected reward', 20),
    _IndicatorRule('you have won', 'Unexpected reward', 18),
    _IndicatorRule('cash reward', 'Unexpected reward', 15),
    _IndicatorRule('selected for a reward', 'Unexpected reward', 18),

    // Account and identity requests.
    _IndicatorRule('verify your account', 'Account verification pressure', 20),
    _IndicatorRule('account suspended', 'Account verification pressure', 22),
    _IndicatorRule('unlock your account', 'Account verification pressure', 20),
    _IndicatorRule('update kyc', 'Account verification pressure', 20),
    _IndicatorRule('kyc expired', 'Account verification pressure', 20),
    _IndicatorRule(
      'confirm your identity',
      'Account verification pressure',
      20,
    ),
    _IndicatorRule('account blocked', 'Account verification pressure', 20),
    _IndicatorRule('click here to verify', 'Account verification pressure', 22),

    // Impersonation-related phrases.
    _IndicatorRule('police case', 'Possible impersonation', 20),
    _IndicatorRule('customs department', 'Possible impersonation', 15),
    _IndicatorRule('income tax department', 'Possible impersonation', 15),
    _IndicatorRule('bank security team', 'Possible impersonation', 20),
    _IndicatorRule('official support', 'Possible impersonation', 10),

    // Requests for secrecy.
    _IndicatorRule('do not tell anyone', 'Secrecy request', 18),
    _IndicatorRule("don't tell anyone", 'Secrecy request', 18),
    _IndicatorRule('keep this confidential', 'Secrecy request', 15),
  ];

  static final RegExp _urlPattern = RegExp(
    r'(https?://[^\s<>]+|www\.[^\s<>]+)',
    caseSensitive: false,
  );

  static final RegExp _ipUrlPattern = RegExp(
    r'https?://(?:\d{1,3}\.){3}\d{1,3}(?::\d+)?(?:/[^\s<>]*)?',
    caseSensitive: false,
  );

  static const List<String> _shortenerDomains = [
    'bit.ly',
    'tinyurl.com',
    't.co',
    'cutt.ly',
    'is.gd',
    'rb.gy',
    'rebrand.ly',
  ];

  bool? get isSuspicious => _isSuspicious;

  List<String> get matchedWords => List.unmodifiable(_matchedWords);

  List<String> get categories => List.unmodifiable(_categories);

  List<String> get detectedUrls => List.unmodifiable(_detectedUrls);

  int get riskScore => _riskScore;

  String get riskLevel => _riskLevel;

  int get totalScans => _totalScans;

  int get warningsFound => _warningsFound;

  List<ScanActivity> get recentActivity => List.unmodifiable(_recentActivity);

  void checkMessage(String message) {
    final lowerMessage = message.trim().toLowerCase();

    final matchedRules = <_IndicatorRule>[];

    // Match configured phrases.
    for (final rule in _rules) {
      if (lowerMessage.contains(rule.phrase)) {
        matchedRules.add(rule);
      }
    }

    // Find URLs without opening or requesting them.
    final urls = _urlPattern
        .allMatches(message)
        .map((match) => match.group(0)!)
        .toList();

    // Check for shortened links.
    final hasShortenedLink = urls.any((url) {
      final normalized = url.toLowerCase().startsWith('www.')
          ? 'https://$url'
          : url;

      final uri = Uri.tryParse(normalized);
      final host = uri?.host.toLowerCase() ?? '';

      return _shortenerDomains.any(
        (domain) => host == domain || host.endsWith('.$domain'),
      );
    });

    if (hasShortenedLink) {
      matchedRules.add(
        const _IndicatorRule(
          'URL shortener domain detected',
          'Shortened link',
          20,
        ),
      );
    }

    // Check for URLs that use an IP address as their host.
    if (_ipUrlPattern.hasMatch(message)) {
      matchedRules.add(
        const _IndicatorRule('URL uses a raw IP address', 'Unusual URL', 30),
      );
    }

    // Store matched phrases for the result card.
    _matchedWords = matchedRules.map((rule) => rule.phrase).toSet().toList();

    // Store unique categories.
    _categories = matchedRules.map((rule) => rule.category).toSet().toList();

    _detectedUrls = urls;

    // Use the highest weight within each category so
    // repeated related phrases do not inflate the score.
    final categoryWeights = <String, int>{};

    for (final rule in matchedRules) {
      final currentWeight = categoryWeights[rule.category] ?? 0;

      if (rule.weight > currentWeight) {
        categoryWeights[rule.category] = rule.weight;
      }
    }

    final score = categoryWeights.values.fold<int>(
      0,
      (total, weight) => total + weight,
    );

    _riskScore = score.clamp(0, 100).toInt();
    _isSuspicious = matchedRules.isNotEmpty;

    if (_riskScore >= 60) {
      _riskLevel = 'High';
    } else if (_riskScore >= 35) {
      _riskLevel = 'Elevated';
    } else if (_riskScore >= 20) {
      _riskLevel = 'Caution';
    } else if (_riskScore > 0) {
      _riskLevel = 'Low';
    } else {
      _riskLevel = 'No indicators found';
    }

    // Update session statistics.
    _totalScans++;

    if (_isSuspicious!) {
      _warningsFound++;
    }

    // Record scan activity without storing the full message.
    _recentActivity.insert(
      0,
      ScanActivity(
        isSuspicious: _isSuspicious!,
        matchedWords: _matchedWords,
        categories: _categories,
        detectedUrls: _detectedUrls,
        riskScore: _riskScore,
        riskLevel: _riskLevel,
        scannedAt: DateTime.now(),
      ),
    );

    if (_recentActivity.length > 5) {
      _recentActivity.removeLast();
    }

    notifyListeners();
  }

  void clearResult() {
    if (_isSuspicious == null &&
        _matchedWords.isEmpty &&
        _detectedUrls.isEmpty) {
      return;
    }

    _isSuspicious = null;
    _matchedWords = [];
    _categories = [];
    _detectedUrls = [];
    _riskScore = 0;
    _riskLevel = 'Not scanned';

    // Keep statistics and history intact.
    notifyListeners();
  }
}
