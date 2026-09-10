import 'package:flutter/material.dart';

import '../sections/career_section.dart';
import '../sections/contact_section.dart';
import '../sections/intro_section.dart';
import '../sections/skills_section.dart';
import 'pokemon_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const IntroSection(),
            const CareerSection(),
            const SkillsSection(),
            const ContactSection(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder<void>(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PokemonPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Text('PokemonPage로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
