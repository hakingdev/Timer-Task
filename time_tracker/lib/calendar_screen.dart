import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/time_tracker_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
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
            timeTrackerModel.selectedDate = selectedDay;
            print('Selected Day: $selectedDay');
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
      default:
        return ''; // Возвращаемое значение для непредвиденных случаев
    }
  }
}
