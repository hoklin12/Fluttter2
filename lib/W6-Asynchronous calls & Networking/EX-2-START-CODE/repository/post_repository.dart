import '../model/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPost();
}
