class AnimeTag {
  final String id;
  final String name;
  final int color;
  final int order;

  const AnimeTag({
    required this.id,
    required this.name,
    required this.color,
    this.order = 0,
  });

  AnimeTag copyWith({String? name, int? color, int? order}) =>
      AnimeTag(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        order: order ?? this.order,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'order': order,
  };

  factory AnimeTag.fromJson(Map<String, dynamic> j) =>
      AnimeTag(
        id: j['id'],
        name: j['name'],
        color: j['color'],
        order: j['order'] ?? 0,
      );
}