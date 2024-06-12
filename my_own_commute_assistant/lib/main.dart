import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_own_commute_assistant/starting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 타임존 설정
  await initializeDateFormatting(); // 로케일 데이터 초기화
  await _requestPermissions(); // 권한 요청 추가
  await _initializeNotifications(); // 알림 초기화 추가

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool hasCommuteInfo = prefs.getBool('hasCommuteInfo') ?? false;
  bool hasRouteInfo = prefs.getBool('hasRouteInfo') ?? false;

  runApp(MyApp(
    isFirstRun: isFirstRun,
    isLoggedIn: isLoggedIn,
    hasCommuteInfo: hasCommuteInfo,
    hasRouteInfo: hasRouteInfo,
  ));
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    rethrow;
  }
}

Future<void> _requestPermissions() async {
  await [Permission.notification].request();
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: onSelectNotification,
  );
}

Future<void> onSelectNotification(String? payload) async {
  // 알림 클릭 시 처리할 작업
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  // 원하는 동작 수행
}

Future<void> onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
    ) async {
  // iOS 알림 수신 시 처리할 작업
  showDialog(
    context: MyApp.navigatorKey.currentState!.overlay!.context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title ?? ''),
      content: Text(body ?? ''),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('OK'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            await onSelectNotification(payload);
          },
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;
  final bool isLoggedIn;
  final bool hasCommuteInfo;
  final bool hasRouteInfo;

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({
    required this.isFirstRun,
    required this.isLoggedIn,
    required this.hasCommuteInfo,
    required this.hasRouteInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartingPage(
        isFirstRun: isFirstRun,
        isLoggedIn: isLoggedIn,
        hasCommuteInfo: hasCommuteInfo,
        hasRouteInfo: hasRouteInfo,
      ),
    );
  }
}
