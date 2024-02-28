import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

enum TaskCategory {
  Work,
  SocialMedia,
  Family,
}

class Task {
  String name;
  int totalTimeInSeconds;
  int elapsedTimeInSeconds;
  TaskCategory category;
  DateTime date;

  Task({
    required this.name,
    this.totalTimeInSeconds = 0,
    this.elapsedTimeInSeconds = 0,
    required this.category,
    required this.date,
  });
}

class TimeTrackerModel extends ChangeNotifier {
  bool isTracking = false;
  List<Task> tasks = [];
  Task? currentTask;

  int totalWorkTimeInSeconds = 0;
  int totalSocialMediaTimeInSeconds = 0;
  int totalFamilyTimeInSeconds = 0;

  DateTime selectedDate = DateTime.now();

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
        switch (currentTask!.category) {
          case TaskCategory.Work:
            totalWorkTimeInSeconds++;
            break;
          case TaskCategory.SocialMedia:
            totalSocialMediaTimeInSeconds++;
            break;
          case TaskCategory.Family:
            totalFamilyTimeInSeconds++;
            break;
        }
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

    totalWorkTimeInSeconds = 0;
    totalSocialMediaTimeInSeconds = 0;
    totalFamilyTimeInSeconds = 0;

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

  void setCurrentTaskDate(DateTime date) {
    if (currentTask != null) {
      currentTask!.date = date;
      notifyListeners();
    }
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  int getTotalTimeForCategory(TaskCategory category) {
    switch (category) {
      case TaskCategory.Work:
        return totalWorkTimeInSeconds;
      case TaskCategory.SocialMedia:
        return totalSocialMediaTimeInSeconds;
      case TaskCategory.Family:
        return totalFamilyTimeInSeconds;
    }
  }

  int getTotalTimeForCategoryAndDate(
      TaskCategory category, DateTime selectedDate) {
    return tasks
        .where((task) =>
            task.category == category &&
            task.date.year == selectedDate.year &&
            task.date.month == selectedDate.month &&
            task.date.day == selectedDate.day)
        .fold(0, (sum, task) => sum + task.totalTimeInSeconds);
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
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Time Tracker'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Tracker'),
              Tab(text: 'Calendar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TimeTrackerScreen(),
            CalendarScreen(),
          ],
        ),
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

    return Center(
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
              'Total Time Spent on ${task.name} (${_categoryToString(task.category)}): ${task.totalTimeInSeconds} seconds',
              style: TextStyle(fontSize: 18),
            ),
          SizedBox(height: 20),
          Text(
            'Total Time Spent on Work: ${timeTrackerModel.getTotalTimeForCategory(TaskCategory.Work)} seconds',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Total Time Spent on Social Media: ${timeTrackerModel.getTotalTimeForCategory(TaskCategory.SocialMedia)} seconds',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Total Time Spent on Family: ${timeTrackerModel.getTotalTimeForCategory(TaskCategory.Family)} seconds',
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
                : 'Start Tracking'),
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
    );
  }

  Future<void> _showTaskInputDialog(
      BuildContext context, TimeTrackerModel model) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _taskController,
                decoration: InputDecoration(hintText: 'Task Name'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<TaskCategory>(
                value: TaskCategory.Work,
                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Text(_categoryToString(category)),
                  );
                }).toList(),
                onChanged: (selectedCategory) {
                  // Handle category selection
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
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
                final taskCategory = TaskCategory
                    .Work; // Placeholder, replace with selected category
                if (taskName.isNotEmpty) {
                  final newTask = Task(
                    name: taskName,
                    category: taskCategory,
                    date: DateTime.now(),
                  );
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

  String _categoryToString(TaskCategory category) {
    switch (category) {
      case TaskCategory.Work:
        return 'Work';
      case TaskCategory.SocialMedia:
        return 'Social Media';
      case TaskCategory.Family:
        return 'Family';
    }
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeTrackerModel = Provider.of<TimeTrackerModel>(context);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: timeTrackerModel.selectedDate,
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            print('Selected Day: $selectedDay');
            timeTrackerModel.updateSelectedDate(selectedDay);
          },
          selectedDayPredicate: (day) {
            return isSameDay(day, timeTrackerModel.selectedDate);
          },
        ),
        SizedBox(height: 20),
        if (timeTrackerModel.currentTask != null)
          Text(
            'Elapsed Time: ${timeTrackerModel.currentTask!.elapsedTimeInSeconds} seconds',
            style: TextStyle(fontSize: 18),
          ),
        for (var category in TaskCategory.values)
          Text(
            'Total Time Spent on ${_categoryToString(category)}: ${timeTrackerModel.getTotalTimeForCategoryAndDate(category, timeTrackerModel.selectedDate)} seconds',
            style: TextStyle(fontSize: 18),
          ),
      ],
    );
  }

  String _categoryToString(TaskCategory category) {
    switch (category) {
      case TaskCategory.Work:
        return 'Work';
      case TaskCategory.SocialMedia:
        return 'Social Media';
      case TaskCategory.Family:
        return 'Family';
    }
  }
}
