import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart' as fs_service;
import 'home_screen.dart';

class RoutePage extends StatefulWidget {
  final String startLat;
  final String startLon;
  final String endLat;
  final String endLon;
  final String transport;

  RoutePage({
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
    required this.transport,
  });

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RoutePage> {
  late Future<Map<String, dynamic>> routeData;
  final _firestoreService = fs_service.FirestoreService();

  @override
  void initState() {
    super.initState();
    routeData = fetchOptimalRoute(widget.startLat, widget.startLon, widget.endLat, widget.endLon);
  }

  Future<Map<String, dynamic>> fetchOptimalRoute(
      String startLat, String startLon, String endLat, String endLon) async {
    final url = Uri.parse(
        'https://api.odsay.com/v1/api/searchPubTransPathT?SX=$startLon&SY=$startLat&EX=$endLon&EY=$endLat&OPT=1&apiKey=W7R24c5etWGAJkhTI6foTCgTAM5QmNXin0BiT7hNIdo');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // 한글 디코딩 추가
      return data;
    } else {
      throw Exception('route 정보 가져오기에 실패했습니다');
    }
  }

  void saveRouteAndNavigate(Map<String, dynamic> selectedRoute) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.saveUserRoute(user.uid, selectedRoute);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasRouteInfo', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('저장 실패'),
          content: const Text('로그인 상태를 확인해주세요.'),
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

  List<Map<String, dynamic>> filterRoutesByTransportType(List<dynamic> routes, int transportType) {
    return routes.where((route) {
      final int type = route['pathType'];
      return type == transportType || (type == 3 && transportType == 3); // 버스+지하철
    }).map((route) {
      final List<dynamic> subPath = route['subPath'];
      int transferCount = 0;
      for (int i = 1; i < subPath.length; i++) {
        if (subPath[i]['trafficType'] != subPath[i - 1]['trafficType'] &&
            subPath[i]['trafficType'] != 3 &&
            subPath[i - 1]['trafficType'] != 3) {
          transferCount++;
        }
      }
      route['info']['totalTransferCount'] = transferCount;
      return route as Map<String, dynamic>;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('경로 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: routeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No route data found'));
            } else {
              final data = snapshot.data!;
              final itineraries = data['result']['path'] as List<dynamic>;

              List<Map<String, dynamic>> filteredRoutes;
              switch (widget.transport) {
                case '지하철':
                  filteredRoutes = filterRoutesByTransportType(itineraries, 1);
                  break;
                case '버스':
                  filteredRoutes = filterRoutesByTransportType(itineraries, 2);
                  break;
                case '버스+지하철':
                  filteredRoutes = filterRoutesByTransportType(itineraries, 3);
                  break;
                default:
                  filteredRoutes = [];
              }

              return ListView.builder(
                itemCount: filteredRoutes.length,
                itemBuilder: (context, index) {
                  final itinerary = filteredRoutes[index];
                  final info = itinerary['info'];
                  final legs = itinerary['subPath'] as List<dynamic>;

                  int transferCount = 0;
                  for (int i = 1; i < legs.length; i++) {
                    if (legs[i]['trafficType'] != 3 && legs[i]['trafficType'] != legs[i - 1]['trafficType']) {
                      transferCount++;
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        '총 소요시간: ${info['totalTime']}분, 환승: $transferCount회, 요금: ${info['payment']}원',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: legs.map((leg) {
                          if (leg['trafficType'] == 1) {
                            // 지하철
                            return ListTile(
                              leading: const Icon(Icons.directions_subway),
                              title: Text('${leg['lane'][0]['name']} (${leg['startName']} -> ${leg['endName']})'),
                              subtitle: Text('${leg['sectionTime']}분 소요'),
                            );
                          } else if (leg['trafficType'] == 2) {
                            // 버스
                            return ListTile(
                              leading: const Icon(Icons.directions_bus),
                              title: Text('${leg['lane'][0]['busNo']}번 (${leg['startName']} -> ${leg['endName']})'),
                              subtitle: Text('${leg['sectionTime']}분 소요'),
                            );
                          } else {
                            // 도보
                            return ListTile(
                              leading: const Icon(Icons.directions_walk),
                              title: Text('도보'),
                              subtitle: Text('${leg['sectionTime']}분 소요, ${leg['distance']}m'),
                            );
                          }
                        }).toList(),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => saveRouteAndNavigate(itinerary),
                        child: const Text('이 경로 저장'),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
