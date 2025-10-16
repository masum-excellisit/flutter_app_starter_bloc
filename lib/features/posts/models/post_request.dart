import 'post_model.dart';

class PostRequest {
  final String title;
  final String body;
  final List<String> tags;
  final int userId;

  const PostRequest({
    required this.title,
    required this.body,
    required this.tags,
    this.userId = 1,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'body': body,
      'tags': tags,
      'userId': userId,
    };
  }

  PostRequest copyWith({
    String? title,
    String? body,
    List<String>? tags,
    int? userId,
  }) {
    return PostRequest(
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
    );
  }

  factory PostRequest.fromModel(PostModel model, {int fallbackUserId = 1}) {
    return PostRequest(
      title: model.title,
      body: model.body,
      tags: model.tags,
      userId: model.userId ?? fallbackUserId,
    );
  }
}
