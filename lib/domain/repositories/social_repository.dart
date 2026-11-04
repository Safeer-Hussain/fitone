import '../entities/social_post.dart';

abstract class SocialRepository {
  Future<List<SocialPost>> getCommunityFeed();
  Future<void> toggleLike(String postId, bool isLiked);
  Future<void> addComment(String postId, PostComment comment);
  Future<void> createPost(SocialPost post);
}
