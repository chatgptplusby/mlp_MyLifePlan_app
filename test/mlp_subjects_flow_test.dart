import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylife_plan/features/university/mlp_subjects_flow.dart';

void main() {
  testWidgets('Subjects flow renders all 3 screens 1:1 and navigates smoothly', (tester) async {
    String? chosenSubject;
    String? chosenTopic;
    var challengeStarted = false;
    var testStarted = false;

    // 1. Verify Screen 1: Mening fanlarim
    await tester.pumpWidget(
      MaterialApp(
        home: MLPSubjectsListScreen(
          onSelectSubject: (sub) => chosenSubject = sub,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mening fanlarim'), findsOneWidget);
    expect(find.text('Fanlar (3-semestr)'), findsOneWidget);
    expect(find.text('Joriy semestr'), findsOneWidget);
    expect(find.text('Chiziqli algebra'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('Dasturlash (Flutter)'), findsOneWidget);

    await tester.tap(find.text('Chiziqli algebra'));
    await tester.pumpAndSettle();
    expect(chosenSubject, 'Chiziqli algebra');

    await tester.scrollUntilVisible(find.text('Texnik chizma'), 100);
    expect(find.text('Texnik chizma'), findsOneWidget);
    expect(find.text('Fan qo‘shish'), findsOneWidget);

    // 2. Verify Screen 2: Chiziqli algebra (Subject Detail)
    await tester.pumpWidget(
      MaterialApp(
        home: MLPSubjectDetailScreen(
          subjectName: 'Chiziqli algebra',
          onSelectTopic: (top) => chosenTopic = top,
          onStartChallenge: () => challengeStarted = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chiziqli algebra'), findsWidgets);
    expect(find.text('Kredit: 4  |  Semestr: 2'), findsOneWidget);
    expect(find.text('Darslar'), findsOneWidget);
    expect(find.text('Vazifalar'), findsOneWidget);
    expect(find.text('Mavzular (4)'), findsOneWidget);
    expect(find.text('1. Determinant ta’rifi'), findsOneWidget);
    expect(find.text('2. Determinant xossalari'), findsOneWidget);
    expect(find.text('Keyingi vazifa'), findsOneWidget);

    await tester.tap(find.text('1. Determinant ta’rifi'));
    await tester.pumpAndSettle();
    expect(chosenTopic, '1. Determinant ta’rifi');

    await tester.ensureVisible(find.text('Boshlash'));
    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    expect(challengeStarted, isTrue);

    // 3. Verify Screen 3: Dars: Determinant (Video Lesson)
    await tester.pumpWidget(
      MaterialApp(
        home: MLPLessonVideoScreen(
          lessonTitle: 'Dars: Determinant',
          onStartTest: () => testStarted = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dars: Determinant'), findsOneWidget);
    expect(find.text('04:16 / 12:34'), findsOneWidget);
    expect(find.text('Dars tafsiloti'), findsOneWidget);
    expect(find.text('Dars materiallari (PDF)'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('Mini-testni boshlash'), findsOneWidget);

    await tester.tap(find.text('Mini-testni boshlash'));
    await tester.pumpAndSettle();
    expect(testStarted, isTrue);
  });
}
