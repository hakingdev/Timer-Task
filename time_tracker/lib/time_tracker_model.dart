import 'dart:async';
import 'package:flutter/material.dart';

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

  Map<TaskCategory, int> categoryTimes = {
    TaskCategory.Work: 0,
    TaskCategory.SocialMedia: 0,
    TaskCategory.Family: 0,
  };

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
        categoryTimes[currentTask!.category] =
            categoryTimes[currentTask!.category]! + 1;
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

    categoryTimes = {
      TaskCategory.Work: 0,
      TaskCategory.SocialMedia: 0,
      TaskCategory.Family: 0,
    };

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

  int getTotalTimeForCategory(TaskCategory category) {
    return categoryTimes[category]!;
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

  int getTotalTimeSpent() {
    return tasks.fold(0, (sum, task) => sum + task.totalTimeInSeconds);
  }
}
