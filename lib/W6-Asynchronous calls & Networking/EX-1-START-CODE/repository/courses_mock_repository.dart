import 'package:futter_term2/W6-Asynchronous calls & Networking/EX-1-START-CODE/models/course.dart';
import 'courses_repository.dart';

class MockCoursesRepository implements CoursesRepository {
  final List<Course> courses = [
    Course(id: '001', name: 'Business'),
    Course(id: '002', name: 'Marketing'),
    Course(id: '003', name: 'Programming'),
  ];

  @override
  List<Course> getCourses() {
    return courses;
  }

  @override
  void addScore(Course course, CourseScore score) {
    course.addScore(score);
  }
}