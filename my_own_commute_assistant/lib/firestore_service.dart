import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 사용자 정보를 Firestore에 저장하는 함수
  Future<void> addUser(String uid, String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  // Firestore에서 사용자 정보를 가져오는 함수
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // 사용자의 출퇴근 경로를 Firestore에 저장하는 함수
  Future<void> saveUserRoute(String uid, Map<String, dynamic> route) async {
    await _db.collection('users').doc(uid).set({
      'route': route,
    }, SetOptions(merge: true)); // 병합 옵션 사용
  }

  // Firestore에서 사용자의 출퇴근 경로를 가져오는 함수
  Future<Map<String, dynamic>?> getUserRoute(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // 사용자 알람 정보를 Firestore에 저장하는 함수
  Future<void> saveUserAlarms(String uid, List<String> alarmTimes, List<int> alarmDaysAsInts) async {
    try {
      await _db.collection('users').doc(uid).set({
        'alarmTimes': alarmTimes,
        'alarmDays': alarmDaysAsInts,
      }, SetOptions(merge: true)); // 병합 옵션 사용
    } catch (e) {
      print('알람 저장 오류: $e');
    }
  }

  // Firestore에서 사용자 알람 정보를 가져오는 함수
  Future<Map<String, dynamic>?> getUserAlarms(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('사용자의 알람 정보 불러오기 오류: $e');
      return null;
    }
  }

  // 3
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true)); // 병합 옵션 사용
  }

  Future<void> deleteUserRoute(String userId) async {
    await _db.collection('users').doc(userId).update({'route': FieldValue.delete()});
  }

  Future<void> saveUserCommuteInfo(String userId, Map<String, String> start, Map<String, String> end, String transport) async {
    await _db.collection('users').doc(userId).set({
      'commuteInfo': {
        'start': start,
        'end': end,
        'transport': transport,
      }
    }, SetOptions(merge: true));
  }
}

