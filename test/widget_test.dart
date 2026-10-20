import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/scam_result_card.dart';

void main() {
  group('ScamResultCard widget tests', () {
    testWidgets('Shows suspicious result and matching words',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScamResultCard(
              isSuspicious: true,
              matchedWords: ['prize', 'claim now'],
            ),
          ),
        ),
      );

      // Finish the fade and slide animations.
      await tester.pumpAndSettle();

      expect(
        find.text('Potential Scam Signs Detected'),
        findsOneWidget,
      );

      expect(
        find.text('Indicators found: prize, claim now'),
        findsOneWidget,
      );
    });

    testWidgets('Shows the result for a message without indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScamResultCard(
              isSuspicious: false,
              matchedWords: [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('No Obvious Scam Signs Detected'),
        findsOneWidget,
      );

      expect(
        find.text('No configured keywords were found.'),
        findsOneWidget,
      );
    });
  });
}