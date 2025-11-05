import 'dart:convert';

class PostModel {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int? reactions;
  final Map<String, dynamic>? reactionMeta;
  final int? userId;

  const PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    this.reactions,
    this.reactionMeta,
    this.userId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final dynamic reactionsRaw = json['reactions'];
    int? reactions;
    Map<String, dynamic>? reactionMeta;

    if (reactionsRaw is int) {
      reactions = reactionsRaw;
    } else if (reactionsRaw is Map<String, dynamic>) {
      reactionMeta = reactionsRaw;
      reactions = reactionsRaw['total'] is int
          ? reactionsRaw['total'] as int
          : reactionsRaw['likes'] is int
              ? reactionsRaw['likes'] as int
              : null;
    }

    return PostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((dynamic e) => e.toString())
          .toList(),
      reactions: reactions,
      reactionMeta: reactionMeta,
      userId: (json['userId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'tags': tags,
      'reactions': reactions ?? reactionMeta,
      'reactionMeta': reactionMeta,
      'userId': userId,
    };
  }

  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    List<String>? tags,
    int? reactions,
    Map<String, dynamic>? reactionMeta,
    int? userId,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      reactions: reactions ?? this.reactions,
      reactionMeta: reactionMeta ?? this.reactionMeta,
      userId: userId ?? this.userId,
    );
  }

  String encodeTags() => jsonEncode(tags);

  static List<String> decodeTags(String tagsJson) {
    if (tagsJson.isEmpty) {
      return const [];
    }
    final dynamic decoded = jsonDecode(tagsJson);
    if (decoded is List<dynamic>) {
      return decoded.map((dynamic e) => e.toString()).toList();
    }
    return const [];
  }
}
