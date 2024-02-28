import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/time_tracker_model.dart';

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
    TaskCategory? selectedCategory;

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
                value: selectedCategory,
                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Text(_categoryToString(category)),
                  );
                }).toList(),
                onChanged: (category) {
                  selectedCategory = category;
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
                if (taskName.isNotEmpty && selectedCategory != null) {
                  final newTask = Task(
                    name: taskName,
                    category: selectedCategory!,
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
