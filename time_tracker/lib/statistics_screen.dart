import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/time_tracker_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeTrackerModel = Provider.of<TimeTrackerModel>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Total Time Spent: ${timeTrackerModel.getTotalTimeSpent()} seconds',
          style: TextStyle(fontSize: 18),
        ),
        Text(
          'Category with Most Time: ${_getCategoryWithMostTime(timeTrackerModel)}',
          style: TextStyle(fontSize: 18),
        ),
        if (timeTrackerModel.getTotalTimeSpent() >
            0.5 * _getTotalTimeInMinutes(TaskCategory.values, timeTrackerModel))
          Text(
            'Advice: Consider reducing time spent on ${_getCategoryWithMostTime(timeTrackerModel)}',
            style: TextStyle(fontSize: 18),
          ),
      ],
    );
  }

  String _getCategoryWithMostTime(TimeTrackerModel timeTrackerModel) {
    TaskCategory categoryWithMostTime = TaskCategory.Work;
    int maxTime = 0;

    for (var category in TaskCategory.values) {
      final categoryTime = timeTrackerModel.getTotalTimeForCategory(category);
      if (categoryTime > maxTime) {
        maxTime = categoryTime;
        categoryWithMostTime = category;
      }
    }

    return _categoryToString(categoryWithMostTime);
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

  int _getTotalTimeInMinutes(
      List<TaskCategory> categories, TimeTrackerModel timeTrackerModel) {
    int totalTime = 0;

    for (var category in categories) {
      totalTime += timeTrackerModel.getTotalTimeForCategory(category);
    }

    return totalTime;
  }
}
