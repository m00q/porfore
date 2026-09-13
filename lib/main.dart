import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';

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
    locale: _locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.portfolioTitle,
    home: HomePage(
      onLocaleChanged: (locale) => setState(() => _locale = locale),
    ),
  );
}
