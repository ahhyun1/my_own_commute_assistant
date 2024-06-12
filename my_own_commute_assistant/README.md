# my_own_commute_assistant

# My Commute Assistant App

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

### 설치 방법
1. Flutter SDK 설치
: Flutter 공식 웹사이트(https://docs.flutter.dev/get-started/install)에서 OS에 맞는 Flutter SDK를 다운로드하고 설치합니다.
  설치 후 압축을 푼 다음 Flutter를 PATH에 추가합니다. (export PATH="$PATH:`pwd`/flutter/bin")
  터미널에서 flutter doctor 명령어를 실행하여 설치가 올바르게 되었는지 확인합니다.
2. Android Studio를 열고 프로젝트를 엽니다.
3. Android 디바이스 또는 에뮬레이터를 선택하고 빌드 및 실행합니다.

## 실제 앱 실행 방법
1. 안드로이드에 [app-release.apk](build%2Fapp%2Foutputs%2Fflutter-apk%2Fapp-release.apk) 파일을 설치합니다.
   (본 프로젝트 안에는 build/app/outputs/flutter-apk/app-release.apk 이 경로를 따라가면 파일 찾을 수 있습니다.)
2. 앱이 다운로드 완료 되면 실행 시작합니다.
3. 알람 기능 사용을 위해 앱 처음 실행 시 알림 권한 허용 해주고 & 설정 앱에서 '알람 및 리마인더' 허용으로 바꿔줍니다.

## 사용법
1. 앱을 실행합니다. 
2. 출근길 경로를 설정합니다.(도시 간의 이동과 같은 너무 먼 거리는 길 찾기 결과가 나오지 않을 수도 있습니다.)
3. 실시간 교통 정보를 확인합니다.(실시간 버스 도착 정보는 api 문제로 서울권만 가능합니다.)
4. 날씨 정보는 로딩 시간이 조금 걸립니다.
5. 출근길 알림을 설정하여 제때 출발합니다. 

### 요약
- 프로젝트를 실행하려면 Flutter SDK와 Dart SDK가 설치되어 있어야 합니다.
- `pubspec.y