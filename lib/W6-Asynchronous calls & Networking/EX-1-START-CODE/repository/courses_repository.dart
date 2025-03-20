import 'package:futter_term2/W6-Asynchronous calls & Networking/EX-1-START-CODE/models/course.dart';

abstract class CoursesRepository{
  List<Course> getCourses();
  void addScore(Course id, CourseScore score);
}