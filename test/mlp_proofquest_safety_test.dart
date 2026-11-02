import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mylife_plan/demo/demo_store.dart';
import 'package:mylife_plan/data/repositories/mlp_ui_repository.dart';
import 'package:mylife_plan/features/university/mlp_university_edition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late DemoStore store;
  late MLPLocalUiRepository ui;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = DemoStore(prefs);
    await store.init();
    ui = MLPLocalUiRepository(prefs);
    await ui.init();
  });
  tearDown(() {
    store.dispose();
    ui.dispose();
  });
  testWidgets('empty result and passport never award L3 or credits', (t) async {
    for (final page in [6, 7]) {
      await t.pumpWidget(
        MaterialApp(
          home: MLPUniversityHub(
            key: ValueKey(page),
            store: store,
            ui: ui,
            initialScreenIndex: page,
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Hali sinov natijasi yo‘q'), findsOneWidget);
      expect(find.text('L3'), findsNothing);
      expect(find.text('+300 XP · +50 kredit'), findsNothing);
      expect(t.takeException(), isNull);
    }
  });
  testWidgets(
    'saved partial score is shown accurately after repository restart',
    (t) async {
      await t.runAsync(
        () => ui.saveAssessment(
          quiz: 'Chiziqli algebra (Matritsalar)',
          correct: 2,
          total: 3,
          at: DateTime(2026, 11, 2),
          taskId: 'task-linear-algebra-mission',
        ),
      );
      final restored = MLPLocalUiRepository(prefs);
      await t.runAsync(restored.init);
      await t.pumpWidget(
        MaterialApp(
          home: MLPUniversityHub(
            store: store,
            ui: restored,
            initialScreenIndex: 7,
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('3 savoldan 2 tasi to‘g‘ri'), findsOneWidget);
      expect(find.text('L3'), findsNothing);
      await t.pumpWidget(const SizedBox());
      restored.dispose();
    },
  );
  test(
    'invalid evidence does not complete mission; duplicate valid submission does not add XP',
    () async {
      const id = 'task-linear-algebra-mission';
      expect(() => store.submitTask(id, 'x'), throwsArgumentError);
      expect(store.tasks.firstWhere((t) => t.id == id).completed, false);
      await store.submitTask(id, 'Matritsa masalalarini yechdim.');
      final xp = store.xp;
      await store.submitTask(id, 'Matritsa masalalarini yechdim.');
      expect(store.xp, xp);
      final restored = DemoStore(prefs);
      await restored.init();
      expect(
        restored.tasks.firstWhere((t) => t.id == id).proof,
        'Matritsa masalalarini yechdim.',
      );
      restored.dispose();
    },
  );
  testWidgets('challenge UI records two correct answers as two, not three', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: MLPUniversityHub(store: store, ui: ui, initialScreenIndex: 4),
      ),
    );
    await t.pumpAndSettle();
    for (final choice in [
      'Satr/ustun almashtirilsa belgisi o‘zgaradi',
      '10',
      '0',
    ]) {
      await t.ensureVisible(find.text(choice));
      await t.tap(find.text(choice));
      await t.pumpAndSettle();
      final next = find.text(
        choice == '0' ? 'Natijani ko‘rish (Proof Level)' : 'Keyingi savol',
      );
      await t.ensureVisible(next);
      await t.tap(next);
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await t.pumpAndSettle();
    }
    expect(ui.assessments.single['correct'], 2);
    expect(find.text('3 savoldan 2 tasi to‘g‘ri'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
