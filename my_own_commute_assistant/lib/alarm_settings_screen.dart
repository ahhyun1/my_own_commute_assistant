import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'firestore_service.dart';
import 'main.dart';

class AlarmSettingsScreen extends StatefulWidget {
  const AlarmSettingsScreen({Key? key}) : super(key: key);

  @override
  _AlarmSettingsScreenState createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  TimeOfDay selectedTime = TimeOfDay(hour: 7, minute: 0);
  List<String> alarmTimes = [];
  List<List<bool>> alarmDays = [];
  final FirestoreService _firestoreService = FirestoreService();
  List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

  get flutterLocalNotificationsPlugin => null;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData = await _firestoreService.getUserAlarms(user.uid);
      if (userData != null) {
        setState(() {
          alarmTimes = List<String>.from(userData['alarmTimes'] ?? []);
          alarmDays = (userData['alarmDays'] as List<dynamic>?)
              ?.map((days) => _intToBoolList(days as int))
              .toList() ??
              List.generate(alarmTimes.length, (_) => List.filled(7, false));
        });
      }
    }
  }

  Future<void> _saveAlarms() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<int> alarmDaysAsInts = alarmDays.map((days) => _boolListToInt(days)).toList();
      print('Saving alarms: $alarmTimes, $alarmDaysAsInts');
      await _firestoreService.saveUserAlarms(user.uid, alarmTimes, alarmDaysAsInts);
    }
  }

  int _boolListToInt(List<bool> boolList) {
    int result = 0;
    for (int i = 0; i < boolList.length; i++) {
      if (boolList[i]) {
        result |= (1 << i);
      }
    }
    return result;
  }

  List<bool> _intToBoolList(int intVal) {
    List<bool> result = List.filled(7, false);
    for (int i = 0; i < result.length; i++) {
      result[i] = (intVal & (1 << i)) != 0;
    }
    return result;
  }

  void _showTimePicker({int? index}) {
    TimeOfDay initialTime = selectedTime;
    if (index != null) {
      List<String> timeParts = alarmTimes[index].split(" ");
      List<String> hourMinuteParts = timeParts[0].split(":");
      initialTime = TimeOfDay(
        hour: int.parse(hourMinuteParts[0]) % 12 + (timeParts[1] == 'PM' ? 12 : 0),
        minute: int.parse(hourMinuteParts[1]),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        bool isAM = initialTime.period == DayPeriod.am;
        List<bool> selectedDays = index != null && alarmDays.isNotEmpty && alarmDays.length > index
            ? List.from(alarmDays[index])
            : List.filled(7, false);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime(0, 0, 0, initialTime.hour, initialTime.minute),
                      onDateTimeChanged: (DateTime newDateTime) {
                        setModalState(() {
                          selectedTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                        });
                      },
                      use24hFormat: false,
                      mode: CupertinoDatePickerMode.time,
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: List.generate(days.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(days[index]),
                          selected: selectedDays[index],
                          onSelected: (selected) {
                            setModalState(() {
                              selectedDays[index] = selected;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final formattedTime = "${selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
                        if (index != null) {
                          alarmTimes[index] = formattedTime;
                          alarmDays[index] = selectedDays;
                        } else {
                          alarmTimes.add(formattedTime);
                          alarmDays.add(selectedDays);
                        }
                        _saveAlarms();
                        _scheduleAlarm(selectedTime.hour, selectedTime.minute, selectedDays, index ?? alarmTimes.length - 1);
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _scheduleAlarm(int hour, int minute, List<bool> days, int id) async {
    final now = DateTime.now();
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        final day = (i + 1) % 7;
        final nextAlarmDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute)
            .add(Duration(days: (day - now.weekday + 7) % 7));

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id * 7 + i,
          '출발 알람',
          '설정된 시간에 출발할 시간입니다.',
          nextAlarmDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'alarm_channel',
              'Alarm Notifications',
              channelDescription: 'This channel is used for alarm notifications.',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  void _deleteAlarm(int index) {
    setState(() {
      alarmTimes.removeAt(index);
      alarmDays.removeAt(index);
      _saveAlarms();
    });
    for (int i = 0; i < 7; i++) {
      flutterLocalNotificationsPlugin.cancel(index * 7 + i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showTimePicker(),
              child: Text(
                '출발시간 알람 설정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: alarmTimes.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.alarm, size: 40),
                      title: Text(
                        alarmTimes[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        days
                            .asMap()
                            .entries
                            .where((entry) => alarmDays[index][entry.key])
                            .map((entry) => entry.value)
                            .join(', '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showTimePicker(index: index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteAlarm(index),
                          ),
                        ],
                      ),
                    ),
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
