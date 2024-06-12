import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'commute_info_screen.dart';
import 'home_screen.dart';
import 'starting_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final String apiKey = 'AIzaSyBKT2uCp0PgYIL7YJUpqDLFN-fNErqukmM'; // Replace with your Firebase API Key

  final FocusNode idFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    idFocus.requestFocus();
  }

  @override
  void dispose() {
    idTextController.dispose();
    passwordTextController.dispose();
    idFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StartingPage(
                isFirstRun: false,
                isLoggedIn: false,
                hasCommuteInfo: false,
                hasRouteInfo: false,
              )),
            );
          },
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: <Widget>[
            logo(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  id(),
                  password(),
                  const SizedBox(height: 50),
                  button(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget logo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: const Text(
        '로그인',
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget id() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 53,
      child: TextFormField(
        controller: idTextController,
        focusNode: idFocus,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '이메일을 입력하세요';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: '이메일',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget password() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 53,
      child: TextFormField(
        controller: passwordTextController,
        focusNode: passwordFocus,
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '비밀번호를 입력하세요';
          }
          return null;
        },
        decoration: const InputDecoration(
          labelText: '비밀번호',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget button() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 53,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            login();
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xFF2C75F5).withOpacity(0.5);
              } else if (states.contains(MaterialState.disabled)) {
                return Colors.grey;
              }
              return const Color(0xFF2C75F5);
            },
          ),
        ),
        child: const Text(
          "로그인",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void login() async {
    final id = idTextController.text;
    final password = passwordTextController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id,
        password: password,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userCredential.user!.uid);
      await prefs.setBool('isLoggedIn', true);

      bool hasCommuteInfo = prefs.getBool('hasCommuteInfo') ?? false;
      bool hasRouteInfo = prefs.getBool('hasRouteInfo') ?? false;

      if (mounted) {
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
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('로그인 실패'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }
}
