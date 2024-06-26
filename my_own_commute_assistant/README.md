# my_own_commute_assistant

My Commute Assistant App은 출근길 시간을 도와주는 앱입니다. 실시간 교통 정보를 제공하고 경로를 추천하여 출근길 시간을 절약할 수 있도록 도와줍니다.

## 기능
- 실시간 교통 정보 제공
- 경로 추천
- 출근길 알림 설정
- 즐겨찾는 경로 저장

### 요구 사항
- **Flutter**: 3.4.0 이상
- **Dart SDK**: 3.4.0 이상
- **iOS**: 12.0 이상
- **Android**: 5.0 (API 21) 이상

### 권장 개발 환경
- **Xcode**: 12.0 이상 (iOS 빌드 및 시뮬레이션)
- **Android Studio**: 4.1 이상 (Android 빌드 및 시뮬레이션)
- **Visual Studio Code**: Flutter 개발을 위한 편집기

### 프로젝트 의존성
- **http**: ^1.2.1
- **shared_preferences**: ^2.0.6
- **cupertino_icons**: ^1.0.6
- **firebase_core**: ^2.31.1
- **firebase_auth**: ^4.19.6
- **cloud_firestore**: ^4.17.4
- **flutter_local_notifications**: ^9.2.0
- **timezone**: ^0.8.0
- **intl**: ^0.17.0
- **permission_handler**: ^11.1.0
- **url_launcher**: ^6.0.20

### 프로젝트 실행 방법
1. Flutter SDK 설치
   : Flutter 공식 웹사이트(https://docs.flutter.dev/get-started/install)에서 OS에 맞는 Flutter SDK를 다운로드하고 설치합니다.
2. 환경 변수 설정 
   : 설치 후 압축을 푼 다음 Flutter를 PATH에 추가합니다. (export PATH="$PATH:`pwd`/flutter/bin")
     터미널에서 flutter doctor 명령어를 실행하여 설치가 올바르게 되었는지 확인합니다.
3. flutter와 dart 플러그인 설치
   : 안드로이드 스튜디오를 실행하여 프로젝트의 설정 항목에서 Plugins를 찾아 클릭합니다. 그리고 flutter와 dart를 검색해 플러그인을 설치에 주면 됩니다.
5. Android Studio를 열고 해당 프로젝트 엽니다.
6. 터미널을 열어 flutter pub get를 입력해 종속성을 해결합니다.
7. Android 디바이스 또는 에뮬레이터를 선택하고 빌드 및 실행합니다.

## 실제 앱 실행 방법
1. 안드로이드에 [app-release.apk](https://github.com/ahhyun1/my_own_commute_assistant/blob/5c7cb94b2e00c3684d42c74698723a6583591887/app-release.apk) 파일을 설치합니다.  
2. 앱이 다운로드 완료 되면 실행 시작합니다.
3. 알람 기능 사용을 위해 앱 처음 실행 시 알림 권한 허용 해주고 & 설정 앱에서 '알람 및 리마인더' 허용으로 바꿔줍니다.

## 사용법
1. 앱을 실행합니다.
2. 회원가입, 로그인을 진행합니다.
3. 출근길 경로를 설정합니다.(도시 간의 이동과 같은 너무 먼 거리는 길 찾기 결과가 나오지 않을 수도 있습니다.)
4. 실시간 교통 정보를 확인합니다.(실시간 버스 도착 정보는 api 문제로 서울권만 가능합니다.)
5. 날씨 정보는 로딩 시간이 조금 걸립니다.
6. 출근길 알림을 설정하여 제때 출발합니다.

### 요약
- 프로젝트를 실행하려면 Flutter SDK와 Dart SDK가 설치되어 있어야 합니다.
- `pubspec.yaml` 파일에 명시된 종속성을 설치하기 위해 `flutter pub get` 명령어를 실행해야 합니다.
- 애플리케이션을 실행하려면 `flutter run` 명령어를 사용합니다.
