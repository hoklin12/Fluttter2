import 'package:flutter/material.dart';
import 'package:futter_term2/W6-Asynchronous%20calls%20&%20Networking/EX-1-START-CODE/repository/courses_mock_repository.dart';
import 'package:provider/provider.dart';
import 'screens/course_list_screen.dart';
import 'package:futter_term2/W6-Asynchronous%20calls%20&%20Networking/EX-1-START-CODE/provider/courses_provider.dart';


// void main() {
//   runApp(
//     ChangeNotifierProvider(create:
//         (context) => CoursesProvider(),
//       child: myApp()
//     )
//   );
// }

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CoursesProvider(MockCoursesRepository()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: CourseListScreen(),
    );
  }
}
