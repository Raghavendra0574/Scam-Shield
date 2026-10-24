import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/providers/scan_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScanProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    provider = ScanProvider();
    await provider.load();
  });

  tearDown(() async {
    await provider.flushPendingSave();
    provider.dispose();
  });

  group('ScanProvider tests', () {
    test('Starts with empty statistics and history', () {
      expect(provider.isLoaded, isTrue);
      expect(provider.isSuspicious, isNull);
      expect(provider.matchedWords, isEmpty);
      expect(provider.totalScans, 0);
      expect(provider.warningsFound, 0);
      expect(provider.recentActivity, isEmpty);
    });

    test('Detects configured suspicious indicators', () async {
      provider.checkMessage(
        'Congratulations! You won a prize. Claim now!',
      );
      await provider.flushPendingSave();

      expect(provider.isSuspicious, isTrue);
      expect(provider.matchedWords, contains('prize'));
      expect(provider.matchedWords, contains('claim now'));
      expect(provider.totalScans, 1);
      expect(provider.warningsFound, 1);
      expect(provider.recentActivity.length, 1);
    });

    test('Does not flag a message without matching indicators',
        () async {
      provider.checkMessage(
        'Your meeting is scheduled for tomorrow at ten AM.',
      );
      await provider.flushPendingSave();

      expect(provider.isSuspicious, isFalse);
      expect(provider.matchedWords, isEmpty);
      expect(provider.totalScans, 1);
      expect(provider.warningsFound, 0);
    });

    test('Clearing the result keeps history and statistics',
        () async {
      provider.checkMessage('You won a prize!');
      await provider.flushPendingSave();

      provider.clearResult();

      expect(provider.isSuspicious, isNull);
      expect(provider.matchedWords, isEmpty);
      expect(provider.totalScans, 1);
      expect(provider.warningsFound, 1);
      expect(provider.recentActivity.length, 1);
    });

    test('Keeps only the latest five activities', () async {
      for (var i = 0; i < 7; i++) {
        provider.checkMessage(
          'Routine meeting update number $i',
        );
      }

      await provider.flushPendingSave();

      expect(provider.totalScans, 7);
      expect(provider.recentActivity.length, 5);
    });

    test('Restores statistics and activity after reloading',
        () async {
      provider.checkMessage(
        'Congratulations! You won a prize. Claim now!',
      );
      await provider.flushPendingSave();

      final restoredProvider = ScanProvider();

      try {
        await restoredProvider.load();

        expect(restoredProvider.isLoaded, isTrue);
        expect(restoredProvider.totalScans, 1);
        expect(restoredProvider.warningsFound, 1);
        expect(restoredProvider.recentActivity.length, 1);

        final activity = restoredProvider.recentActivity.first;

        expect(activity.isSuspicious, isTrue);
        expect(activity.matchedWords, contains('prize'));
        expect(activity.riskScore, greaterThan(0));
      } finally {
        restoredProvider.dispose();
      }
    });
  });
}