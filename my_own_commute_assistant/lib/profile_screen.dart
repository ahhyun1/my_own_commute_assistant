import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'starting_page.dart';
import 'firestore_service.dart';
import 'commute_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _route;
  Map<String, dynamic>? _commuteInfo;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestoreService.getUser(user.uid);
      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            _route = userData['route'] as Map<String, dynamic>?;
            _commuteInfo = userData['commuteInfo'] as Map<String, dynamic>?;
          });
        }
      }
    }
  }

  Future<void> _resetRoute() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.deleteUserRoute(user.uid);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRouteInfo', false);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CommuteInfoScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    bool hasCommuteInfo = prefs.getBool('hasCommuteInfo') ?? false;
    bool hasRouteInfo = prefs.getBool('hasRouteInfo') ?? false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StartingPage(
          isFirstRun: false,
          isLoggedIn: false,
          hasCommuteInfo: hasCommuteInfo,
          hasRouteInfo: hasRouteInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '저장된 경로',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_route != null)
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_commuteInfo != null)
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text('출발지: ${_commuteInfo!['start']['address']}'),
                        ),
                      for (var leg in _route!['subPath'])
                        ListTile(
                          leading: leg['trafficType'] == 1
                              ? const Icon(Icons.directions_subway)
                              : leg['trafficType'] == 2
                              ? const Icon(Icons.directions_bus)
                              : const Icon(Icons.directions_walk),
                          title: Text(
                            leg['trafficType'] == 1
                                ? '${leg['lane'][0]['name']} (${leg['startName']} -> ${leg['endName']})'
                                : leg['trafficType'] == 2
                                ? '${leg['lane'][0]['busNo']}번 (${leg['startName']} -> ${leg['endName']})'
                                : '${leg['startName']} -> ${leg['endName']}',
                          ),
                          subtitle: Text('${leg['sectionTime']}분 소요'),
                        ),
                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('목적지: ${_commuteInfo!['end']['address']}'),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('저장된 경로가 없습니다.'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _resetRoute,
                child: const Text('경로 재설정'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _logout,
                child: const Text('로그아웃'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
