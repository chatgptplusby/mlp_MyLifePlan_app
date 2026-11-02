import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mylife_plan/features/onboarding/mlp_campus_entry.dart';
void main() {
  testWidgets('Campus entry navigates, searches and persists university at narrow width', (t) async {
    SharedPreferences.setMockInitialValues({'existing_data':'preserve'});
    final prefs = await SharedPreferences.getInstance();
    t.view.devicePixelRatio = 1; t.view.physicalSize = const Size(320,640);
    addTearDown(t.view.resetPhysicalSize); addTearDown(t.view.resetDevicePixelRatio);
    var finished = false;
    await t.pumpWidget(MaterialApp(home: MLPCampusEntry(prefs: prefs, onComplete: () => finished = true)));
    Future<void> tap(String title) async {
      final f = find.text(title);
      await t.ensureVisible(f.last);
      await t.tap(f.last);
      await t.pumpAndSettle();
    }
    await tap('Boshlash');
    expect(find.text('O‘qishdan\nko‘proq natija\noling'), findsOneWidget);
    await tap('Davom etish');
    await t.enterText(find.byType(TextField).first, 'TATU'); await t.pumpAndSettle();
    await tap('TATU');
    FocusManager.instance.primaryFocus?.unfocus(); await t.pumpAndSettle();
    await tap('Davom etish');
    await t.runAsync(() => Future<void>.delayed(Duration.zero)); await t.pump();
    expect(finished, true);
    expect(prefs.getString(MLPCampusEntry.universityKey), 'TATU');
    expect(prefs.getString('existing_data'), 'preserve');
    expect(t.takeException(), isNull);
  });
}
