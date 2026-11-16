import 'anime_button.dart';

enum WatchStatus { planned, watching, completed, dropped }

WatchStatus _statusFromJson(dynamic v) {
  for (final s in WatchStatus.values) {
    if (s.name == v) return s;
  }
  return WatchStatus.planned;
}

class AnimeItem {
  final String id;
  final String title;
  final String description;
  final String note;
  final List<String> tagIds;
  final DateTime createdAt;
  final String? imageBase64;
  final List<AnimeButton> buttons;

  final WatchStatus status;

  final int progress;

  final int totalEpisodes;

  final int? rating;

  final bool favorite;
  final bool pinned;

  const AnimeItem({
    required this.id,
    required this.title,
    this.description = '',
    this.note = '',
    this.tagIds = const [],
    required this.createdAt,
    this.imageBase64,
    this.buttons = const [],
    this.status = WatchStatus.planned,
    this.progress = 0,
    this.totalEpisodes = 0,
    this.rating,
    this.favorite = false,
    this.pinned = false,
  });

  AnimeItem copyWith({
    String? title,
    String? description,
    String? note,
    List<String>? tagIds,
    String? imageBase64,
    bool clearImage = false,
    List<AnimeButton>? buttons,
    WatchStatus? status,
    int? progress,
    int? totalEpisodes,
    int? rating,
    bool clearRating = false,
    bool? favorite,
    bool? pinned,
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
        status: status ?? this.status,
        progress: progress ?? this.progress,
        totalEpisodes: totalEpisodes ?? this.totalEpisodes,
        rating: clearRating ? null : (rating ?? this.rating),
        favorite: favorite ?? this.favorite,
        pinned: pinned ?? this.pinned,
      );

  AnimeItem withProgress(int value) {
    var p = value < 0 ? 0 : value;
    if (totalEpisodes > 0 && p > totalEpisodes) p = totalEpisodes;
    var st = status;
    if (totalEpisodes > 0 && p >= totalEpisodes) {
      st = WatchStatus.completed;
    } else if (status == WatchStatus.completed) {
      st = WatchStatus.watching;
    } else if (p > 0 && status == WatchStatus.planned) {
      st = WatchStatus.watching;
    }
    return copyWith(progress: p, status: st);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'note': note,
        'tagIds': tagIds,
        'createdAt': createdAt.toIso8601String(),
        'imageBase64': imageBase64,
        'buttons': buttons.map((b) => b.toJson()).toList(),
        'status': status.name,
        'progress': progress,
        'totalEpisodes': totalEpisodes,
        'rating': rating,
        'favorite': favorite,
        'pinned': pinned,
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
        status: _statusFromJson(j['status']),
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        totalEpisodes: (j['totalEpisodes'] as num?)?.toInt() ?? 0,
        rating: (j['rating'] as num?)?.toInt(),
        favorite: j['favorite'] as bool? ?? false,
        pinned: j['pinned'] as bool? ?? false,
      );
}
