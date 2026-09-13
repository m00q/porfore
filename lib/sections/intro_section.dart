import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({super.key, required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          AppLocalizations.of(context)!.portfolioTitle,
          style: const TextStyle(fontSize: 36),
        ),
      ),
    ),
  );
}
