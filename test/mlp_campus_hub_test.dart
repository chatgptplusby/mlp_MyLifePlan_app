import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylife_plan/features/university/mlp_campus_hub.dart';

void main() {
  testWidgets('MLPCampusHub seamlessly connects all flows with shared logic', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MLPCampusHub(initialRoute: 'dashboard'),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Dashboard is active
    expect(find.text('MLP Campus'), findsWidgets);
    expect(find.text('Salom, Aziz!'), findsOneWidget);
    expect(find.text('Quiz Arena'), findsWidgets);
    expect(find.text('Mukofotlar'), findsWidgets);

    // 2. Navigate to Quiz Arena
    await tester.tap(find.text('Quiz Arena').first);
    await tester.pumpAndSettle();

    expect(find.text('Jonli viktorina va tezkor\nbilim sinovi'), findsOneWidget);
    expect(find.text('PIN bilan qo‘shilish'), findsOneWidget);

    // Back to Dashboard
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Salom, Aziz!'), findsOneWidget);

    // 3. Navigate to Mukofotlar (Market)
    await tester.tap(find.text('Mukofotlar').first);
    await tester.pumpAndSettle();

    expect(find.text('Mukofotlar do‘koni'), findsOneWidget);
    expect(find.text('2 450 coin'), findsOneWidget);

    // Back to Dashboard
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // 4. Navigate to Profile
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Azizbek Karimov'), findsOneWidget);
    expect(find.text('Hamkorlar va bonuslar'), findsOneWidget);

    // Open Screen 3 (Hamkorlar va bonuslar)
    await tester.tap(find.text('Hamkorlar va bonuslar'));
    await tester.pumpAndSettle();

    expect(find.text('Hamkorlar va bonuslar'), findsOneWidget);
    expect(find.text('Coin qanday ishlaydi?'), findsOneWidget);

    // Open "Coin qanday ishlaydi?" modal
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coin qanday ishlaydi?'));
    await tester.pumpAndSettle();

    expect(find.text('Vazifa va testlarni bajar'), findsOneWidget);
    expect(find.text('Coin yig‘'), findsWidgets);
    expect(find.text('Hamkorlar bonusini tanla'), findsOneWidget);
    expect(find.text('Voucher ol'), findsWidgets);
    expect(find.text('Lokatsiyaga borib foydalan'), findsOneWidget);
  });
}
