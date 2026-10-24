import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/dashboard_page.dart';
import 'providers/scan_provider.dart';
import 'widgets/protection_card.dart';
import 'widgets/scam_result_card.dart';

const Color _brandBlue = Color(0xFF2563EB);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _ink = Color(0xFF14213D);

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
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scam Shield',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseColorScheme.copyWith(
          primary: _brandBlue,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: _pageBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: _pageBackground,
          foregroundColor: _ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _ink,
          displayColor: _ink,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDCE4F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDCE4F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _brandBlue, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide.none,
        ),
      ),
      home: const ScamHomePage(),
      routes: {'/dashboard': (context) => const DashboardPage()},
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
  final TextEditingController _messageController = TextEditingController();

  void _checkMessage() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<ScanProvider>().checkMessage(_messageController.text);
  }

  void _showSafetyInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: _brandBlue),
            SizedBox(width: 10),
            Text('About Scam Shield'),
          ],
        ),
        content: const Text(
          'Scam Shield checks messages using configured warning phrases and URL patterns. '
          'Its risk score is a simple rule-based signal, not a guarantee that a message is '
          'safe or fraudulent. Never share passwords, PINs, or one-time codes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _sectionHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check before you click.',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
        ),
        const SizedBox(height: 8),
        Text(
          'Review suspicious messages for common warning signs.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: const Color(0xFF64748B), height: 1.45),
        ),
      ],
    );
  }

  Widget _buildScannerSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4EAF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: _brandBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message scanner',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Local rule-based check',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF15945A)),
                    SizedBox(width: 6),
                    Text(
                      'READY',
                      style: TextStyle(
                        color: Color(0xFF137648),
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
          const SizedBox(height: 22),
          const Text(
            'Check a suspicious message',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _messageController,
              maxLines: 5,
              minLines: 4,
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
              onChanged: (_) => context.read<ScanProvider>().clearResult(),
              decoration: const InputDecoration(
                labelText: 'Message to check',
                hintText: 'Paste a suspicious SMS, email, or message here...',
                helperText: 'Avoid including real passwords or one-time codes.',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.chat_bubble_outline),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _checkMessage,
              icon: const Icon(Icons.shield_outlined),
              label: const Text('CHECK NOW'),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 17, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your message is checked against local configured rules. This is a helpful first check, not a guarantee.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Consumer<ScanProvider>(
            builder: (context, scan, child) {
              if (scan.isSuspicious == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ScamResultCard(
                  isSuspicious: scan.isSuspicious!,
                  matchedWords: scan.matchedWords,
                  riskScore: scan.riskScore,
                  riskLevel: scan.riskLevel,
                  categories: scan.categories,
                  detectedUrls: scan.detectedUrls,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 960;
    final pagePadding = isMobile ? 16.0 : (isDesktop ? 32.0 : 24.0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE4ECFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_rounded, color: _brandBlue),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scam Shield',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  'MESSAGE SAFETY',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.1,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
            icon: const Icon(Icons.space_dashboard_outlined),
            tooltip: 'Dashboard',
          ),
          IconButton(
            onPressed: _showSafetyInfo,
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About Scam Shield',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
            child: Padding(
              padding: EdgeInsets.all(pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionHeading(),
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 2, child: ProtectionCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _buildScannerSection()),
                      ],
                    )
                  else ...[
                    const ProtectionCard(),
                    const SizedBox(height: 20),
                    _buildScannerSection(),
                  ],
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Pause • Check • Then respond',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
