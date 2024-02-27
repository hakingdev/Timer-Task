import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp()); //changes is her
}

class Task {
  String name;
  int totalTimeInSeconds;
  int elapsedTimeInSeconds;

  Task(
      {required this.name,
      this.totalTimeInSeconds = 0,
      this.elapsedTimeInSeconds = 0});
}

class TimeTrackerModel extends ChangeNotifier {
  bool isTracking = false;
  List<Task> tasks = [];
  Task? currentTask;

  void startTracking(Task task) {
    currentTask = task;
    currentTask!.elapsedTimeInSeconds = 0;
    isTracking = true;
    notifyListeners();

    const Duration interval = Duration(seconds: 1);
    Timer.periodic(interval, (Timer timer) {
      if (!isTracking) {
        timer.cancel();
      } else {
        currentTask!.elapsedTimeInSeconds++;
        notifyListeners();
      }
    });
  }

  void stopTracking() {
    isTracking = false;
    if (currentTask != null) {
      currentTask!.totalTimeInSeconds += currentTask!.elapsedTimeInSeconds;
      currentTask = null;
    }
    notifyListeners();
  }

  void resetTracking() {
    for (var task in tasks) {
      task.totalTimeInSeconds = 0;
      task.elapsedTimeInSeconds = 0;
    }
    notifyListeners();
  }

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void setCurrentTask(Task task) {
    currentTask = task;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeTrackerModel(),
      child: MaterialApp(
        title: 'Time Tracker',
        home: TimeTrackerScreen(),
      ),
    );
  }
}

class TimeTrackerScreen extends StatelessWidget {
  TimeTrackerScreen({Key? key}) : super(key: key);

  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final timeTrackerModel = Provider.of<TimeTrackerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Time Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (timeTrackerModel.currentTask != null)
              Text(
                'Elapsed Time: ${timeTrackerModel.currentTask!.elapsedTimeInSeconds} seconds',
                style: TextStyle(fontSize: 18),
              ),
            for (var task in timeTrackerModel.tasks)
              Text(
                'Total Time Spent on ${task.name}: ${task.totalTimeInSeconds} seconds',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (timeTrackerModel.isTracking) {
                  timeTrackerModel.stopTracking();
                } else {
                  _showTaskInputDialog(context, timeTrackerModel);
                }
              },
              child: Text(timeTrackerModel.isTracking
                  ? 'Stop Tracking'
                  : 'Start Tracking1'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                timeTrackerModel.resetTracking();
              },
              child: Text('Reset'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showTaskInputDialog(context, timeTrackerModel);
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTaskInputDialog(
      BuildContext context, TimeTrackerModel model) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Task'),
          content: TextFormField(
            controller: _taskController,
            decoration: InputDecoration(hintText: 'Task Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final taskName = _taskController.text.trim();
                if (taskName.isNotEmpty) {
                  final newTask = Task(name: taskName);
                  model.addTask(newTask);
                  model.startTracking(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Start Task'),
            ),
          ],
        );
      },
    );
  }
}
