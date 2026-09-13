import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../l10n/app_localizations.dart';

class CreditsSection extends StatelessWidget {
  const CreditsSection({
    super.key,
    required this.height,
    required this.onPokemon,
  });
  final double height;
  final VoidCallback onPokemon;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lines = [
      l10n.builtWithFlutter,
      l10n.references,
      l10n.assets,
      l10n.copyright,
    ];
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.credits, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 28),
            Link(
              uri: Uri.parse('https://github.com/m00q/'),
              target: LinkTarget.blank,
              builder: (context, followLink) =>
                  InkWell(onTap: followLink, child: Text(l10n.github)),
            ),
            TextButton(onPressed: onPokemon, child: Text(l10n.pokemonLab)),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }
}
