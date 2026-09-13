// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get portfolioTitle => 'JUN의 포트폴리오';

  @override
  String get home => '홈';

  @override
  String get bio => '이력';

  @override
  String get skills => '기술';

  @override
  String get credits => '크레딧';

  @override
  String get chaos => '분산';

  @override
  String get graph => '그래프';

  @override
  String get categories => '카테고리';

  @override
  String skillsHeading(String skills, String state) {
    return '$skills / $state';
  }

  @override
  String get languages => '프로그래밍 언어';

  @override
  String get frameworkEngine => '프레임워크 / 런타임 / 엔진';

  @override
  String get graphics => '그래픽스';

  @override
  String get toolsEnvironment => '개발 도구';

  @override
  String get knowledge => '컴퓨터 과학';

  @override
  String get experienceAxis => 'X = 실전 경험';

  @override
  String get proficiencyAxis => 'Y = 숙련도';

  @override
  String get career2019Title => '대구대학교 졸업';

  @override
  String get career2019Description => '문헌정보학 전공';

  @override
  String get career2023Title => 'SBS게임아카데미';

  @override
  String get career2023Description =>
      '게임 개발자 과정\nC/C++, C#, Unity, 컴퓨터 그래픽스,\n렌더링 파이프라인, 알고리즘 등을 학습';

  @override
  String get career2026Title => '일본 テクノアーク 입사';

  @override
  String get career2026Description => '';

  @override
  String get github => 'GitHub';

  @override
  String get pokemonLab => 'Pokemon Lab';

  @override
  String get pokemonPage => '포켓몬 페이지';

  @override
  String get builtWithFlutter => 'Flutter로 제작';

  @override
  String get references => '참고 자료';

  @override
  String get assets => '에셋';

  @override
  String get copyright => '© 2026 JUN';

  @override
  String get webData => 'Web / 데이터';

  @override
  String get career2019TrainingTitle => '한국능력개발교육원';

  @override
  String get career2019TrainingDescription =>
      '「JAVA 기반 디지털 컨버전스 개발자 양성」 과정\nJava, SQL, Spring 등을 학습';

  @override
  String get career2025Title => 'HCM(주) 입사';

  @override
  String get career2025Description => '';
}
