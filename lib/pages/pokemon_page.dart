import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class PokemonPage extends StatelessWidget {
  const PokemonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.pokemonPage)),
      body: Center(child: Text(AppLocalizations.of(context)!.pokemonPage)),
    );
  }
}
