import 'anime_button.dart';

class AnimeItem {
  final String id;
  final String title;
  final String description;
  final String note;
  final List<String> tagIds;
  final DateTime createdAt;
  final String? imageBase64;
  final List<AnimeButton> buttons;

  const AnimeItem({
    required this.id,
    required this.title,
    this.description = '',
    this.note = '',
    this.tagIds = const [],
    required this.createdAt,
    this.imageBase64,
    this.buttons = const [],
  });

  AnimeItem copyWith({
    String? title,
    String? description,
    String? note,
    List<String>? tagIds,
    String? imageBase64,
    bool clearImage = false,
    List<AnimeButton>? buttons,
  }) =>
      AnimeItem(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        note: note ?? this.note,
        tagIds: tagIds ?? this.tagIds,
        createdAt: createdAt,
        imageBase64: clearImage ? null : (imageBase64 ?? this.imageBase64),
        buttons: buttons ?? this.buttons,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'note': note,
        'tagIds': tagIds,
        'createdAt': createdAt.toIso8601String(),
        'imageBase64': imageBase64,
        'buttons': buttons.map((b) => b.toJson()).toList(),
      };

  factory AnimeItem.fromJson(Map<String, dynamic> j) => AnimeItem(
        id: j['id'],
        title: j['title'],
        description: j['description'] ?? '',
        note: j['note'] ?? '',
        tagIds: (j['tagIds'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(j['createdAt']),
        imageBase64: j['imageBase64'] as String?,
        buttons: (j['buttons'] as List<dynamic>?)
                ?.map((b) => AnimeButton.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [],
      );
}