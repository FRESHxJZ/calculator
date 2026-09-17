import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workspace/main.dart';

void main() {
  Future<void> press(WidgetTester tester, String value) async {
    await tester.tap(find.widgetWithText(FilledButton, value));
    await tester.pump();
  }

  Future<void> enter(WidgetTester tester, String values) async {
    for (final value in values.split('')) {
      await press(tester, value);
    }
  }

  Future<void> pumpCalculator(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  testWidgets('evaluates expressions using algebraic precedence', (
    tester,
  ) async {
    await pumpCalculator(tester);
    await enter(tester, '2+3*4');
    await press(tester, '=');

    expect(find.text('2+3*4 = 14'), findsOneWidget);
  });

  testWidgets('clear resets the accumulator', (tester) async {
    await pumpCalculator(tester);
    await enter(tester, '123+4');
    await press(tester, 'C');

    expect(find.byKey(const Key('calculator-display')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '0',
    );
  });

  testWidgets('continues from a completed result', (tester) async {
    await pumpCalculator(tester);
    await enter(tester, '2+3');
    await press(tester, '=');
    await press(tester, '*');
    await press(tester, '4');
    await press(tester, '=');

    expect(find.text('5*4 = 20'), findsOneWidget);
  });

  testWidgets('shows a recoverable error for division by zero', (tester) async {
    await pumpCalculator(tester);
    await enter(tester, '8/0');
    await press(tester, '=');

    expect(find.text('Cannot calculate this expression'), findsOneWidget);
    await press(tester, 'C');
    expect(
      tester.widget<Text>(find.byKey(const Key('calculator-display'))).data,
      '0',
    );
  });

  testWidgets('shows an error for an incomplete expression', (tester) async {
    await pumpCalculator(tester);
    await enter(tester, '7+');
    await press(tester, '=');

    expect(find.text('Enter a complete expression'), findsOneWidget);
  });

  testWidgets('handles a long chained expression', (tester) async {
    await pumpCalculator(tester);
    await enter(tester, '1+1+1+1+1+1+1+1+1+1');
    await press(tester, '=');

    expect(find.text('1+1+1+1+1+1+1+1+1+1 = 10'), findsOneWidget);
  });
}
