import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mylife_plan/features/onboarding/mlp_campus_entry.dart';
import 'package:mylife_plan/features/university/mlp_campus_dashboard.dart';
import 'package:mylife_plan/features/university/mlp_university_edition.dart';

void main() {
  testWidgets('Campus Dashboard renders 1:1 with all elements and callbacks', (tester) async {
    SharedPreferences.setMockInitialValues({
      MLPCampusEntry.universityKey: 'FarDU',
    });
    final prefs = await SharedPreferences.getInstance();

    String? navigatedSubject;
    var quizOpened = false;
    var missionOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MLPCampusDashboard(
          prefs: prefs,
          onNavigateSubject: (sub) => navigatedSubject = sub,
          onNavigateQuiz: () => quizOpened = true,
          onNavigateMission: () => missionOpened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('MLP Campus'), findsOneWidget);
    expect(find.text('Universitet ta\'lim platformasi'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Bell notification badge

    // 2. Greeting & Level
    expect(find.text('Salom, Aziz!'), findsOneWidget);
    expect(find.text('FarDU • 2-semestr'), findsOneWidget);
    expect(find.text('Lv. 4'), findsOneWidget);
    expect(find.text('1 250 / 2 000 XP'), findsOneWidget);

    // 3. Quick Action Cards
    expect(find.text('Mening\nfanlarim'), findsOneWidget);
    expect(find.text('Vazifalar'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // Task badge
    expect(find.text('Quiz Arena'), findsOneWidget);
    expect(find.text('Mukofotlar'), findsOneWidget);

    // 4. "Bugungi darslar" Card
    expect(find.text('Bugungi darslar'), findsOneWidget);
    expect(find.text('Seshanba, 3 noyabr'), findsOneWidget);
    expect(find.text('Kompyuter tarmoqlari'), findsOneWidget);
    expect(find.text('Elektronika va sxemalar'), findsOneWidget);
    expect(find.text('Ma’lumotlar bazasi'), findsOneWidget);
    expect(find.text('8A-214'), findsOneWidget);
    expect(find.text('8A-117'), findsOneWidget);
    expect(find.text('8A-115'), findsOneWidget);

    // 5. "Bugungi vazifa" and "Haftalik progress"
    expect(find.text('Bugungi vazifa'), findsOneWidget);
    expect(find.text('Chiziqli algebra'), findsOneWidget);
    expect(find.text('1. Determinant mavzusi\nbo‘yicha mini-test'), findsOneWidget);
    expect(find.text('~ 15 daqiqa'), findsOneWidget);
    expect(find.text('Bajarish'), findsOneWidget);
    expect(find.text('Haftalik progress'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);

    // 6. Test interaction: tap "Bajarish" triggers quiz callback
    await tester.ensureVisible(find.text('Bajarish'));
    await tester.tap(find.text('Bajarish'));
    await tester.pumpAndSettle();
    expect(quizOpened, isTrue);

    // 7. Test interaction: tap a class triggers subject callback
    await tester.ensureVisible(find.text('Kompyuter tarmoqlari'));
    await tester.tap(find.text('Kompyuter tarmoqlari'));
    await tester.pumpAndSettle();
    expect(navigatedSubject, 'Kompyuter tarmoqlari');

    // 8. Test interaction: tap "Vazifalar" triggers mission callback
    await tester.ensureVisible(find.text('Vazifalar'));
    await tester.tap(find.text('Vazifalar'));
    await tester.pumpAndSettle();
    expect(missionOpened, isTrue);
  });

  testWidgets('Campus Dashboard seamlessly integrated into MLPUniversityHub', (tester) async {
    SharedPreferences.setMockInitialValues({
      MLPCampusEntry.universityKey: 'TATU',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MaterialApp(
        home: MLPUniversityHub(
          initialScreenIndex: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Screen 1 Bosh sahifa is the new dashboard
    expect(find.text('MLP Campus'), findsWidgets);
    expect(find.text('Bugungi darslar'), findsOneWidget);
    expect(find.text('Quiz Arena'), findsWidgets);
  });
}
