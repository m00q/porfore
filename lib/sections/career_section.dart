import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/scroll_reveal.dart';

// Shared by the scene and timeline so their heights and reveal offsets agree.
class CareerLayout {
  CareerLayout._(this.entries, this.headingHeight, this.rowHeights);

  final List<(String, String, String)> entries;
  final double headingHeight;
  final List<double> rowHeights;
  double get contentHeight =>
      90 + headingHeight + 40 + rowHeights.fold(0.0, (sum, h) => sum + h);
  double rowTop(int index) =>
      90 +
      headingHeight +
      40 +
      rowHeights.take(index).fold(0.0, (sum, h) => sum + h);

  factory CareerLayout.measure(BuildContext context, double width) {
    final l10n = AppLocalizations.of(context)!;
    final entries = [
      ('2019', l10n.career2019Title, l10n.career2019Description),
      (
        '2019',
        l10n.career2019TrainingTitle,
        l10n.career2019TrainingDescription,
      ),
      ('2023', l10n.career2023Title, l10n.career2023Description),
      ('2025', l10n.career2025Title, l10n.career2025Description),
      ('2026', l10n.career2026Title, l10n.career2026Description),
    ];
    final contentWidth = math.max(1.0, math.min(width, 680.0) - 64);
    final defaultStyle = DefaultTextStyle.of(context).style;
    double textHeight(String text, double maxWidth, [TextStyle? style]) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: defaultStyle.merge(style)),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.localeOf(context),
      )..layout(maxWidth: maxWidth);
      final height = painter.height.ceilToDouble();
      painter.dispose();
      return height;
    }

    final textWidth = math.max(1.0, contentWidth - 24);
    return CareerLayout._(
      entries,
      math.max(
        34,
        textHeight(l10n.bio, contentWidth, const TextStyle(fontSize: 28)),
      ),
      [
        for (final entry in entries)
          math.max(
            160,
            textHeight(entry.$1, textWidth) +
                10 +
                textHeight(entry.$2, textWidth, const TextStyle(fontSize: 22)) +
                8 +
                textHeight(entry.$3, textWidth),
          ),
      ],
    );
  }
}

class CareerSection extends StatelessWidget {
  const CareerSection({
    super.key,
    required this.layout,
    required this.height,
    required this.top,
    required this.offset,
    required this.viewportHeight,
  });
  final CareerLayout layout;
  final double height, top, offset, viewportHeight;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = layout.entries;
    return SizedBox(
      height: height,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 90),
                SizedBox(
                  height: layout.headingHeight,
                  child: Text(l10n.bio, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 40),
                for (var i = 0; i < entries.length; i++)
                  ScrollReveal(
                    top: top + layout.rowTop(i),
                    height: layout.rowHeights[i],
                    offset: offset,
                    viewportHeight: viewportHeight,
                    child: SizedBox(
                      height: layout.rowHeights[i],
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: layout.rowHeights[i],
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 5,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 2,
                                    color: Colors.black26,
                                  ),
                                ),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.blueGrey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entries[i].$1,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  entries[i].$2,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: 8),
                                Text(entries[i].$3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
