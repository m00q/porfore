# porfore

Personal portfolio website built with Flutter Web.

## 머릿말 변경

`lib/sections/intro_section.dart`의 `portfolioHeadlineOverride` 한 곳에서 선택합니다.
- `null`: 기존 다국어 제목 유지 (`lib/l10n/app_*.arb`의 `portfolioTitle`).
- `headlineCandidateA`: People who analyze algorithms have double happiness.
- `headlineCandidateB`: Schaffen — das ist die große Erlösung vom Leiden.

후보는 아직 확정하지 않았습니다. 인용문을 선택하면 모든 언어에 해당 원문을 표시하며,
기존 언어 전환은 그대로 동작합니다. 언어별 제목 수정은 ARB에서 하고 `flutter gen-l10n`으로 재생성합니다.

## Web 아이콘 교체

현재 연결된 PNG를 같은 이름과 크기의 커스텀 이미지로 교체하면 됩니다.
경로는 이미 상대 경로이므로 하위 경로 배포를 위해 manifest를 수정할 필요가 없습니다.

| 파일 | 사용 위치 | 크기 |
| --- | --- | --- |
| `web/favicon.png` | `web/index.html`의 브라우저 탭 아이콘 | 16 × 16 |
| `web/icons/Icon-192.png` | manifest 및 index.html의 Apple 터치 아이콘 | 192 × 192 |
| `web/icons/Icon-512.png` | manifest의 Web App 아이콘 | 512 × 512 |
| `web/icons/Icon-maskable-192.png` | manifest의 maskable 아이콘 | 192 × 192 |
| `web/icons/Icon-maskable-512.png` | manifest의 maskable 아이콘 | 512 × 512 |

파일 이름을 바꾸는 경우 `web/index.html`의 favicon/apple-touch-icon 링크와
`web/manifest.json`의 해당 `icons[].src`도 함께 변경합니다.
maskable 파일은 플랫폼의 잘림을 고려해 중요한 패턴을 중앙에 두는 별도 버전으로 준비합니다.
이미지 교체 후 Web을 다시 빌드·배포하고 브라우저/PWA 아이콘 캐시를 확인합니다.

예정된 로고: 투명 배경 위 검정 원, 내부에 조밀한 흰색 0/1 패턴,
약 5시 방향의 일부 절단. TSMC 로고를 복제하지 않는 독자적인 디자인으로 제작합니다.
이번 변경에는 이미지 생성이나 기존 아이콘 교체가 포함되지 않습니다.