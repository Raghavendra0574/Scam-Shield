import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/dashboard_page.dart';
import 'providers/scan_provider.dart';
import 'widgets/protection_card.dart';
import 'widgets/scam_result_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final scanProvider = ScanProvider();
  await scanProvider.load();

  runApp(
    ChangeNotifierProvider<ScanProvider>.value(
      value: scanProvider,
      child: const ScamShieldApp(),
    ),
  );
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

  void _checkMessage() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ScanProvider>().checkMessage(
          _messageController.text,
        );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
              context.read<ScanProvider>().clearResult();
            },
            decoration: const InputDecoration(
              labelText: 'Message to check',
              hintText:
                  'Paste a suspicious SMS, email, or message here...',
              helperText:
                  'Never share real passwords or one-time codes.',
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
        Consumer<ScanProvider>(
          builder: (context, scan, child) {
            if (scan.isSuspicious == null) {
              return const SizedBox.shrink();
            }

            return ScamResultCard(
              isSuspicious: scan.isSuspicious!,
              matchedWords: scan.matchedWords,
              riskScore: scan.riskScore,
              riskLevel: scan.riskLevel,
              categories: scan.categories,
              detectedUrls: scan.detectedUrls,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: ProtectionCard(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildScannerSection(),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ProtectionCard(),
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