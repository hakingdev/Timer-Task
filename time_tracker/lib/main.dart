import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/home_screen.dart';
import 'package:time_tracker/time_tracker_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeTrackerModel(),
      child: MaterialApp(
        title: 'Time Tracker',
        home: HomeScreen(),
      ),
    );
  }
}
