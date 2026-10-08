import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_activity/data/gadget_repository.dart';
import 'package:flutter_activity/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('user can create, search, update, and delete a gadget', (
    tester,
  ) async {
    await tester.pumpWidget(const GadgetCatalogApp());
    await tester.pumpAndSettle();

    expect(find.text('Everyday Smartphone'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Wired Mouse');
    await tester.enterText(find.byType(TextFormField).at(1), 'Accessories');
    await tester.enterText(find.byType(TextFormField).at(2), '799.50');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Comfortable precision mouse.',
    );
    await tester.tap(find.text('Add gadget').last);
    await tester.pumpAndSettle();

    expect(find.text('Wired Mouse'), findsOneWidget);
    expect(find.text('₱799.50'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search your collection'),
      'mouse',
    );
    await tester.pumpAndSettle();
    expect(find.text('Wired Mouse'), findsOneWidget);
    expect(find.text('Everyday Smartphone'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextField, 'Search your collection'),
      '',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit Wired Mouse'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Wireless Mouse');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.text('Wired Mouse'), findsNothing);

    await tester.tap(find.byTooltip('Delete Wireless Mouse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Wireless Mouse'), findsNothing);
    final savedGadgets = await GadgetRepository().loadGadgets();
    expect(
      savedGadgets.map((gadget) => gadget.name),
      isNot(contains('Wireless Mouse')),
    );
  });

  testWidgets('rejects a negative gadget price', (tester) async {
    await tester.pumpWidget(const GadgetCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Bad Price Gadget',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Accessories');
    await tester.enterText(find.byType(TextFormField).at(2), '-1');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Test description',
    );
    await tester.tap(find.text('Add gadget').last);
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid non-negative price'), findsOneWidget);
    expect(find.byTooltip('Edit Bad Price Gadget'), findsNothing);
  });
}
