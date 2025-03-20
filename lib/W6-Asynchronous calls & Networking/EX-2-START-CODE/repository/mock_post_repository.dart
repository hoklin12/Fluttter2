import '../model/post.dart';

import 'post_repository.dart';

class MockPostRepository extends PostRepository {
  final List<Post> posts = [
    Post(id: 001, title: 'Who is the Best teacher?', description: 'Teacher Ronan'),
    Post(id: 002, title: 'Who do you think is the best coder?', description: 'Teacher Baby Shark'),
    Post(id: 003, title: 'Who is the Best designer', description: 'Teacher little Boy'),
  ];

  @override
  Future<List<Post>> getPost() {
    return Future.delayed(Duration(seconds: 5), () {
      // if (postId != 25) {
      //   throw Exception("No post found");
      // }
      return posts;
    });
  }
}
