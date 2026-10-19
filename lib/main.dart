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
  // Controls the text entered by the user.
  final TextEditingController _messageController =
      TextEditingController();

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

              // Message input section
              const Text(
                'Check a suspicious message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
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
            ],
          ),
        ),
      ),
    );
  }
}