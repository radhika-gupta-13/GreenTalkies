// grove_model.dart
class Comment {
  final String id; // <-- add this
  final String userId;
  final String username;
  final String text;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '', // map backend _id to id
      userId: json['userId'],
      username: json['username'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'username': username,
    'text': text,
  };
}

class GrovePostModel {
  final String id;
  final String username;
  final String userId;
  final String content;
  final String topic;
  final List<String> likes;
  final List<Comment> comments;
  final String? imageUrl;
  final DateTime? createdAt;

  GrovePostModel({
    required this.id,
    required this.username,
    required this.userId,
    required this.content,
    required this.topic,
    required this.likes,
    required this.comments,
    this.imageUrl,
    this.createdAt,
  });

  factory GrovePostModel.fromJson(Map<String, dynamic> json) {
    return GrovePostModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      topic: json['topic'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'userId': userId,
    'content': content,
    'topic': topic,
    'likes': likes,
    'comments': comments.map((c) => c.toJson()).toList(),
    'imageUrl': imageUrl,
    'createdAt': createdAt?.toIso8601String(),
  };
}
