import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';
import 'widgets/loading_overlay.dart';

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
  bool _isLoading = true;

  void _changeLocale(Locale locale) {
    if (_isLoading || locale == _locale) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);
    // Paint the opaque cover before rebuilding the localized portfolio.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _locale = locale);
    });
  }

  void _finishLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

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
    builder: (context, child) => Stack(
      fit: StackFit.expand,
      children: [
        ExcludeFocus(
          excluding: _isLoading,
          child: ExcludeSemantics(
            excluding: _isLoading,
            child: AbsorbPointer(absorbing: _isLoading, child: child),
          ),
        ),
        if (_isLoading) LoadingOverlay(onComplete: _finishLoading),
      ],
    ),
    home: HomePage(onLocaleChanged: _changeLocale),
  );
}
