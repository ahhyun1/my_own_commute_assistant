import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'route_screen.dart';
import 'address_search_screen.dart';
import 'firestore_service.dart';

class CommuteInfoScreen extends StatefulWidget {
  @override
  _CommuteInfoScreenState createState() => _CommuteInfoScreenState();
}

class _CommuteInfoScreenState extends State<CommuteInfoScreen> {
  String _selectedTransport = '버스';
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  Map<String, String> _startCoords = {'lat': '', 'lon': ''};
  Map<String, String> _endCoords = {'lat': '', 'lon': ''};
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('출퇴근길 정보를 입력해주세요.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                labelText: '출발지',
                hintText: '주소 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressSearchScreen(
                      onAddressSelected: (address, coords) {
                        setState(() {
                          _startController.text = address;
                          _startCoords = coords;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _endController,
              decoration: InputDecoration(
                labelText: '목적지',
                hintText: '주소 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressSearchScreen(
                      onAddressSelected: (address, coords) {
                        setState(() {
                          _endController.text = address;
                          _endCoords = coords;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            Text(
              '이용 교통수단',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TransportOption(
                  icon: Icons.directions_bus,
                  label: '버스',
                  selected: _selectedTransport == '버스',
                  onTap: () => _selectTransport('버스'),
                ),
                TransportOption(
                  icon: Icons.subway,
                  label: '지하철',
                  selected: _selectedTransport == '지하철',
                  onTap: () => _selectTransport('지하철'),
                ),
                TransportOption(
                  icon: Icons.directions_transit,
                  label: '버스+지하철',
                  selected: _selectedTransport == '버스+지하철',
                  onTap: () => _selectTransport('버스+지하철'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_startCoords['lat']!.isEmpty || _endCoords['lat']!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('출발지와 목적지를 입력해주세요.')),
                    );
                    return;
                  }

                  // Save commute info to Firestore
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await _firestoreService.saveUserCommuteInfo(
                      user.uid,
                      {'address': _startController.text, 'lat': _startCoords['lat']!, 'lon': _startCoords['lon']!},
                      {'address': _endController.text, 'lat': _endCoords['lat']!, 'lon': _endCoords['lon']!},
                      _selectedTransport,
                    );
                  }

                  // Save commute info to SharedPreferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('startLat', _startCoords['lat']!);
                  await prefs.setString('startLon', _startCoords['lon']!);
                  await prefs.setString('endLat', _endCoords['lat']!);
                  await prefs.setString('endLon', _endCoords['lon']!);
                  await prefs.setString('transport', _selectedTransport);
                  await prefs.setBool('hasCommuteInfo', true);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutePage(
                        startLat: _startCoords['lat']!,
                        startLon: _startCoords['lon']!,
                        endLat: _endCoords['lat']!,
                        endLon: _endCoords['lon']!,
                        transport: _selectedTransport,
                      ),
                    ),
                  );
                },
                child: Text('경로 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTransport(String transport) {
    setState(() {
      _selectedTransport = transport;
    });
  }
}

class TransportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TransportOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 40.0,
            color: selected ? Colors.blue : Colors.grey,
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
