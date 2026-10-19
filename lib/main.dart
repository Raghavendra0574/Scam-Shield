import 'package:flutter/material.dart';

void main() {
  runApp(const ScamShieldApp());
}

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scam Shield',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ScamHomePage(),
    );
  }
}

class ScamHomePage extends StatefulWidget {
  const ScamHomePage({super.key});

  @override
  State<ScamHomePage> createState() => _ScamHomePageState();
}

class _ScamHomePageState extends State<ScamHomePage> {
  final TextEditingController _messageController =
      TextEditingController();

  bool? _isSuspicious;
  List<String> _matchedWords = [];

  // Basic rule-based scam detection for demonstration.
  void _checkMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message to check.'),
        ),
      );
      return;
    }

    final lowerMessage = message.toLowerCase();

    const suspiciousKeywords = [
      'urgent',
      'winner',
      'won a prize',
      'prize',
      'verify account',
      'click here',
      'click the link',
      'claim now',
      'send money',
      'bank account',
      'otp',
      'password',
      'free gift',
      'limited time',
    ];

    final matched = suspiciousKeywords
        .where((word) => lowerMessage.contains(word))
        .toList();

    setState(() {
      _matchedWords = matched;
      _isSuspicious = matched.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Shield'),
        centerTitle: true,
        leading: const Icon(Icons.shield),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Protection status card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 60,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'You are protected',
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
              ),

              const SizedBox(height: 28),

              const Text(
                'Check a suspicious message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Message input field
              TextField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) {
                  if (_isSuspicious != null) {
                    setState(() {
                      _isSuspicious = null;
                      _matchedWords = [];
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Message to check',
                  hintText:
                      'Paste a suspicious SMS, email, or message here...',
                  helperText:
                      'Never share passwords or one-time codes.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Check Now button
              ElevatedButton.icon(
                onPressed: _checkMessage,
                icon: const Icon(Icons.search),
                label: const Text('CHECK NOW'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Show the result after checking a message
              if (_isSuspicious != null)
                Card(
                  color: _isSuspicious!
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isSuspicious!
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                          size: 42,
                          color: _isSuspicious!
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isSuspicious!
                              ? 'Potential Scam Signs Detected'
                              : 'No Obvious Scam Signs Detected',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: _isSuspicious!
                                ? Colors.red.shade800
                                : Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isSuspicious!)
                          Text(
                            'Indicators found: '
                            '${_matchedWords.join(', ')}',
                          )
                        else
                          const Text(
                            'No configured keywords were found.',
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'This is a basic demonstration, not a '
                          'reliable scam detector. Always verify '
                          'messages independently.',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}