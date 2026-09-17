import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porfore/main.dart';
import 'package:porfore/pages/home_page.dart';
import 'package:porfore/widgets/loading_overlay.dart';

void main() {
  testWidgets('Cover blocks input and completes startup and locale cycles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // Decode in real async time so the test clock only controls playback.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.runAsync(
      () => precacheImage(
        LoadingOverlay.spriteImage,
        tester.element(find.byType(SizedBox).first),
      ),
    );
    await tester.pumpWidget(const MainApp());
    await tester.pump();
    expect(find.byType(LoadingOverlay), findsOneWidget);
    final barrier = tester.widget<ModalBarrier>(
      find.descendant(
        of: find.byType(LoadingOverlay),
        matching: find.byType(ModalBarrier),
      ),
    );
    expect(barrier.color, const Color(0xFFFFFFFF));
    expect(tester.getSize(find.byType(LoadingOverlay)), const Size(1200, 800));

    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byWidgetPredicate(
            (w) =>
                w is SingleChildScrollView &&
                w.scrollDirection == Axis.vertical,
          ),
        )
        .controller!;
    final dropdown = find.byType(DropdownButton<String>);
    await tester.tapAt(tester.getCenter(dropdown));
    await tester.dragFrom(const Offset(600, 500), const Offset(0, -200));
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(600, 500),
        scrollDelta: Offset(0, 200),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(scroll.offset, 0);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Loading overlay');
    expect(find.byType(LoadingOverlay), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LoadingOverlay), findsNothing);

    final home = tester.element(find.byType(HomePage));
    for (final code in ['ko', 'en', 'ja']) {
      final oldLocale = tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .locale;
      final change = tester
          .widget<HomePage>(find.byType(HomePage))
          .onLocaleChanged;
      change(Locale(code));
      change(const Locale('fr')); // A duplicate request must be ignored.
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        oldLocale,
      );
      await tester.pump();
      expect(find.byType(LoadingOverlay), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        oldLocale,
      );
      await tester.pump();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        Locale(code),
      );
      expect(find.byType(LoadingOverlay), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(LoadingOverlay), findsNothing);
      expect(tester.element(find.byType(HomePage)), same(home));
    }
    await tester.dragFrom(const Offset(600, 500), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    expect(find.text('KO'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
