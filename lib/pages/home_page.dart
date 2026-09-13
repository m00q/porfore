import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/scroll_reveal.dart';
import '../sections/career_section.dart';
import '../sections/credits_section.dart';
import '../sections/intro_section.dart';
import '../sections/skills_section.dart';
import 'pokemon_page.dart';

// Single source of truth for section offsets and pinned scene progress.
class _ScrollScene {
  _ScrollScene(Size size, double requiredCareerContentHeight)
    : height = size.height,
      bioHeight = math.max(size.height, requiredCareerContentHeight),
      stageHeight = math.max(size.height, 700);
  final double height;
  final double bioHeight;
  final double stageHeight;
  double get skillsStart => height + bioHeight;
  double get travel => height * 2;
  double get creditsStart => skillsStart + stageHeight + travel;
  List<double> get starts => [0, height, skillsStart, creditsStart];
  double progress(double offset) =>
      ((offset - skillsStart) / travel).clamp(0.0, 1.0);
  double pinOffset(double offset) => (offset - skillsStart).clamp(0.0, travel);
  int active(double offset) =>
      starts.lastIndexWhere((start) => offset + height * .35 >= start);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onLocaleChanged});
  final ValueChanged<Locale> onLocaleChanged;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openPokemon() => Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const PokemonPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .025),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff4f3ef),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final careerLayout = CareerLayout.measure(
          context,
          constraints.maxWidth,
        );
        final scene = _ScrollScene(
          constraints.biggest,
          careerLayout.contentHeight,
        );
        final l10n = AppLocalizations.of(context)!;
        final sections = [l10n.home, l10n.bio, l10n.skills, l10n.credits];
        return AnimatedBuilder(
          animation: _scroll,
          builder: (context, child) {
            final offset = _scroll.hasClients ? _scroll.offset : 0.0;
            final active = scene.active(offset);
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scroll,
                  child: Column(
                    children: [
                      ScrollReveal(
                        top: 0,
                        height: scene.height,
                        offset: offset,
                        viewportHeight: scene.height,
                        child: IntroSection(height: scene.height),
                      ),
                      CareerSection(
                        layout: careerLayout,
                        height: scene.bioHeight,
                        top: scene.height,
                        offset: offset,
                        viewportHeight: scene.height,
                      ),
                      SizedBox(
                        height: scene.stageHeight + scene.travel,
                        child: Stack(
                          children: [
                            Positioned(
                              top: scene.pinOffset(offset),
                              left: 0,
                              right: 0,
                              height: scene.stageHeight,
                              child: SkillsSection(
                                progress: scene.progress(offset),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScrollReveal(
                        top: scene.creditsStart,
                        height: scene.height,
                        offset: offset,
                        viewportHeight: scene.height,
                        child: CreditsSection(
                          height: scene.height,
                          onPokemon: _openPokemon,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 16,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: Localizations.localeOf(context).languageCode,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final language in const ['ja', 'en', 'ko'])
                            DropdownMenuItem(
                              value: language,
                              child: Text(language.toUpperCase()),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            widget.onLocaleChanged(Locale(value));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 12,
                  right: 12,
                  child: Center(
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SizedBox(
                          width: math.min(440, constraints.maxWidth - 36),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < sections.length; i++)
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      minimumSize: const WidgetStatePropertyAll(
                                        Size(0, 44),
                                      ),
                                      padding: const WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      foregroundColor: WidgetStatePropertyAll(
                                        i == active
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      backgroundColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                              WidgetState.hovered,
                                            )) {
                                              return i == active
                                                  ? Colors.blueGrey
                                                  : Colors.black12;
                                            }
                                            return i == active
                                                ? Colors.black87
                                                : Colors.transparent;
                                          }),
                                    ),
                                    onPressed: () => _scroll.animateTo(
                                      scene.starts[i].clamp(
                                        0.0,
                                        _scroll.position.maxScrollExtent,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 650,
                                      ),
                                      curve: Curves.easeInOut,
                                    ),
                                    child: FittedBox(child: Text(sections[i])),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
