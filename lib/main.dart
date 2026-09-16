import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';

String _fontFamilyFor(Locale locale) => switch (locale.languageCode) {
  'ko' => 'KimjungchulScript',
  'ja' => 'KleeOne',
  _ => 'Handlee',
};

List<String> _fontFallbackFor(Locale locale) => switch (locale.languageCode) {
  'ko' => const ['KleeOne', 'Handlee'],
  'ja' => const ['KimjungchulScript', 'Handlee'],
  _ => const ['KleeOne', 'KimjungchulScript'],
};

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale _locale = const Locale('ja');

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: _fontFamilyFor(_locale),
      fontFamilyFallback: _fontFallbackFor(_locale),
    ),
    locale: _locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.portfolioTitle,
    home: HomePage(
      onLocaleChanged: (locale) => setState(() => _locale = locale),
    ),
  );
}
