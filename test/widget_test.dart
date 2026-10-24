import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/scam_result_card.dart';

void main() {
  group('ScamResultCard widget tests', () {
    testWidgets(
      'Displays suspicious indicators and risk score',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ScamResultCard(
                isSuspicious: true,
                matchedWords: ['prize', 'claim now'],
                riskScore: 45,
                riskLevel: 'Elevated',
                categories: ['Unexpected reward'],
              ),
            ),
          ),
        );

        // Complete the fade and slide animations.
        await tester.pumpAndSettle();

        expect(
          find.text('Potential Scam Indicators Found'),
          findsOneWidget,
        );

        expect(
          find.text('Risk score: 45/100'),
          findsOneWidget,
        );

        expect(
          find.text('Risk level: Elevated'),
          findsOneWidget,
        );

        expect(find.text('Matched indicators'), findsOneWidget);
        expect(find.text('prize'), findsOneWidget);
        expect(find.text('claim now'), findsOneWidget);
        expect(find.text('Unexpected reward'), findsOneWidget);
      },
    );

    testWidgets(
      'Displays zero risk when no indicators are found',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ScamResultCard(
                isSuspicious: false,
                matchedWords: [],
                riskScore: 0,
                riskLevel: 'No indicators found',
                categories: [],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('No Configured Scam Indicators Found'),
          findsOneWidget,
        );

        expect(
          find.text('Risk score: 0/100'),
          findsOneWidget,
        );

        expect(
          find.text('Risk level: No indicators found'),
          findsOneWidget,
        );

        expect(
          find.text('Matched indicators'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Displays high-risk results',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ScamResultCard(
                isSuspicious: true,
                matchedWords: ['share your otp'],
                riskScore: 60,
                riskLevel: 'High',
                categories: [
                  'Sensitive information request',
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('High-Risk Indicators Found'),
          findsOneWidget,
        );

        expect(find.text('Risk score: 60/100'), findsOneWidget);
        expect(find.text('Risk level: High'), findsOneWidget);
        expect(find.text('share your otp'), findsOneWidget);

        expect(
          find.text('Sensitive information request'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Displays detected URLs without opening them',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ScamResultCard(
                isSuspicious: true,
                matchedWords: [
                  'URL shortener domain detected',
                ],
                riskScore: 20,
                riskLevel: 'Caution',
                categories: ['Shortened link'],
                detectedUrls: ['https://bit.ly/example'],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('https://bit.ly/example'),
          findsOneWidget,
        );

        expect(find.text('Links found'), findsOneWidget);
        expect(find.text('Shortened link'), findsOneWidget);
      },
    );
  });
}