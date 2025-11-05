class PostModel {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int userId;

  const PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.userId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      userId: (json['userId'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        'userId': userId,
      };
}
