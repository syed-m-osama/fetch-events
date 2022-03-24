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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('fetch-events')),
        ),
        body: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: kFirstDay,
              lastDay: kLastDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            Divider(
              thickness: 1,
            ),
            const SizedBox(height: 10.0),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("eventsDate")
                        .where('Date',
                            isEqualTo:
                                _selectedDay.toString().split(' ').elementAt(0))
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        log(snapshot.error.toString());
                        return Text(
                          'NO DATA!!!',
                          style: TextStyle(fontSize: 20.0),
                        );
                      }

                      var events = snapshot.data!.docs;
                      List<EventCard> eventCards = [];

                      for (var event in events) {
                        var eventData = event.get('Event');
                        var eventCard = EventCard(
                          eventTitle: eventData,
                        );
                        eventCards.add(eventCard);
                      }
                      if (eventCards.isEmpty) {
                        return Text(
                          'No Events',
                          style: TextStyle(fontSize: 20.0),
                        );
                      }
                      return ListView(
                        children: eventCards,
                      );
                    }))
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final eventTitle;
  //const EventCard({Key? key}) : super(key: key);

  EventCard({this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          borderOnForeground: true,
          elevation: 2.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '$eventTitle',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          )),
    );
  }
}
