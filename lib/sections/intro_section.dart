import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({super.key, required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.heroQuote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Donald Knuth',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
