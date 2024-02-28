import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/time_tracker_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeTrackerModel = Provider.of<TimeTrackerModel>(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Column(
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
              3601 *
                  _getTotalTimeInMinutes(TaskCategory.values, timeTrackerModel))
            Text(
              'Advice: Consider reducing time spent on ${_getCategoryWithMostTime(timeTrackerModel)}',
              style: TextStyle(fontSize: 18),
            ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryLegend(
                TaskCategory.Work,
                Colors.blue,
                'Work',
              ),
              _buildCategoryLegend(
                TaskCategory.SocialMedia,
                Colors.green,
                'Social Media',
              ),
              _buildCategoryLegend(
                TaskCategory.Family,
                Colors.orange,
                'Family',
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: 300,
            height: 300,
            child: PieChart(
              PieChartData(
                sections: _generatePieChartSections(timeTrackerModel),
                centerSpaceRadius: 40,
                sectionsSpace: 0,
                pieTouchData: PieTouchData(
                  touchCallback:
                      (FlTouchEvent event, PieTouchResponse? response) {
                    // Handle touch interactions if needed
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      TimeTrackerModel timeTrackerModel) {
    final List<TaskCategory> categories = TaskCategory.values;
    final List<Color> categoryColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];

    final List<PieChartSectionData> pieChartSections =
        categories.map((category) {
      final double categoryTime =
          timeTrackerModel.getTotalTimeForCategory(category).toDouble();
      return PieChartSectionData(
        color: categoryColors[category.index],
        value: categoryTime,
        title: categoryTime.round().toString(),
        radius: 100,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }).toList();

    return pieChartSections;
  }

  Widget _buildCategoryLegend(
      TaskCategory category, Color color, String categoryName) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(height: 5),
        Text(
          categoryName,
          style: TextStyle(fontSize: 14),
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
