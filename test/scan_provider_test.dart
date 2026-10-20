import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/providers/scan_provider.dart';

void main() {
  group('ScanProvider tests', () {
    late ScanProvider provider;

    setUp(() {
      provider = ScanProvider();
    });

    test('Initial result and statistics are empty', () {
      expect(provider.isSuspicious, isNull);
      expect(provider.matchedWords, isEmpty);
      expect(provider.totalScans, 0);
      expect(provider.warningsFound, 0);
      expect(provider.recentActivity, isEmpty);
    });

    test('Detects configured suspicious keywords', () {
      provider.checkMessage(
        'Congratulations! You won a prize. Claim now!',
      );

      expect(provider.isSuspicious, isTrue);
      expect(provider.matchedWords, contains('prize'));
      expect(provider.matchedWords, contains('claim now'));
      expect(provider.totalScans, 1);
      expect(provider.warningsFound, 1);
      expect(provider.recentActivity.length, 1);
    });

    test('Does not flag a message without matching keywords', () {
      provider.checkMessage(
        'Your meeting is scheduled for tomorrow at ten AM.',
      );

      expect(provider.isSuspicious, isFalse);
      expect(provider.matchedWords, isEmpty);
      expect(provider.totalScans, 1);
      expect(provider.warningsFound, 0);
    });

    test('Clears the current result but keeps statistics', () {
      provider.checkMessage('You won a prize!');
      provider.clearResult();

      expect(provider.isSuspicious, isNull);
      expect(provider.matchedWords, isEmpty);
      expect(provider.totalScans, 1);
      expect(provider.warningsFound, 1);
      expect(provider.recentActivity.length, 1);
    });

    test('Retains only the latest five scan activities', () {
      for (var i = 0; i < 7; i++) {
        provider.checkMessage('Routine meeting update number $i');
      }

      expect(provider.totalScans, 7);
      expect(provider.recentActivity.length, 5);
    });
  });
}