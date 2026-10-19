import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

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
      routes: {
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}

class ScamHomePage extends StatefulWidget {
  const ScamHomePage({super.key});

  @override
  State<ScamHomePage> createState() => _ScamHomePageState();
}

class _ScamHomePageState extends State<ScamHomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _messageController =
      TextEditingController();

  bool? _isSuspicious;
  List<String> _matchedWords = [];

  void _checkMessage() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final message = _messageController.text.trim();
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

  // Protection card
  Widget _buildProtectionCard() {
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
              'Scam Shield helps you identify suspicious '
              'messages and links.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Scanner form and button
  Widget _buildScannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Check a suspicious message',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Form(
          key: _formKey,
          child: TextFormField(
            controller: _messageController,
            maxLines: 4,
            maxLength: 1000,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a message to check.';
              }

              if (value.trim().length < 5) {
                return 'Enter at least 5 characters.';
              }

              return null;
            },
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
              hintText: 'Paste a suspicious SMS, email, or message here...',
              helperText: 'Never share passwords or one-time codes.',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.message_outlined),
            ),
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          onPressed: _checkMessage,
          icon: const Icon(Icons.search),
          label: const Text('CHECK NOW'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 20),

        if (_isSuspicious != null) _buildResultCard(),
      ],
    );
  }

  // Scan result card
  Widget _buildResultCard() {
    final suspicious = _isSuspicious!;

    return Card(
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
              color: suspicious ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 10),
            Text(
              suspicious
                  ? 'Potential Scam Signs Detected'
                  : 'No Obvious Scam Signs Detected',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: suspicious
                    ? Colors.red.shade800
                    : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 10),
            if (suspicious)
              Text('Indicators found: ${_matchedWords.join(', ')}')
            else
              const Text('No configured keywords were found.'),
            const SizedBox(height: 12),
            const Text(
              'This is a basic demonstration, not a reliable '
              'scam detector. Always verify messages independently.',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive screen width detection using MediaQuery.
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoints:
    // Mobile: below 600 pixels
    // Tablet: 600 to 899 pixels
    // Laptop/desktop: 900 pixels and above
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 900;

    final pagePadding = isMobile
        ? 16.0
        : isDesktop
            ? 32.0
            : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Shield'),
        centerTitle: true,
        leading: const Icon(Icons.shield),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.all(pagePadding),
              child: isDesktop
                  // Laptop: protection card and scanner side by side.
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildProtectionCard(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildScannerSection(),
                        ),
                      ],
                    )

                  // Mobile and tablet: stack the sections vertically.
                  : Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _buildProtectionCard(),
                        const SizedBox(height: 24),
                        _buildScannerSection(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}