import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'join_page.dart';
import 'home_screen.dart';
import 'commute_info_screen.dart';

class StartingPage extends StatefulWidget {
  final bool isFirstRun;
  final bool isLoggedIn;
  final bool hasCommuteInfo;
  final bool hasRouteInfo;

  const StartingPage({
    required this.isFirstRun,
    required this.isLoggedIn,
    required this.hasCommuteInfo,
    required this.hasRouteInfo,
    super.key,
  });

  @override
  _StartingPageState createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  late bool isLoggedIn;
  late bool hasCommuteInfo;
  late bool hasRouteInfo;

  @override
  void initState() {
    super.initState();
    _initializeState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextPage();
    });
  }

  Future<void> _initializeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    hasCommuteInfo = prefs.getBool('hasCommuteInfo') ?? false;
    hasRouteInfo = prefs.getBool('hasRouteInfo') ?? false;
    await prefs.setBool('isFirstRun', false);
  }

  void _navigateToNextPage() {
    if (isLoggedIn) {
      if (hasCommuteInfo && hasRouteInfo) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CommuteInfoScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/startingPage_image.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 50),
            const Text(
              '나만의 출근길 비서',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF080A0B),
                fontSize: 32,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                '실시간으로 업데이트되는 출근길 정보를 쉽게 탐색할 수 있습니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5d5d5b),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  height: 18 / 14,
                ),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear preferences on logout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('로그인'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => JoinPage()),
                );
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
