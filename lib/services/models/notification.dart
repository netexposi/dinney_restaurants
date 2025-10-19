import 'package:hive/hive.dart';


@HiveType(typeId: 1)
class Notifications extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final bool viewed;

  @HiveField(4)
  final String media;

  Notifications({
    required this.id,
    required this.title,
    required this.body,
    required this.viewed,
    required this.media,
  });

  Notifications copyWith({
    String? id,
    String? title,
    String? body,
    bool? viewed,
    String? media,
  }) {
    return Notifications(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      viewed: viewed ?? this.viewed,
      media: media ?? this.media,
    );
  }

  // Add this:
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'viewed': viewed,
        'media': media,
      };

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        viewed: json['viewed'] as bool,
        media: json['media'] as String,
      );
}
