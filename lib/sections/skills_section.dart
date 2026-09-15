import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class _Skill {
  const _Skill(this.name, this.category, this.experience, this.proficiency);
  final String name;
  final int category;
  final double experience, proficiency;
}

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key, required this.progress});
  final double progress;

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  static const chipWidth = 154.0;
  static const chipHeight = 30.0;
  late final Map<String, Offset> _chaosPositions;

  @override
  void initState() {
    super.initState();
    _chaosPositions = _generateChaosPositions();
  }

  static Offset _generateRandomPosition(math.Random random) =>
      Offset(random.nextDouble(), random.nextDouble());

  static Map<String, Offset> _generateChaosPositions() {
    final queue = Queue<String>.of(_skills.map((skill) => skill.name));
    final int skillCount = queue.length;
    final positions = <Offset>[];
    final occupied = <Rect>[];
    final random = math.Random();
    const maxAttempts = 1000;
    const minGap = 4.0;
    // Use the existing minimum canvas (760 x (700 - 80 - 90)).
    // Larger canvases only increase separation; resize never regenerates layout.
    Rect rectFor(Offset position) => Rect.fromLTWH(
      position.dx * (760 - chipWidth - 24),
      position.dy * (530 - 120),
      chipWidth,
      chipHeight,
    );

    while (positions.length < skillCount) {
      var bestCandidate = Offset.zero;
      var leastOverlap = double.infinity;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final candidate = _generateRandomPosition(random);
        final candidateRect = rectFor(candidate);
        var overlap = 0.0;
        for (final existing in occupied) {
          final padded = existing.inflate(minGap);
          if (candidateRect.overlaps(padded)) {
            final intersection = candidateRect.intersect(padded);
            overlap += intersection.width * intersection.height;
          }
        }
        if (overlap < leastOverlap) {
          bestCandidate = candidate;
          leastOverlap = overlap;
        }
        if (overlap == 0) break;
      }
      // Bounded fallback: retain the least-overlapping in-bounds candidate.
      // If future data exhausts available space, some overlap is unavoidable.
      // Previously accepted positions are never discarded or moved.
      positions.add(bestCandidate);
      occupied.add(rectFor(bestCandidate));
    }
    return Map.unmodifiable({
      for (final position in positions) queue.removeFirst(): position,
    });
  }

  // TODO: Replace experience/proficiency with confirmed self-assessments.
  // ALL values are temporary animation/layout fixtures, not final ratings.
  // Previously listed skills retain their existing values.
  static const _skills = [
    _Skill('C / C++', 0, .68, .82),
    _Skill('C#', 0, .85, .74),
    _Skill('Java', 0, .38, .64),
    _Skill('Dart', 0, .54, .49),
    _Skill('JavaScript', 0, .18, .56),
    _Skill('HTML', 1, .32, .72),
    _Skill('CSS', 1, .48, .58),
    _Skill('SQL', 1, .24, .42),
    _Skill('Flutter', 2, .76, .35),
    _Skill('Spring', 2, .62, .66),
    _Skill('React', 2, .80, .16),
    _Skill('Node.js', 2, .70, .08),
    _Skill('Unity', 2, .91, .91),
    _Skill('Godot', 2, .10, .30),
    _Skill('DirectX', 3, .42, .91),
    _Skill('OpenGL', 3, .56, .80),
    _Skill('Rendering Pipeline', 3, .30, .08),
    _Skill('Git', 4, .91, .55),
    _Skill('Docker', 4, .38, .24),
    _Skill('npm', 4, .64, .46),
    _Skill('Visual Studio', 4, .82, .80),
    _Skill('VS Code', 4, .94, .40),
    _Skill('Data Structures', 5, .57, .18),
    _Skill('Algorithms', 5, .22, .92),
    _Skill('Networking', 5, .12, .76),
  ];

  // Hold each pose briefly. Both transitions use the same keyed item tree.
  static double _phase(double p, double start, double end) =>
      Curves.easeInOut.transform(((p - start) / (end - start)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      l10n.languages,
      l10n.webData,
      l10n.frameworkEngine,
      l10n.graphics,
      l10n.toolsEnvironment,
      l10n.knowledge,
    ];
    final state = widget.progress < .275
        ? l10n.chaos
        : widget.progress < .725
        ? l10n.graph
        : l10n.categories;
    final toGraph = _phase(widget.progress, .10, .45);
    final toCategories = _phase(widget.progress, .55, .90);
    final graphOpacity = toGraph * (1 - toCategories);
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 90),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // A horizontally scrollable minimum canvas preserves readable labels on
            // narrow browser windows without changing the document scroll axis.
            final width = math.max(760.0, constraints.maxWidth);
            final height = constraints.maxHeight;
            final plot = Rect.fromLTWH(60, 95, width - 220, height - 170);
            const gap = 16.0;
            final boxWidth = (width - gap * 2) / 3;
            final boxHeight = (height - 80 - gap) / 2;
            Rect categoryRect(int category) => Rect.fromLTWH(
              (category % 3) * (boxWidth + gap),
              64 + (category ~/ 3) * (boxHeight + gap),
              boxWidth,
              boxHeight,
            );
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Text(
                        l10n.skillsHeading(l10n.skills, state),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: graphOpacity,
                        child: CustomPaint(painter: _GraphPainter(plot)),
                      ),
                    ),
                    Positioned(
                      left: plot.left,
                      bottom: 0,
                      child: Opacity(
                        opacity: graphOpacity,
                        child: Text(l10n.experienceAxis),
                      ),
                    ),
                    Positioned(
                      left: plot.left,
                      top: 56,
                      child: Opacity(
                        opacity: graphOpacity,
                        child: Text(l10n.proficiencyAxis),
                      ),
                    ),
                    for (var c = 0; c < categories.length; c++)
                      Positioned.fromRect(
                        rect: categoryRect(c),
                        child: Opacity(
                          opacity: toCategories,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - toCategories)),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueGrey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  height: 20,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      categories[c],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    for (var i = 0; i < _skills.length; i++)
                      _item(
                        i,
                        width,
                        height,
                        plot,
                        categoryRect(_skills[i].category),
                        toGraph,
                        toCategories,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _item(
    int index,
    double width,
    double height,
    Rect plot,
    Rect category,
    double toGraph,
    double toCategories,
  ) {
    final skill = _skills[index];
    final normalizedChaos = _chaosPositions[skill.name]!;
    final chaos = Offset(
      12 + normalizedChaos.dx * math.max(0.0, width - chipWidth - 24),
      75 + normalizedChaos.dy * math.max(0.0, height - 120),
    );
    final graph = Offset(
      plot.left + skill.experience * plot.width - chipWidth / 2,
      plot.bottom - skill.proficiency * plot.height - chipHeight / 2,
    );
    final row = _skills
        .take(index)
        .where((s) => s.category == skill.category)
        .length;
    final categorized = Offset(
      category.left + 12,
      category.top + 40 + row * 34,
    );
    final position = Offset.lerp(
      Offset.lerp(chaos, graph, toGraph),
      categorized,
      toCategories,
    )!;
    return Positioned(
      key: ValueKey(skill.name),
      left: position.dx,
      top: position.dy,
      width: lerpDouble(chipWidth, category.width - 24, toCategories),
      height: chipHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(
            Colors.transparent,
            const Color(0xffd4e2de),
            toCategories,
          ),
          borderRadius: BorderRadius.circular(lerpDouble(16, 4, toCategories)!),
          // Preserve category decoration; Chaos/Graph remain transparent.
          border: Border.all(
            color: Colors.blueGrey.withValues(alpha: .35 * toCategories),
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              skill.name,
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  const _GraphPainter(this.plot);
  final Rect plot;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xffced5d2)
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      final x = plot.left + plot.width * i / 4;
      final y = plot.bottom - plot.height * i / 4;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), grid);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
    }
    final axis = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(plot.center.dx, plot.top),
      Offset(plot.center.dx, plot.bottom),
      axis,
    );
    canvas.drawLine(
      Offset(plot.left, plot.center.dy),
      Offset(plot.right, plot.center.dy),
      axis,
    );
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) => oldDelegate.plot != plot;
}
