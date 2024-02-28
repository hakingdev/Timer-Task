import 'package:flutter/material.dart';
import 'time_tracker_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Time Tracker'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Tracker'),
              Tab(text: 'Calendar'),
              Tab(text: 'Statistics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TimeTrackerScreen(),
            CalendarScreen(),
            StatisticsScreen(),
          ],
        ),
      ),
    );
  }
}
