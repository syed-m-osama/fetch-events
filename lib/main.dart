import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 1, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 1, kToday.day);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EventsHome());
}

class EventsHome extends StatefulWidget {
  const EventsHome({Key? key}) : super(key: key);

  @override
  State<EventsHome> createState() => _EventsHomeState();
}

class _EventsHomeState extends State<EventsHome> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? kStr;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    kStr = _selectedDay!.year.toString() +
        _selectedDay!.month.toString() +
        _selectedDay!.day.toString();
    //_selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  Widget build(BuildContext context) {
    kStr = _selectedDay!.year.toString() + //2022
        _selectedDay!.month.toString() + //3
        _selectedDay!.day.toString(); //23
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('hello')),
        ),
        body: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: kFirstDay,
              lastDay: kLastDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            TextButton(onPressed: () {}, child: Text('break')),
            const SizedBox(height: 5.0),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("eventsDate")
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        log(snapshot.error.toString());
                        return Text('No Events');
                      }
                      // return ListView(
                      //   children: snapshot.data!.docs.map((event) {
                      //     return Center(
                      //       child: ListTile(
                      //         title: Text(event['events']),
                      //       ),
                      //     );
                      //   }).toList(),
                      // );
                      final events = snapshot.data!.docs;

                      for (var event in events) {
                        final date = event.get('dateString');
                        if (date.toString() == kStr) {
                          final arr = event.get('event');
                          return Text(arr.toString());
                        }
                      }
                      return Text('random');
                    }))
          ],
        ),
      ),
    );
  }
}
