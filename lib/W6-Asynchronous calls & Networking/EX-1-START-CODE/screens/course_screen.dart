import 'package:flutter/material.dart';
import 'package:futter_term2/W6-Asynchronous%20calls%20&%20Networking/EX-1-START-CODE/provider/courses_provider.dart';
import 'package:provider/provider.dart';
import 'course_score_form.dart';
import 'package:futter_term2/W6-Asynchronous calls & Networking/EX-1-START-CODE/models/course.dart';


class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key, required this.course});

  final Course course;

  Future<CourseScore?> _addScore(BuildContext context) async {
    final result = await Navigator.of(context).push<CourseScore>(
      MaterialPageRoute(builder: (ctx) => const CourseScoreForm()),
    );
    return result;
  }

  Color scoreColor(double score) {
    return score > 50 ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoursesProvider>(
      builder: (ctx, CoursesProvider, child){
        List<CourseScore> scores = course.scores;

        Widget content = const Center(child: Text('No Scores added yet.'));

        if (scores.isNotEmpty) {
          content = ListView.builder(
            itemCount: scores.length,
            itemBuilder:
                (ctx, index) => ListTile(
              title: Text(scores[index].studentName),
              trailing: Text(
                scores[index].studenScore.toString(),
                style: TextStyle(
                  color: scoreColor(scores[index].studenScore),
                  fontSize: 15,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: mainColor,
            title: Text(
              course.name,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(onPressed: () => _addScore(context), icon: const Icon(Icons.add)),
            ],
          ),
          body: content,
        );
      },
    );
  }
}

