class AnimeButton {
  final String id;
  final String label;
  final int color;
  final String url;

  const AnimeButton({
    required this.id,
    required this.label,
    required this.color,
    required this.url,
  });

  AnimeButton copyWith({String? label, int? color, String? url}) => AnimeButton(
        id: id,
        label: label ?? this.label,
        color: color ?? this.color,
        url: url ?? this.url,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'label': label, 'color': color, 'url': url};

  factory AnimeButton.fromJson(Map<String, dynamic> j) => AnimeButton(
        id: j['id'],
        label: j['label'],
        color: j['color'],
        url: j['url'],
      );
}