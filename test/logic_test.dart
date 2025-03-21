import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roulette/roulette.dart';
import 'package:roulette/src/roulette.dart';
import 'package:roulette/utils/helpers.dart';
import 'package:roulette/src/roulette_paint.dart';

import 'test_component.dart';

void main() {
  group('helpers tests', () {
    group('calculate end rotate test', () {
      test('ensure end rotate on target unit with no offset, clockwise', () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, true, 0);
        expect(actual, 4 / 5 * pi * 2);
      });

      test('ensure end rotate on target unit with offset, clockwise', () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, true, 0, offset: 1);
        expect(actual, pi * 2);
      });

      test('ensure end rotate on target unit with no offset, not clockwise',
          () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, false, 0);
        expect(actual, 0.0);
      });

      test('ensure end rotate on target unit with offset, not clockwise', () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, true, 0, offset: 1);
        expect(actual, pi * 2);
      });
    });

    testWidgets('continuos rotation test', (WidgetTester tester) async {
      final controller = RouletteController();
      await tester.pumpWidget(RouletteWidgetTest(
        group: RouletteGroup.uniform(5),
        controller: controller,
      ));
      final widgetState = tester.state<RouletteState>(find.byType(Roulette));
      controller.rollTo(1, minRotateCircles: 0, offset: 1);
      await tester.pumpAndSettle();
      var animation = widgetState.rotateAnimation.value;
      expect(animation.value, 4 / 5 * pi * 2);

      controller.rollTo(2, minRotateCircles: 0, offset: 1);
      animation = widgetState.rotateAnimation.value;
      expect(animation.value, 4 / 5 * pi * 2);
    });

    testWidgets(
      'ensure rollTo settle at target index with offset',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const minCircles = 1;
        controller.rollTo(1, minRotateCircles: minCircles, offset: 1);
        await tester.pumpAndSettle();
        final animation = widgetState.rotateAnimation.value;
        expect(animation.value, (minCircles + 4 / 5) * pi * 2);
      },
    );
  });

  group('controller tests', () {
    testWidgets(
      'ensure rollTo settle at target index',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const minCircles = 3;
        controller.rollTo(1, minRotateCircles: minCircles);
        await tester.pumpAndSettle();
        final animation = widgetState.rotateAnimation.value;
        expect(animation.value, (minCircles + 3 / 5) * pi * 2);
      },
    );
  });

  group('other unit tests', () {
    test('conflict when set text and icon simultaneously', () {
      expect(
        () => RouletteUnit(
          text: 'TEST',
          icon: Icons.message,
          weight: 1,
          color: Colors.red,
        ),
        throwsAssertionError,
      );
    });
  });

  group('widget display tests', () {
    testWidgets(
      'ensure roulette displayed',
      (WidgetTester tester) async {
        final group = RouletteGroup.uniform(
          5,
          textBuilder: (index) => '$index',
          colorBuilder: (index) => Colors.pink,
        );
        final controller = RouletteController();
        await tester.pumpWidget(Roulette(group: group, controller: controller));
        expect(find.byType(RoulettePaint), findsOneWidget);
      },
    );
  });
}
