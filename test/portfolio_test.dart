import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porfore/main.dart';
import 'package:porfore/l10n/app_localizations.dart';
import 'package:porfore/pages/pokemon_page.dart';
import 'package:porfore/sections/skills_section.dart';
import 'package:porfore/sections/career_section.dart';
import 'package:porfore/pages/home_page.dart';

void main() {
  testWidgets('Skills holds anchors without changing scroll offsets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    final career = tester.widget<CareerSection>(find.byType(CareerSection));
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          ),
        )
        .controller!;
    Future<double> progressAt(double raw) async {
      final offset = 800 + career.height + raw * 1600;
      scroll.jumpTo(offset);
      await tester.pump();
      expect(scroll.offset, closeTo(offset, 1e-8));
      return tester.widget<SkillsSection>(find.byType(SkillsSection)).progress;
    }

    for (final raw in [0.0, .06, .12]) {
      expect(await progressAt(raw), 0);
    }
    for (final raw in [.40, .43, .5, .57, .60, .55, .41]) {
      expect(await progressAt(raw), .5);
    }
    expect(await progressAt(.39), lessThan(.5));
    expect(await progressAt(.61), greaterThan(.5));
    for (final raw in [.88, .94, 1.0, .90]) {
      expect(await progressAt(raw), 1);
    }
    // Large jumps skip holds immediately, and reverse scrolling is symmetric.
    expect(await progressAt(0), 0);
    expect(await progressAt(1), 1);
    var previous = 1.0;
    for (var step = 100; step >= 0; step--) {
      final progress = await progressAt(step / 100);
      expect(progress, lessThanOrEqualTo(previous));
      expect((progress - previous).abs(), lessThan(.03));
      previous = progress;
    }
    final decorations = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/edgelayer.png',
    );
    expect(decorations, findsNWidgets(4));
    for (var i = 0; i < 4; i++) {
      expect(
        find.ancestor(
          of: decorations.at(i),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
      );
      final rotation = tester.widget<RotatedBox>(
        find.ancestor(of: decorations.at(i), matching: find.byType(RotatedBox)),
      );
      expect(rotation.quarterTurns, i);
      expect(
        tester.getSize(decorations.at(i)),
        tester.getSize(decorations.first),
      );
    }
    scroll.jumpTo(0);
    await tester.pump();
    final bottomCorner = find.ancestor(
      of: decorations.at(2),
      matching: find.byType(RotatedBox),
    );
    final initialTop = tester.getTopLeft(decorations.first);
    final initialBottom = tester.getBottomRight(bottomCorner);
    expect(initialTop.dy, greaterThanOrEqualTo(0));
    expect(initialBottom.dy, greaterThan(800));
    scroll.jumpTo(300);
    await tester.pump();
    expect(
      tester.getTopLeft(decorations.first).dy,
      closeTo(initialTop.dy - 300, 1e-8),
    );
    expect(
      tester.getBottomRight(bottomCorner).dy,
      closeTo(initialBottom.dy - 300, 1e-8),
    );
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    expect(tester.getTopLeft(decorations.first).dy, lessThan(0));
    expect(
      tester.getBottomRight(bottomCorner).dy,
      closeTo(800 - initialTop.dy, 1e-8),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Career fits all locales and scene uses its measured height', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [
      const Size(320, 400),
      const Size(390, 500),
      const Size(1200, 1600),
    ]) {
      await tester.binding.setSurfaceSize(size);
      for (final language in ['ja', 'ko', 'en']) {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomePage(onLocaleChanged: (_) {}),
          ),
        );
        await tester.pumpAndSettle();
        final career = tester.widget<CareerSection>(find.byType(CareerSection));
        expect(career.height, greaterThanOrEqualTo(size.height));
        expect(
          career.height,
          greaterThanOrEqualTo(career.layout.contentHeight),
        );
        if (size.height == 1600) expect(career.height, size.height);
        final document = tester.widget<SingleChildScrollView>(
          find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          ),
        );
        final start = size.height + career.height;
        document.controller!.jumpTo(start);
        await tester.pump();
        expect(
          tester.widget<SkillsSection>(find.byType(SkillsSection)).progress,
          0,
        );
        document.controller!.jumpTo(start + size.height);
        await tester.pump();
        expect(
          tester.widget<SkillsSection>(find.byType(SkillsSection)).progress,
          .5,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('Chaos is fresh per mount, collision-free and stable on resize', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final items = find.byWidgetPredicate(
      (widget) => widget is Positioned && widget.key is ValueKey<String>,
    );
    Future<void> pose(double progress, {Locale locale = const Locale('ja')}) =>
        tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SkillsSection(progress: progress)),
          ),
        );
    List<Rect> rectangles() => [
      for (var i = 0; i < items.evaluate().length; i++)
        tester.getRect(items.at(i)),
    ];
    void checkCollisions(List<Rect> rects) {
      expect(rects, hasLength(25));
      for (var i = 0; i < rects.length; i++) {
        for (var j = i + 1; j < rects.length; j++) {
          expect(rects[i].overlaps(rects[j]), isFalse);
        }
      }
    }

    List<Rect>? previous;
    List<Rect>? graph;
    List<Rect>? categories;
    for (var mount = 0; mount < 40; mount++) {
      await tester.binding.setSurfaceSize(const Size(808, 700));
      await pose(0);
      await tester.pumpAndSettle();
      final initial = rectangles();
      checkCollisions(initial);
      if (previous != null) expect(initial, isNot(previous));
      previous = initial;
      final elements = items.evaluate().toList();
      for (final progress in [.3, .5, .7, 1.0, .5, 0.0]) {
        await pose(progress);
        expect(items.evaluate().toList(), elements);
        if (progress == .5) {
          if (graph != null) expect(rectangles(), graph);
          graph = rectangles();
        }
        if (progress == 1) {
          if (categories != null) expect(rectangles(), categories);
          categories = rectangles();
        }
      }
      expect(rectangles(), initial);
      await pose(0, locale: const Locale('ko'));
      await tester.pumpAndSettle();
      expect(rectangles(), initial);
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      await tester.pump();
      checkCollisions(rectangles());
      await tester.binding.setSurfaceSize(const Size(390, 700));
      await tester.pump();
      checkCollisions(rectangles());
      await tester.binding.setSurfaceSize(const Size(808, 700));
      await tester.pump();
      expect(rectangles(), initial);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Skills keep their elements through all poses and reverse', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Future<void> pose(double progress) => tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SkillsSection(progress: progress)),
      ),
    );
    await pose(0);
    await tester.pumpAndSettle();
    final flutter = tester.element(find.text('Flutter'));
    final initial = tester.getTopLeft(find.text('Flutter'));
    for (final progress in [.3, .5, .7, 1.0, .5, 0.0]) {
      await pose(progress);
      expect(identical(tester.element(find.text('Flutter')), flutter), isTrue);
      expect(find.text('Flutter'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (progress == .5) {
        expect(tester.getTopLeft(find.text('Flutter')), isNot(initial));
      }
    }
    expect(tester.getTopLeft(find.text('Flutter')), initial);
  });

  testWidgets('Narrow viewport scrolls to credits and opens Pokemon Lab', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    expect(find.text('JA'), findsOneWidget);
    final document = tester.widget<SingleChildScrollView>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.vertical,
      ),
    );
    for (final offset in [700.0, 1600.0, 2300.0, 3000.0, 3700.0]) {
      document.controller!.jumpTo(offset);
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.text('Pokemon Lab'));
    await tester.pumpAndSettle();
    expect(find.byType(PokemonPage), findsOneWidget);
  });
  testWidgets(
    'Locale changes preserve skill identity and geometry at equal progress',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('ja'),
      );
      final context = tester.element(find.byType(SkillsSection));
      expect(AppLocalizations.of(context)!.career2019Title, '大邱大学校 卒業');
      final document = tester.widget<SingleChildScrollView>(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.vertical,
        ),
      );
      final controller = document.controller!;
      for (final offset in [2300.0, 3000.0]) {
        controller.jumpTo(offset);
        await tester.pump();
        final itemFinder = find.byKey(const ValueKey('Rendering Pipeline'));
        final itemElement = tester.element(itemFinder);
        final position = tester.getTopLeft(itemFinder);
        final size = tester.getSize(itemFinder);
        final initialCareerHeight = tester
            .widget<CareerSection>(find.byType(CareerSection))
            .height;
        for (final language in ['en', 'ko', 'ja']) {
          final previousOffset = controller.offset;
          await tester.tap(find.byType(DropdownButton<String>));
          await tester.pumpAndSettle();
          await tester.tap(find.text(language.toUpperCase()).last);
          await tester.pumpAndSettle();
          expect(
            tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
            Locale(language),
          );
          expect(Localizations.localeOf(context), Locale(language));
          final l10n = AppLocalizations.of(context)!;
          final expectedTitle = switch (language) {
            'en' => 'Graduated from Daegu University',
            'ko' => '대구대학교 졸업',
            _ => '大邱大学校 卒業',
          };
          expect(l10n.career2019Title, expectedTitle);
          expect(find.text(expectedTitle), findsOneWidget);
          expect(find.text(l10n.experienceAxis), findsOneWidget);
          expect(find.text(l10n.frameworkEngine), findsOneWidget);
          expect(find.text('Rendering Pipeline'), findsOneWidget);
          expect(find.text('Flutter'), findsOneWidget);
          expect(controller.offset, previousOffset);
          final careerHeight = tester
              .widget<CareerSection>(find.byType(CareerSection))
              .height;
          controller.jumpTo(offset + careerHeight - initialCareerHeight);
          await tester.pump();
          expect(identical(tester.element(itemFinder), itemElement), isTrue);
          expect(tester.getTopLeft(itemFinder), position);
          expect(tester.getSize(itemFinder), size);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
}
