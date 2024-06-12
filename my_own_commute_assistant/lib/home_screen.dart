import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'alarm_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userId;
  Future<Map<String, dynamic>?>? routeDataFuture;
  //Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getUser();
   // _startTimer();
  }

  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }

  Future<void> _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        routeDataFuture = FirestoreService().getUserRoute(userId!);
      });
    } else {
      print("현재 로그인된 사용자가 없습니다.");
    }
  }

  Future<Map<String, dynamic>> fetchBusInfo(String busId) async {
    final response = await http.get(
      Uri.parse('https://api.odsay.com/v1/api/realtimeRoute?busID=$busId&apiKey=W7R24c5etWGAJkhTI6foTCgTAM5QmNXin0BiT7hNIdo'),
    );
    if (response.statusCode == 200) {
      print('버스 정보 응답: ${response.body}');
      return json.decode(response.body);
    } else {
      print('버스 정보를 불러오지 못했습니다: ${response.body}');
      throw Exception('버스 정보를 불러오지 못했습니다');
    }
  }

  Future<Map<String, dynamic>> fetchBusStopInfo(String stationId) async {
    final response = await http.get(
      Uri.parse('https://api.odsay.com/v1/api/busStationInfo?stationID=$stationId&apiKey=W7R24c5etWGAJkhTI6foTCgTAM5QmNXin0BiT7hNIdo'),
    );
    if (response.statusCode == 200) {
      print('버스 정류장 정보 응답: ${response.body}');
      return json.decode(response.body);
    } else {
      print('버스 정류장 정보를 불러오지 못했습니다: ${response.body}');
      throw Exception('버스 정류장 정보를 불러오지 못했습니다');
    }
  }

  Future<Map<String, dynamic>> fetchSubwayInfo(String stationId) async {
    final response = await http.get(
      Uri.parse('https://api.odsay.com/v1/api/searchSubwaySchedule?stationID=$stationId&apiKey=W7R24c5etWGAJkhTI6foTCgTAM5QmNXin0BiT7hNIdo'),
    );
    if (response.statusCode == 200) {
      print('지하철 시간표 응답: ${response.body}');
      return json.decode(response.body);
    } else {
      print('지하철 정보를 불러오지 못했습니다: ${response.body}');
      throw Exception('지하철 정보를 불러오지 못했습니다');
    }
  }

  Future<Map<String, dynamic>> getGridNumber(double lon, double lat) async {
    final apiKey = 'cK7ITHDRT-CuyExw0c_gzw'; // 활성화된 API 키를 여기에 입력하세요
    final url = Uri.parse(
        'https://apihub.kma.go.kr/api/typ01/cgi-bin/url/nph-dfs_xy_lonlat?lon=$lon&lat=$lat&help=0&authKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      print('Response: $decodedResponse');

      final lines = decodedResponse.split('\n');
      if (lines.length > 2) {
        final values = lines[2].split(',').map((v) => v.trim()).toList();
        return {
          'lon': double.parse(values[0]),
          'lat': double.parse(values[1]),
          'x': int.parse(values[2]),
          'y': int.parse(values[3]),
        };
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      print('Failed to load grid number: ${response.body}');
      throw Exception('격자 정보를 불러오지 못했습니다.');
    }
  }
  Future<Map<String, dynamic>> fetchWeatherInfo(int nx, int ny) async {
    final apiKey = 'cK7ITHDRT-CuyExw0c_gzw';

    final now = DateTime.now();
    int baseHour = ((now.hour + 1) ~/ 3) * 3 - 1;
    if (baseHour == -1) {
      baseHour = 23;
    } else if (baseHour == 23) {
      baseHour = 23;
    } else {
      baseHour %= 24;
    }

    final baseDate = now.hour < 2 ?
    DateTime(now.year, now.month, now.day - 1) :
    now;

    final baseDateStr = '${baseDate.year.toString().padLeft(4, '0')}${baseDate.month.toString().padLeft(2, '0')}${baseDate.day.toString().padLeft(2, '0')}';
    final baseTime = '${baseHour.toString().padLeft(2, '0')}00';

    final url = Uri.parse(
        'https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst?pageNo=1&numOfRows=1000&dataType=JSON&base_date=$baseDateStr&base_time=$baseTime&nx=$nx&ny=$ny&authKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      print('Weather Info Response: $decodedResponse');
      final jsonResponse = json.decode(decodedResponse);
      jsonResponse['baseDateStr'] = baseDateStr;
      jsonResponse['baseTime'] = baseTime;
      return jsonResponse;
    } else {
      print('Failed to load weather info: ${response.body}');
      throw Exception('날씨 정보를 불러오지 못했습니다.');
    }
  }

  Map<String, Map<String, String>> parseWeatherInfo(List<dynamic> items) {
    Map<String, Map<String, String>> informations = {};

    for (var item in items) {
      String category = item['category'];
      String fcstTime = item['fcstTime'];
      String fcstValue = item['fcstValue'] ?? '';

      if (!informations.containsKey(fcstTime)) {
        informations[fcstTime] = {};
      }

      informations[fcstTime]![category] = fcstValue;
    }

    return informations;
  }

  String generateWeatherInfo(Map<String, dynamic> val, String baseDate, String baseTime, int nx, int ny) {
    String template = "${baseDate.substring(0, 4)}년 ${baseDate.substring(4, 6)}월 ${baseDate.substring(6, 8)}일 ${baseTime.substring(0, 2)}시 ${baseTime.substring(2)}분 (${nx}, ${ny}) 지역의 날씨는 ";

    if (val.containsKey('SKY')) {
      String skyTemp = skyCode[int.parse(val['SKY'] ?? '1')]!;
      template += "$skyTemp ";
    }

    if (val.containsKey('PTY')) {
      String ptyTemp = ptyCode[int.parse(val['PTY'] ?? '0')]!;
      template += "$ptyTemp ";
      if (val['RN1'] != '강수없음') {
        String rn1Temp = val['RN1'] ?? '0';
        template += "시간당 $rn1Temp mm ";
      }
    }

    if (val.containsKey('T1H')) {
      double t1hTemp = double.parse(val['T1H'] ?? '0');
      template += "기온 ${t1hTemp}℃ ";
    }

    if (val.containsKey('REH')) {
      double rehTemp = double.parse(val['REH'] ?? '0');
      template += "습도 ${rehTemp}% ";
    }

    if (val.containsKey('VEC') && val.containsKey('WSD')) {
      String vecTemp = degToDir(double.parse(val['VEC'] ?? '0'));
      String wsdTemp = val['WSD'] ?? '0';
      template += "풍속 $vecTemp 방향 $wsdTemp m/s";
    }

    return template;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 /* void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _reload();
    });
  }*/

  Map<double, String> degCode = {
    0: 'N', 360: 'N', 180: 'S', 270: 'W', 90: 'E',
    22.5: 'NNE', 45: 'NE', 67.5: 'ENE', 112.5: 'ESE',
    135: 'SE', 157.5: 'SSE', 202.5: 'SSW', 225: 'SW',
    247.5: 'WSW', 292.5: 'WNW', 315: 'NW', 337.5: 'NNW'
  };

  String degToDir(double deg) {
    String closeDir = '';
    double minAbs = 360;
    if (!degCode.containsKey(deg)) {
      degCode.forEach((key, value) {
        if ((key - deg).abs() < minAbs) {
          minAbs = (key - deg).abs();
          closeDir = value;
        }
      });
    } else {
      closeDir = degCode[deg]!;
    }
    return closeDir;
  }

  Map<int, String> ptyCode = {0: '강수 없음', 1: '비', 2: '비/눈', 3: '눈', 5: '빗방울', 6: '진눈깨비', 7: '눈날림'};
  Map<int, String> skyCode = {1: '맑음', 3: '구름많음', 4: '흐림'};

  Future<List<dynamic>> fetchTrafficEvents(double minLat, double minLon, double maxLat, double maxLon) async {
    final url = Uri.parse(
        'https://apis.openapi.sk.com/tmap/traffic?version=1&format=json&appKey=PrYA8Y7Iag6vSqpSdf0jE9VB2t75qkBv42Y3GDoB&trafficType=ACC&minLat=$minLat&minLon=$minLon&maxLat=$maxLat&maxLon=$maxLon&reqCoordType=WGS84GEO&resCoordType=WGS84GEO&zoomLevel=3'
    );

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'appKey': 'PrYA8Y7Iag6vSqpSdf0jE9VB2t75qkBv42Y3GDoB',
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['features']?.where((feature) => feature['geometry']['type'] == 'Point').toList() ?? [];
    } else {
      throw Exception('돌발 교통 정보를 불러오지 못했습니다: ${response.body}');
    }
  }
  List<Widget> _widgetOptions(String userId) => <Widget>[
    _buildHomeScreen(userId),
    AlarmSettingsScreen(),
    ProfileScreen(),
  ];

  Widget _buildHomeScreen(String userId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: routeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('오류: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('경로 데이터를 찾을 수 없습니다');
        } else {
          final routeData = snapshot.data!;
          print("경로 데이터: $routeData");

          final subPaths = routeData['route']['subPath'] as List<dynamic>;
          List<Widget> infoCards = [];

          final userStartLat = double.parse(routeData['commuteInfo']['start']['lat'].toString());
          final userStartLon = double.parse(routeData['commuteInfo']['start']['lon'].toString());
          final userEndLat = double.parse(routeData['commuteInfo']['end']['lat'].toString());
          final userEndLon = double.parse(routeData['commuteInfo']['end']['lon'].toString());

          final minLat = (userStartLat < userEndLat) ? userStartLat : userEndLat;
          final minLon = (userStartLon < userEndLon) ? userStartLon : userEndLon;
          final maxLat = (userStartLat > userEndLat) ? userStartLat : userEndLat;
          final maxLon = (userStartLon > userEndLon) ? userStartLon : userEndLon;

          // Add existing bus and subway info cards
          for (var subPath in subPaths) {
            if (subPath['trafficType'] == 2) { // 버스
              final busId = subPath['lane'][0]['busID'].toString();
              final busNumber = subPath['lane'][0]['busNo'];
              final userStationName = subPath['startName'];
              final userStationId = subPath['startID'].toString();
              final stations = subPath['passStopList']['stations'];

              infoCards.add(
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchBusInfo(busId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('오류: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.containsKey('result')) {
                      return Text('실시간 버스 정보가 없습니다');
                    } else {
                      final busInfo = snapshot.data;
                      if (busInfo != null && busInfo['result'].containsKey('real')) {
                        final realTimeInfo = busInfo['result']['real'];
                        if (realTimeInfo.isEmpty) {
                          return Text('실시간 버스 정보가 없습니다');
                        }

                        List<Widget> busInfoCards = [];
                        for (var info in realTimeInfo) {
                          final fromStationSeq = int.parse(info['fromStationSeq']);
                          final toStationSeq = int.parse(info['toStationSeq']);

                          final userStationIndex = stations.indexWhere((station) => station['stationID'].toString() == userStationId);
                          final busStationIndex = stations.indexWhere((station) => station['stationID'].toString() == info['fromStationId'].toString());

                          if (userStationIndex != -1 && busStationIndex != -1) {
                            final stopsAway = userStationIndex - busStationIndex;

                            busInfoCards.add(
                              InfoCard(
                                title: '버스 번호: ${info['busPlateNo']}',
                                subtitle: '도착 예정: $stopsAway번째 정류장 전',
                                icon: Icons.directions_bus,
                                onTap: () {},
                              ),
                            );
                          }
                          if (busInfoCards.length >= 2) break; // 두 개만 보여주기
                        }

                        return InfoCard(
                          title: '버스 번호: $busNumber',
                          subtitle: '정류장: $userStationName',
                          icon: Icons.directions_bus,
                          onTap: () {},
                          children: busInfoCards,
                        );
                      } else {
                        return Text('실시간 버스 정보가 없습니다');
                      }
                    }
                  },
                ),
              );
            } else if (subPath['trafficType'] == 1) { // 지하철
              final stationId = subPath['startID'].toString();
              final userStationName = subPath['startName'];

              infoCards.add(
                FutureBuilder<Map<String, dynamic>>(
                  future: fetchSubwayInfo(stationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('오류: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.containsKey('result')) {
                      return Text('실시간 지하철 정보가 없습니다');
                    } else {
                      final subwayInfo = snapshot.data;
                      if (subwayInfo != null && subwayInfo['result'].containsKey('weekdaySchedule')) {
                        final now = DateTime.now();
                        final weekdaySchedule = subwayInfo['result']['weekdaySchedule'];
                        final upSchedule = weekdaySchedule['up'] ?? [];
                        final downSchedule = weekdaySchedule['down'] ?? [];

                        List<Map<String, dynamic>> upcomingTrains = [];

                        for (var train in upSchedule) {
                          final departureTime = train['departureTime'];
                          final trainTime = DateTime(now.year, now.month, now.day, int.parse(departureTime.split(':')[0]), int.parse(departureTime.split(':')[1]));
                          if (trainTime.isAfter(now)) {
                            upcomingTrains.add({
                              'departureTime': departureTime,
                              'destination': train['endStationName'],
                              'minutesAway': trainTime.difference(now).inMinutes,
                            });
                          }
                          if (upcomingTrains.length >= 2) break;
                        }

                        for (var train in downSchedule) {
                          final departureTime = train['departureTime'];
                          final trainTime = DateTime(now.year, now.month, now.day, int.parse(departureTime.split(':')[0]), int.parse(departureTime.split(':')[1]));
                          if (trainTime.isAfter(now)) {
                            upcomingTrains.add({
                              'departureTime': departureTime,
                              'destination': train['endStationName'],
                              'minutesAway': trainTime.difference(now).inMinutes,
                            });
                          }
                          if (upcomingTrains.length >= 2) break;
                        }

                        List<Widget> trainInfoCards = [];
                        for (var train in upcomingTrains) {
                          trainInfoCards.add(
                            InfoCard(
                              title: '열차 도착 예정',
                              subtitle: '${train['departureTime']} (${train['minutesAway']}분 후)',
                              icon: Icons.directions_subway,
                              onTap: () {},
                            ),
                          );
                        }

                        return InfoCard(
                          title: '지하철역: $userStationName',
                          subtitle: '도착 예정 열차:',
                          icon: Icons.directions_subway,
                          onTap: () {},
                          children: trainInfoCards,
                        );
                      } else {
                        return Text('실시간 지하철 정보가 없습니다');
                      }
                    }
                  },
                ),
              );
            }
          }
          infoCards.add(
            FutureBuilder<List<dynamic>>(
              future: fetchTrafficEvents(minLat, minLon, maxLat, maxLon),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('도로 돌발 교통 정보를 불러올 수 없습니다');
                } else {
                  final trafficEvents = snapshot.data ?? [];

                  List<Widget> eventCards = trafficEvents.map<Widget>((event) {
                    final properties = event['properties'];
                    final description = properties['description'] ?? '정보없음';
                    final congestion = properties['congestion'] ?? 0;
                    final speed = properties['speed'] ?? '정보없음';
                    final startNodeName = properties['startNodeName'] ?? '정보없음';
                    final endNodeName = properties['endNodeName'] ?? '정보없음';

                    final congestionStr = congestion == 1 ? '원활' : congestion == 2 ? '서행' : congestion == 3 ? '지체' : congestion == 4 ? '정체' : '정보없음';

                    return InfoCard(
                      title: '돌발 교통 상황',
                      subtitle: '설명: $description',
                      icon: Icons.warning,
                      onTap: () {},
                    );
                  }).toList();

                  return Column(children: eventCards);
                }
              },
            ),
          );
          infoCards.add(
            FutureBuilder<Map<String, dynamic>>(
              future: getGridNumber(userStartLon, userStartLat),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('격자 정보를 불러올 수 없습니다');
                } else {
                  final gridInfo = snapshot.data!;
                  final nx = gridInfo['x'];
                  final ny = gridInfo['y'];

                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchWeatherInfo(nx, ny),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('오류: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Text('실시간 날씨 정보를 불러올 수 없습니다');
                      } else {
                        final weatherInfo = snapshot.data!;
                        final items = weatherInfo['response']['body']['items']['item'] as List<dynamic>;
                        final baseDateStr = weatherInfo['baseDateStr'];
                        final baseTime = weatherInfo['baseTime'];

                        final informations = parseWeatherInfo(items);
                        final mostRecentTime = informations.keys.first;
                        final mostRecentInfo = informations[mostRecentTime]!;

                        String info = generateWeatherInfo(mostRecentInfo, baseDateStr, mostRecentTime, nx, ny);

                        return InfoCard(
                          title: '날씨 정보',
                          subtitle: info,
                          icon: Icons.wb_sunny,
                          onTap: () {},
                        );
                      }
                    },
                  );
                }
              },
            ),
          );
          return ListView(
            children: infoCards.isNotEmpty ? infoCards : [Text('도착 정보가 없습니다')],
          );
        }
      },
    );
  }

  void _reload() {
    setState(() {
      routeDataFuture = FirestoreService().getUserRoute(userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나만의 출근길 비서'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userId == null
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            ElevatedButton(
              onPressed: _reload,
              child: Text('다시 로딩'),
            ),
            Expanded(
              child: _widgetOptions(userId!).elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserRoute(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        print('Document data: ${doc.data()}');
        return doc.data() as Map<String, dynamic>?;
      } else {
        print('No document found for user $uid');
        return null;
      }
    } catch (e) {
      print('Error getting user route: $e');
      return null;
    }
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? trailing;
  final VoidCallback? onTap;
  final List<Widget>? children;

  const InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(subtitle),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              if (children != null) ...children!,
            ],
          ),
        ),
      ),
    );
  }
}
