import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// Set to headlineCandidateA or headlineCandidateB to preview either quote.
// null keeps the localized portfolioTitle from lib/l10n/app_*.arb.
const String? portfolioHeadlineOverride = null;
const headlineCandidateA =
    'People who analyze algorithms have double happiness.';

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
          portfolioHeadlineOverride ??
              AppLocalizations.of(context)!.portfolioTitle,
          style: const TextStyle(fontSize: 36),
        ),
      ),
    ),
  );
}
