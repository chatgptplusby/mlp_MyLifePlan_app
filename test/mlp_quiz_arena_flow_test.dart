import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylife_plan/features/university/mlp_quiz_arena_flow.dart';

void main() {
  testWidgets('Quiz Arena 5-screen flow renders 1:1 and navigates end-to-end', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? navigatedLesson;
    var backedToDash = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MLPQuizArenaFlow(
          initialStep: 0,
          onBackToDashboard: () => backedToDash = true,
          onNavigateLesson: (topic) => navigatedLesson = topic,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 1: Bosh sahifa
    // -------------------------------------------------------------
    expect(find.text('Quiz Arena'), findsWidgets);
    expect(find.text('Jonli viktorina va tezkor\nbilim sinovi'), findsOneWidget);
    expect(find.text('PIN bilan qo‘shilish'), findsOneWidget);
    expect(find.text('QR orqali kirish'), findsOneWidget);
    expect(find.text('Mening o‘yinlarim'), findsOneWidget);
    expect(find.text('Diskret matematika'), findsWidgets);
    expect(find.text('124 talaba'), findsOneWidget);

    // Tap "Qo'shilish" button to go to Screen 2 (Lobby)
    final joinBtn = find.text('Qo‘shilish');
    expect(joinBtn, findsOneWidget);
    await tester.ensureVisible(joinBtn);
    await tester.tap(joinBtn);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 2: Qo'shilish (Lobbi)
    // -------------------------------------------------------------
    expect(find.text('O‘yinga qo‘shilish'), findsOneWidget);
    expect(find.text('O‘yin PIN-kodini kiriting'), findsOneWidget);
    expect(find.text('12 / 30'), findsOneWidget);
    expect(find.text('talaba qo‘shildi'), findsOneWidget);
    expect(find.text('O‘yin boshlanishiga:'), findsOneWidget);

    // Tap "Tayyor" to proceed to Screen 3 (Live Question)
    final readyBtn = find.text('Tayyor ✓');
    expect(readyBtn, findsOneWidget);
    await tester.ensureVisible(readyBtn);
    await tester.tap(readyBtn);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 3: Jonli savol
    // -------------------------------------------------------------
    expect(find.text('3 / 10'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.text('ball'), findsWidgets);
    expect(
      find.text('Grafda bog‘langanlikni tekshirish uchun qaysi algoritm qulay?'),
      findsOneWidget,
    );
    expect(find.text('BFS yoki DFS algoritmi'), findsOneWidget);
    expect(find.text('3 ta ketma-ket to‘g‘ri javob!'), findsOneWidget);

    // Select the correct answer (BFS yoki DFS)
    await tester.tap(find.text('BFS yoki DFS algoritmi'));
    await tester.pumpAndSettle();

    // Tap next to go to Screen 4 (Podium Results)
    final nextQuestionBtn = find.text('Keyingi savol →');
    expect(nextQuestionBtn, findsOneWidget);
    await tester.tap(nextQuestionBtn);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 4: Natijalar (Podium)
    // -------------------------------------------------------------
    expect(find.text('Natijalar'), findsOneWidget);
    expect(find.text('O. Anvar'), findsOneWidget);
    expect(find.text('980 ball'), findsOneWidget);
    expect(find.text('D. Sevinch'), findsOneWidget);
    expect(find.text('M. Aziz'), findsOneWidget);
    expect(find.text('Siz 5-o‘rindasiz'), findsOneWidget);
    expect(find.text('Jami: 760 ball  •  🏆 +120 XP'), findsOneWidget);
    expect(find.text('Graf nazariyasi'), findsWidgets);

    // Tap "Tahlilni ko'rish" button to go to Screen 5 (Analysis)
    final seeAnalysisBtn = find.text('Tahlilni ko‘rish');
    expect(seeAnalysisBtn, findsOneWidget);
    await tester.ensureVisible(seeAnalysisBtn);
    await tester.tap(seeAnalysisBtn);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 5: Tahlil va rivojlanish
    // -------------------------------------------------------------
    expect(find.text('Tahlil va rivojlanish'), findsOneWidget);
    expect(find.text('Umumiy aniqlik'), findsOneWidget);
    expect(find.text('8 / 10 to‘g‘ri javob'), findsOneWidget);
    expect(find.text('Xatolik qilingan savollar'), findsOneWidget);
    expect(find.text('Kuchsiz mavzu: Determinant'), findsOneWidget);
    expect(find.text('Tajribali (B2)'), findsOneWidget);

    // Tap weak topic recommendation card -> navigates to lesson
    final weakTopicCard = find.text('Kuchsiz mavzu: Determinant');
    await tester.ensureVisible(weakTopicCard);
    await tester.tap(weakTopicCard);
    await tester.pumpAndSettle();

    expect(navigatedLesson, 'Determinant');
  });
}
