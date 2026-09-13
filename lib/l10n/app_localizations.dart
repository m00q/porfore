import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @portfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'JUN\'s Portfolio'**
  String get portfolioTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'BIO'**
  String get bio;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'SKILLS'**
  String get skills;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'CREDITS'**
  String get credits;

  /// No description provided for @chaos.
  ///
  /// In en, this message translates to:
  /// **'CHAOS'**
  String get chaos;

  /// No description provided for @graph.
  ///
  /// In en, this message translates to:
  /// **'GRAPH'**
  String get graph;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categories;

  /// Skills heading and current scroll state
  ///
  /// In en, this message translates to:
  /// **'{skills} / {state}'**
  String skillsHeading(String skills, String state);

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @frameworkEngine.
  ///
  /// In en, this message translates to:
  /// **'Frameworks / Runtime / Engines'**
  String get frameworkEngine;

  /// No description provided for @graphics.
  ///
  /// In en, this message translates to:
  /// **'Graphics'**
  String get graphics;

  /// No description provided for @toolsEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsEnvironment;

  /// No description provided for @knowledge.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get knowledge;

  /// No description provided for @experienceAxis.
  ///
  /// In en, this message translates to:
  /// **'X = Practical Experience'**
  String get experienceAxis;

  /// No description provided for @proficiencyAxis.
  ///
  /// In en, this message translates to:
  /// **'Y = Proficiency'**
  String get proficiencyAxis;

  /// No description provided for @career2019Title.
  ///
  /// In en, this message translates to:
  /// **'Graduated from Daegu University'**
  String get career2019Title;

  /// No description provided for @career2019Description.
  ///
  /// In en, this message translates to:
  /// **'Major in Library and Information Science'**
  String get career2019Description;

  /// No description provided for @career2023Title.
  ///
  /// In en, this message translates to:
  /// **'SBS Game Academy'**
  String get career2023Title;

  /// No description provided for @career2023Description.
  ///
  /// In en, this message translates to:
  /// **'Game Developer Course\nStudied C/C++, C#, Unity, computer graphics,\nrendering pipelines, algorithms, and related topics'**
  String get career2023Description;

  /// No description provided for @career2026Title.
  ///
  /// In en, this message translates to:
  /// **'Joined Techno-Arc in Japan'**
  String get career2026Title;

  /// No description provided for @career2026Description.
  ///
  /// In en, this message translates to:
  /// **''**
  String get career2026Description;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @pokemonLab.
  ///
  /// In en, this message translates to:
  /// **'Pokemon Lab'**
  String get pokemonLab;

  /// No description provided for @pokemonPage.
  ///
  /// In en, this message translates to:
  /// **'PokemonPage'**
  String get pokemonPage;

  /// No description provided for @builtWithFlutter.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter'**
  String get builtWithFlutter;

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 JUN'**
  String get copyright;

  /// No description provided for @webData.
  ///
  /// In en, this message translates to:
  /// **'Web / Data'**
  String get webData;

  /// No description provided for @career2019TrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Korea Human Resources Development Institute'**
  String get career2019TrainingTitle;

  /// No description provided for @career2019TrainingDescription.
  ///
  /// In en, this message translates to:
  /// **'JAVA-based Digital Convergence Developer Training\nStudied Java, SQL, Spring, and related technologies'**
  String get career2019TrainingDescription;

  /// No description provided for @career2025Title.
  ///
  /// In en, this message translates to:
  /// **'Joined HCM Co., Ltd.'**
  String get career2025Title;

  /// No description provided for @career2025Description.
  ///
  /// In en, this message translates to:
  /// **''**
  String get career2025Description;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
