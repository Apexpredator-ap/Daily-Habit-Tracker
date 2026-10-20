import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled3/features/habits/presentation/widgets/habit_header_card.dart';

void main() {
  testWidgets('HabitHeaderCard renders progress and points correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HabitHeaderCard(
            dateText: 'Monday, Oct 19',
            earnedPoints: 45,
            completedCount: 3,
            totalCount: 5,
            progress: 0.6,
          ),
        ),
      ),
    );

    expect(find.text('MONDAY, OCT 19'), findsOneWidget);
    expect(find.text('Today\'s Progress'), findsOneWidget);
    expect(find.text('45 pts'), findsOneWidget);
    expect(find.text('3 of 5 completed'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
  });
}
