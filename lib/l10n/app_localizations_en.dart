// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get portfolioTitle => 'JUN\'s Portfolio';

  @override
  String get home => 'HOME';

  @override
  String get bio => 'BIO';

  @override
  String get skills => 'SKILLS';

  @override
  String get credits => 'CREDITS';

  @override
  String get chaos => 'CHAOS';

  @override
  String get graph => 'GRAPH';

  @override
  String get categories => 'CATEGORIES';

  @override
  String skillsHeading(String skills, String state) {
    return '$skills / $state';
  }

  @override
  String get languages => 'Languages';

  @override
  String get frameworkEngine => 'Frameworks / Runtime / Engines';

  @override
  String get graphics => 'Graphics';

  @override
  String get toolsEnvironment => 'Tools';

  @override
  String get knowledge => 'Computer Science';

  @override
  String get experienceAxis => 'X = Practical Experience';

  @override
  String get proficiencyAxis => 'Y = Proficiency';

  @override
  String get career2019Title => 'Graduated from Daegu University';

  @override
  String get career2019Description =>
      'Major in Library and Information Science';

  @override
  String get career2023Title => 'SBS Game Academy';

  @override
  String get career2023Description =>
      'Game Developer Course\nStudied C/C++, C#, Unity, computer graphics,\nrendering pipelines, algorithms, and related topics';

  @override
  String get career2026Title => 'Joined Techno-Arc in Japan';

  @override
  String get career2026Description => '';

  @override
  String get github => 'GitHub';

  @override
  String get pokemonLab => 'Pokemon Lab';

  @override
  String get pokemonPage => 'PokemonPage';

  @override
  String get builtWithFlutter => 'Built with Flutter';

  @override
  String get references => 'References';

  @override
  String get assets => 'Assets';

  @override
  String get copyright => '© 2026 JUN';

  @override
  String get webData => 'Web / Data';

  @override
  String get career2019TrainingTitle =>
      'Korea Human Resources Development Institute';

  @override
  String get career2019TrainingDescription =>
      'JAVA-based Digital Convergence Developer Training\nStudied Java, SQL, Spring, and related technologies';

  @override
  String get career2025Title => 'Joined HCM Co., Ltd.';

  @override
  String get career2025Description => '';
}
