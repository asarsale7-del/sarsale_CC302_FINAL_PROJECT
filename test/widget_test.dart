import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_activity/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'mdc_connect_concerns_v1': jsonEncode([
        {
          'id': 'test-1',
          'title': 'LIBRARY WIFI',
          'description': 'The Wi-Fi connection drops in the library.',
          'category': 'IT Support',
          'date': '2026-10-14T10:00:00.000Z',
          'status': 'Received',
        },
      ]),
    });
  });

  testWidgets('student can submit, search, and delete a concern', (
    tester,
  ) async {
    await tester.pumpWidget(const MdcConnectApp());
    await tester.pumpAndSettle();
    expect(find.text('LIBRARY WIFI'), findsOneWidget);

    await tester.tap(find.text('How it works').first);
    await tester.pumpAndSettle();
    expect(find.text('Your demo data'), findsOneWidget);
    await tester.tap(find.text('Concerns').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Broken desk');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'A desk in the study hall is damaged.',
    );
    await tester.tap(find.text('Submit concern'));
    await tester.pumpAndSettle();
    expect(find.text('BROKEN DESK'), findsOneWidget);

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search concerns',
    );
    await tester.enterText(searchField, 'broken');
    await tester.pumpAndSettle();
    expect(find.text('BROKEN DESK'), findsOneWidget);
    expect(find.text('LIBRARY WIFI'), findsNothing);

    final deleteButton = find.byTooltip('Delete concern').first;
    await tester.ensureVisible(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('BROKEN DESK'), findsNothing);
  });

  testWidgets('validates concern details before submission', (tester) async {
    await tester.pumpWidget(const MdcConnectApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit concern'));
    await tester.pumpAndSettle();
    expect(find.text('Enter at least 4 characters'), findsOneWidget);
    expect(
      find.text('Add a little more detail (10 characters minimum)'),
      findsOneWidget,
    );
  });
}
