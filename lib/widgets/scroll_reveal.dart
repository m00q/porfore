import 'dart:math' as math;

import 'package:flutter/material.dart';

// Reverses naturally when scrolling back; exit also slides downward.
class ScrollReveal extends StatelessWidget {
  const ScrollReveal({
    super.key,
    required this.top,
    required this.height,
    required this.offset,
    required this.viewportHeight,
    required this.child,
  });
  final double top, height, offset, viewportHeight;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final visible = math
        .min(
          (offset + viewportHeight - top) / 140,
          (top + height - offset) / 140,
        )
        .clamp(0.0, 1.0);
    final eased = Curves.easeOut.transform(visible);
    return Opacity(
      opacity: eased,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - eased)),
        child: child,
      ),
    );
  }
}
