import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:idmanager_app/main.dart';

void main() {
  testWidgets('App shows the login screen when no session is restored', (WidgetTester tester) async {
    // shared_preferences needs its mock platform-channel values set before use in
    // tests, otherwise getInstance() never completes and the splash screen never
    // resolves.
    SharedPreferences.setMockInitialValues({});

    // The splash screen shows an indeterminate CircularProgressIndicator, which
    // animates forever - pumpAndSettle would hang waiting for it to stop, so pump a
    // few frames instead to let the async session-restore future resolve.
    await tester.pumpWidget(const ProviderScope(child: IdManagerApp()));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('IDManager'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone'), findsOneWidget);
  });
}
