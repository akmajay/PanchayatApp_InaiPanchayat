// Basic Flutter widget test for PanchayatApp
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:panchayat_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PanchayatApp()));

    // Verify that app title is displayed
    expect(find.text('Panchayat App'), findsOneWidget);
  });
}
