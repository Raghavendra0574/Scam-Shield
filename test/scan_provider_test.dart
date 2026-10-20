import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/providers/scan_provider.dart';

void main() {
  group('ScanProvider tests', () {
    late ScanProvider provider;

    setUp(() {
      provider = ScanProvider();
    });

    test('Initial result should be empty', () {
      expect(provider.isSuspicious, isNull);
      expect(provider.matchedWords, isEmpty);
    });

    test('Detects configured suspicious keywords', () {
      provider.checkMessage(
        'Congratulations! You won a prize. Claim now!',
      );

      expect(provider.isSuspicious, isTrue);
      expect(provider.matchedWords, contains('prize'));
      expect(provider.matchedWords, contains('claim now'));
    });

    test('Does not flag a message without matching keywords', () {
      provider.checkMessage(
        'Your meeting is scheduled for tomorrow at 10 AM.',
      );

      expect(provider.isSuspicious, isFalse);
      expect(provider.matchedWords, isEmpty);
    });

    test('Clears the previous scan result', () {
      provider.checkMessage('You won a prize!');
      provider.clearResult();

      expect(provider.isSuspicious, isNull);
      expect(provider.matchedWords, isEmpty);
    });
  });
}