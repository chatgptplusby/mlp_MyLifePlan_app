import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylife_plan/features/university/mlp_campus_profile_flow.dart';

void main() {
  testWidgets('Profile & Communication ecosystem renders 1:1 and navigates end-to-end', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MLPCampusProfileFlow(initialScreen: 0),
      ),
    );
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 1: Profil
    // -------------------------------------------------------------
    expect(find.text('Azizbek Karimov'), findsOneWidget);
    expect(find.text('FarDU • Informatika • 2-semestr'), findsOneWidget);
    expect(find.text('Lv. 4'), findsOneWidget);
    expect(find.text('1 250 / 2 000 XP'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Kun ketma-ket'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Yutuq'), findsOneWidget);
    expect(find.text('Mening yutuqlarim'), findsOneWidget);
    expect(find.text('Hamkorlar va bonuslar'), findsOneWidget);
    expect(find.text('Ma‘muriyatga murojaat'), findsOneWidget);

    // -------------------------------------------------------------
    // Screen 2: Mening yutuqlarim
    // -------------------------------------------------------------
    await tester.tap(find.text('Mening yutuqlarim'));
    await tester.pumpAndSettle();

    expect(find.text('Bilimdon talaba'), findsOneWidget);
    expect(find.text('5 ta fan bo‘yicha 70%+ natija'), findsOneWidget);
    expect(find.text('Izchil o‘quvchi'), findsOneWidget);
    expect(find.text('Test ustasi'), findsOneWidget);

    // Back to Profile
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 3: Hamkorlar va bonuslar
    // -------------------------------------------------------------
    await tester.tap(find.text('Hamkorlar va bonuslar'));
    await tester.pumpAndSettle();

    expect(find.text('Dodo Pizza'), findsOneWidget);
    expect(find.text('Asaxiy'), findsOneWidget);
    expect(find.text('Najot Ta‘lim'), findsOneWidget);

    // Tap Dodo Pizza to open Screen 4 (Detail)
    await tester.tap(find.text('Dodo Pizza'));
    await tester.pumpAndSettle();

    expect(find.text('15% chegirma'), findsOneWidget);
    expect(find.text('🪙 800 coin'), findsOneWidget);
    expect(find.text('Voucher olish (800 coin)'), findsOneWidget);

    // Back twice to Profile
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 6: Ma'muriyatga murojaat
    // -------------------------------------------------------------
    await tester.tap(find.text('Ma‘muriyatga murojaat'));
    await tester.pumpAndSettle();

    expect(find.text('Rektor'), findsOneWidget);
    expect(find.text('Universitet boshqaruvchisi'), findsOneWidget);
    expect(find.text('Zamdekan'), findsOneWidget);
    expect(find.text('Dekanat'), findsOneWidget);
    expect(find.text('O‘qituvchi'), findsOneWidget);

    // Tap Rektor to open Screen 7 (1:1 Chat)
    await tester.tap(find.text('Rektor'));
    await tester.pumpAndSettle();

    expect(find.text('Onlayn'), findsOneWidget);
    expect(find.text('Bugun'), findsOneWidget);

    // Send a new message
    await tester.enterText(find.byType(TextField), 'Rahmat, kutyapman!');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Rahmat, kutyapman!'), findsOneWidget);

    // Back to Administration Hub
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // Tap Zamdekan to open Screen 8 (Murojaat shakli)
    await tester.tap(find.text('Zamdekan'));
    await tester.pumpAndSettle();

    expect(find.text('Murojaat shakli'), findsOneWidget);
    expect(find.text('Taklif.pdf'), findsOneWidget);

    // Submit petition
    await tester.tap(find.text('Yuborish'));
    await tester.pumpAndSettle();

    // Should now be on Screen 9: Mening murojaatlarim
    expect(find.text('Mening murojaatlarim'), findsOneWidget);
    expect(find.text('Wi-Fi qamrovini kengaytirish'), findsOneWidget);
    expect(find.text('Yakunlangan'), findsWidgets);
    expect(find.text('Jarayonda'), findsWidgets);
  });
}
