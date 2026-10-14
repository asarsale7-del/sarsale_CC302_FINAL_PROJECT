import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_activity/data/student_account_repository.dart';
import 'package:flutter_activity/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      ConcernRepository.storageKeyFor('S1234567'): jsonEncode([
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
    await StudentAccountRepository().createAccount(
      schoolId: 'S1234567',
      password: 'Correct!123',
    );
  });

  testWidgets('uses only the requested blue, yellow, and white theme', (
    tester,
  ) async {
    await tester.pumpWidget(const MdcConnectApp());
    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
    expect(theme.colorScheme.primary, const Color(0xFF4169E1));
    expect(theme.colorScheme.secondary, const Color(0xFFFFD84D));
    expect(theme.scaffoldBackgroundColor, Colors.white);
  });

  testWidgets('student can submit, search, and delete a concern', (
    tester,
  ) async {
    await tester.pumpWidget(const MdcConnectApp());
    await tester.pumpAndSettle();
    await _signIn(tester);
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
    await _signIn(tester);
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

  testWidgets('student can create an account and sign in', (tester) async {
    await tester.pumpWidget(const MdcConnectApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('New student? Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'MDC-0002');
    await tester.enterText(find.byType(TextFormField).at(1), 'Student!456');
    await tester.enterText(find.byType(TextFormField).at(2), 'Student!456');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('MDC-0002'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    await _signIn(tester, schoolId: 'mdc-0002', password: 'Student!456');
    expect(find.text('MDC-0002'), findsOneWidget);
  });
}

Future<void> _signIn(
  WidgetTester tester, {
  String schoolId = 'S1234567',
  String password = 'Correct!123',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), schoolId);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
}
