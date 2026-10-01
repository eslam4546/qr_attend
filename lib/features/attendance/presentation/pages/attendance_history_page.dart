import 'package:flutter/material.dart';

/// Placeholder — will be implemented in Step 6.5
class AttendanceHistoryPage extends StatelessWidget {
  final String courseId;

  const AttendanceHistoryPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Attendance History: $courseId')),
    );
  }
}
