// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get portfolioTitle => 'JUNのポートフォリオ';

  @override
  String get home => 'ホーム';

  @override
  String get bio => '経歴';

  @override
  String get skills => 'スキル';

  @override
  String get credits => 'クレジット';

  @override
  String get chaos => '分散';

  @override
  String get graph => 'グラフ';

  @override
  String get categories => 'カテゴリー';

  @override
  String skillsHeading(String skills, String state) {
    return '$skills / $state';
  }

  @override
  String get languages => 'プログラミング言語';

  @override
  String get frameworkEngine => 'フレームワーク / ランタイム / エンジン';

  @override
  String get graphics => 'グラフィックス';

  @override
  String get toolsEnvironment => '開発ツール';

  @override
  String get knowledge => 'コンピュータサイエンス';

  @override
  String get experienceAxis => 'X = 実践経験';

  @override
  String get proficiencyAxis => 'Y = 習熟度';

  @override
  String get career2019Title => '大邱大学校 卒業';

  @override
  String get career2019Description => '文献情報学専攻';

  @override
  String get career2023Title => 'SBSゲームアカデミー';

  @override
  String get career2023Description =>
      'ゲーム開発者コース\nC/C++、C#、Unity、コンピュータグラフィックス、\nレンダリングパイプライン、アルゴリズムなどを学習';

  @override
  String get career2026Title => '株式会社テクノアーク 入社';

  @override
  String get career2026Description => '';

  @override
  String get github => 'GitHub';

  @override
  String get pokemonLab => 'Pokemon Lab';

  @override
  String get pokemonPage => 'ポケモンページ';

  @override
  String get builtWithFlutter => 'Flutterで制作';

  @override
  String get references => '参考資料';

  @override
  String get assets => '素材';

  @override
  String get copyright => '© 2026 JUN';

  @override
  String get webData => 'Web / データ';

  @override
  String get career2019TrainingTitle => '韓国能力開発教育院';

  @override
  String get career2019TrainingDescription =>
      '「JAVAベース デジタルコンバージェンス開発者養成」課程\nJava、SQL、Springなどを学習';

  @override
  String get career2025Title => 'HCM株式会社 入社';

  @override
  String get career2025Description => '';
}
