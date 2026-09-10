import 'package:flutter/material.dart';

class PokemonPage extends StatelessWidget {
  const PokemonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PokemonPage')),
      body: const Center(child: Text('PokemonPage')),
    );
  }
}
