import 'package:flutter/material.dart';
import 'package:futter_term2/W6-Asynchronous calls & Networking/EX-1-START-CODE/models/course.dart';
import 'package:futter_term2/W6-Asynchronous%20calls%20&%20Networking/EX-1-START-CODE/repository/courses_repository.dart';

class CoursesProvider with ChangeNotifier {
  final CoursesRepository _repository;

  CoursesProvider(this._repository);

  List<Course> get courses => _repository.getCourses();

  void addScore(Course course, CourseScore score) {
    _repository.addScore(course, score);
    notifyListeners(); // Notify UI of changes
  }
}