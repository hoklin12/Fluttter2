import 'package:flutter/material.dart';
import 'package:futter_term2/W6-Asynchronous%20calls%20&%20Networking/EX-1-START-CODE/provider/courses_provider.dart';
import 'package:provider/provider.dart';
import 'course_screen.dart';
import 'package:futter_term2/W6-Asynchronous calls & Networking/EX-1-START-CODE/models/course.dart';


const Color mainColor = Colors.blue;


class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  void _editCourse(BuildContext context, Course course) async {
    await Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (ctx) => CourseScreen(course: course)),
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('SCORE APP', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<CoursesProvider>(
        builder: (context, CourseProvider, child) {
          return ListView.builder(
              itemCount: CourseProvider.courses.length,
              itemBuilder:
              (ctx, index) => Dismissible(
              key: Key(CourseProvider.courses[index].name),
                child: CourseTile(
                    course: CourseProvider.courses[index],
                    onEdit: (course) => _editCourse(context, course),
                ),
              ),
          );
        },
      ),
    );
    }
}

class CourseTile extends StatelessWidget {
  const CourseTile({super.key, required this.course, required this.onEdit});

  final Course course;
  final Function(Course) onEdit;

  int get numberOfScores => course.scores.length;

  String get numberText {
    return course.hasScore ? "$numberOfScores scores" : 'No score';
  }

  String get averageText {
    String average = course.average.toStringAsFixed(1);
    return course.hasScore ? "Average : $average" : '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            onTap: () => onEdit(course),
            title: Text(course.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(numberText), Text(averageText)],
            ),
          ),
        ),
      ),
    );
  }
}