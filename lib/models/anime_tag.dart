class AnimeTag {
  final String id;
  final String name;
  final int color;

  const AnimeTag({required this.id, required this.name, required this.color});

  AnimeTag copyWith({String? name, int? color}) =>
      AnimeTag(id: id, name: name ?? this.name, color: color ?? this.color);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};

  factory AnimeTag.fromJson(Map<String, dynamic> j) =>
      AnimeTag(id: j['id'], name: j['name'], color: j['color']);
}