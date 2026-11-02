import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylife_plan/features/university/mlp_campus_market_flow.dart';

void main() {
  testWidgets('Market flow renders store, detail, purchases coupon, and displays wallet', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var backed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MLPCampusMarketFlow(
          initialScreen: 0,
          onBackToDashboard: () => backed = true,
          initialCoins: 2450,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 1: Mukofotlar do'koni
    // -------------------------------------------------------------
    expect(find.text('Mukofotlar do‘koni'), findsOneWidget);
    expect(find.text('2 450 coin'), findsOneWidget);
    expect(find.text('Kafeda qahva kuponi'), findsOneWidget);
    expect(find.text('Kitob xaridi uchun voucher'), findsOneWidget);
    expect(find.text('Kursga 20% chegirma'), findsOneWidget);

    // Scroll slightly to verify 4th item
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(find.text('Kantselyariya to‘plami'), findsOneWidget);

    // Scroll back up and tap "Olish" on first item
    await tester.drag(find.byType(ListView), const Offset(0, 150));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Olish').first);
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 2: Bonus tafsiloti
    // -------------------------------------------------------------
    expect(find.text('Bonus tafsiloti'), findsOneWidget);
    expect(find.text('500 coin'), findsOneWidget);
    expect(find.text('Filiallar'), findsOneWidget);
    // Scroll down to reveal "Kod olish (kupon)"
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Kod olish (kupon)'), findsOneWidget);

    // Tap "Kod olish (kupon)" -> Dialog opens and coins deducted
    await tester.tap(find.text('Kod olish (kupon)'));
    await tester.pumpAndSettle();

    expect(find.text('Kupon olindi!'), findsOneWidget);
    expect(find.text('Yopish'), findsOneWidget);

    // Dismiss dialog
    await tester.tap(find.text('Yopish'));
    await tester.pumpAndSettle();

    // -------------------------------------------------------------
    // Screen 5: Mening coinlarim (Wallet via bottom nav)
    // -------------------------------------------------------------
    await tester.tap(find.text('Hamyon'));
    await tester.pumpAndSettle();

    expect(find.text('Mening coinlarim'), findsOneWidget);
    expect(find.text('1 950 coin'), findsOneWidget); // 2450 - 500 = 1950
    expect(find.text('+750'), findsOneWidget);
    expect(find.text('Tarix'), findsOneWidget);
    expect(find.text('Vazifa: Darsga qatnashish'), findsOneWidget);
  });
}
