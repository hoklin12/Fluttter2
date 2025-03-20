// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import '../model/post.dart';
//
// class HttpPostRepo{
//   final String baseUrl = " https://jsonplaceholder.typicode.com";
//
//   Future<List<Post>> getPosts() async {
//     final response = await http.get(Uri.parse('$baseUrl/posts'));
//
//     if (response.statusCode == 200) {
//       // If the server returns a 200 OK response, parse the JSON.
//       final List<dynamic> jsonData = jsonDecode(response.body);
//       return jsonData.map((json) => fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load posts');
//     }
//   }
//
//   // Method to convert JSON to a Post object
//   Post fromJson(Map<String, dynamic> json) {
//     return Post(
//       id: json['id'] as int, // Cast to int
//       title: json['title'] as String, // Cast to String
//       description: json['body'] as String, // Cast to String (assuming 'body' contains the description)
//     );
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post.dart';
import 'post_repository.dart'; // Import the PostRepository interface

class HttpPostRepo implements PostRepository {
  final String baseUrl = "https://jsonplaceholder.typicode.com/posts";

  @override
  Future<List<Post>> getPost() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
  // implement a fromJson to Post object
  Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['body'] as String,
    );
  }
}