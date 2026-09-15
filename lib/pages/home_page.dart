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
  double get documentHeight => creditsStart + height;
  List<double> get starts => [0, height, skillsStart, creditsStart];
  double progress(double offset) {
    final raw = ((offset - skillsStart) / travel).clamp(0.0, 1.0);
    // Dead zones hold complete poses without moving the browser scroll offset.
    // Smoothstep has zero slope at each boundary, easing into and out of holds.
    double transition(double start, double end) {
      final t = ((raw - start) / (end - start)).clamp(0.0, 1.0);
      return t * t * (3 - 2 * t);
    }

    if (raw <= .12) return 0;
    if (raw < .40) return .5 * transition(.12, .40);
    if (raw <= .60) return .5;
    if (raw < .88) return .5 + .5 * transition(.60, .88);
    return 1;
  }

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
  final _documentLayer = LayerLink();

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
    backgroundColor: Colors.white,
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
                  child: CompositedTransformTarget(
                    link: _documentLayer,
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
                    child: SizedBox(
                      width: math.min(440, constraints.maxWidth - 36),
                      child: Row(
                        children: [
                          for (var i = 0; i < sections.length; i++)
                            Expanded(
                              child: _NavigationItem(
                                label: sections[i],
                                active: i == active,
                                onPressed: () => _scroll.animateTo(
                                  scene.starts[i].clamp(
                                    0.0,
                                    _scroll.position.maxScrollExtent,
                                  ),
                                  duration: const Duration(milliseconds: 650),
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Paint above navigation, but anchor to the scrolling document.
                // The linked transform follows its actual scroll translation.
                Positioned(
                  left: 0,
                  top: 0,
                  width: constraints.maxWidth,
                  height: scene.documentHeight,
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: CompositedTransformFollower(
                        link: _documentLayer,
                        showWhenUnlinked: false,
                        child: _CornerDecoration(size: constraints.biggest),
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

class _CornerDecoration extends StatelessWidget {
  const _CornerDecoration({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    final horizontalInset = (size.width * .02).clamp(8.0, 32.0);
    final verticalInset = (size.height * .02).clamp(8.0, 24.0);
    final extent = (size.shortestSide * .18).clamp(56.0, 144.0);
    return Stack(
      children: [
        for (var corner = 0; corner < 4; corner++)
          Positioned(
            left: corner == 0 || corner == 3 ? horizontalInset : null,
            right: corner == 1 || corner == 2 ? horizontalInset : null,
            top: corner < 2 ? verticalInset : null,
            bottom: corner >= 2 ? verticalInset : null,
            width: extent,
            height: extent,
            child: RotatedBox(
              quarterTurns: corner,
              child: Image.asset(
                'assets/images/edgelayer.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavigationItem extends StatefulWidget {
  const _NavigationItem({
    required this.label,
    required this.active,
    required this.onPressed,
  });
  final String label;
  final bool active;
  final VoidCallback onPressed;
  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final emphasized = widget.active || _hovered || _focused;
    return TextButton(
      onHover: (value) => setState(() => _hovered = value),
      onFocusChange: (value) => setState(() => _focused = value),
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        backgroundColor: Colors.transparent,
        overlayColor: Colors.transparent,
        shadowColor: Colors.transparent,
        side: BorderSide.none,
      ),
      child: AnimatedSlide(
        offset: Offset(
          0,
          _hovered || _focused
              ? -.18
              : widget.active
              ? 0
              : .18,
        ),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: emphasized
                ? const Color(0xff171717)
                : const Color(0xff777777),
          ),
          child: FittedBox(child: Text(widget.label)),
        ),
      ),
    );
  }
}
