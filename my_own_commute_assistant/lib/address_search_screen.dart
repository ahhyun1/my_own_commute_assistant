import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressSearchScreen extends StatefulWidget {
  final Function(String, Map<String, String>) onAddressSelected;

  AddressSearchScreen({required this.onAddressSelected});

  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  Future<void> _fetchAddressSuggestions(String query) async {
    final url = Uri.parse(
        'https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=$query&page=1&count=20&resCoordType=WGS84GEO&multiPoint=N&searchtypCd=A');
    final response = await http.get(url, headers: {
      'appKey': 'PrYA8Y7Iag6vSqpSdf0jE9VB2t75qkBv42Y3GDoB ', // 실제 API 키로 교체
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> poiList = data['searchPoiInfo']['pois']['poi'];
      setState(() {
        _suggestions = poiList.map((poi) {
          return {
            'id': poi['id'].toString(),
            'name': poi['name'].toString(),
            'lat': poi['noorLat'].toString(),
            'lon': poi['noorLon'].toString()
          };
        }).toList();
      });
    } else {
      throw Exception('주소 검색 가져오기에 실패했습니다.');
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      await _fetchAddressSuggestions(query);
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '주소 검색',
                hintText: '주소 입력',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion['name']),
                    onTap: () {
                      widget.onAddressSelected(
                        suggestion['name'],
                        {
                          'lat': suggestion['lat'],
                          'lon': suggestion['lon']
                        },
                      );
                      Navigator.pop(context); // 주소를 선택하고 창을 닫음
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
