import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const AnimeTrackerApp());
}



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

// ── Store ────────────────────────────────────────────────

class Store extends ChangeNotifier {
  static const _animeKey = 'anime_v3';
  static const _tagsKey = 'tags_v3';

  List<AnimeItem> anime = [];
  List<AnimeTag> tags = [];

  Store() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final ar = p.getString(_animeKey);
    final tr = p.getString(_tagsKey);
    if (ar != null) {
      anime = (jsonDecode(ar) as List).map((e) => AnimeItem.fromJson(e)).toList();
    }
    if (tr != null) {
      tags = (jsonDecode(tr) as List).map((e) => AnimeTag.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveAnime() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_animeKey, jsonEncode(anime.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveTags() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tagsKey, jsonEncode(tags.map((e) => e.toJson()).toList()));
  }

  Future<void> addAnime(AnimeItem item) async {
    anime.add(item);
    notifyListeners();
    await _saveAnime();
  }

  Future<void> updateAnime(AnimeItem item) async {
    final i = anime.indexWhere((a) => a.id == item.id);
    if (i != -1) anime[i] = item;
    notifyListeners();
    await _saveAnime();
  }

  Future<void> deleteAnime(String id) async {
    anime.removeWhere((a) => a.id == id);
    notifyListeners();
    await _saveAnime();
  }

  Future<void> addTag(AnimeTag tag) async {
    tags.add(tag);
    notifyListeners();
    await _saveTags();
  }

  Future<void> updateTag(AnimeTag tag) async {
    final i = tags.indexWhere((t) => t.id == tag.id);
    if (i != -1) tags[i] = tag;
    notifyListeners();
    await _saveTags();
  }

  Future<void> deleteTag(String id) async {
    tags.removeWhere((t) => t.id == id);
    anime = anime
        .map((a) => a.copyWith(tagIds: a.tagIds.where((t) => t != id).toList()))
        .toList();
    notifyListeners();
    await _saveTags();
    await _saveAnime();
  }

  Future<void> exportToFile() async {
    final data = jsonEncode({
      'anime': anime.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
    });
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/anime_backup.json');
    await file.writeAsString(data);
    await Share.shareXFiles([XFile(file.path)], text: 'Anime Tracker backup');
  }

  Future<void> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final raw = await File(result.files.single.path!).readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final importedAnime =
          (data['anime'] as List).map((e) => AnimeItem.fromJson(e)).toList();
      final importedTags =
          (data['tags'] as List).map((e) => AnimeTag.fromJson(e)).toList();

      for (final tag in importedTags) {
        final idx = tags.indexWhere((t) => t.id == tag.id);
        if (idx == -1) {
          tags.add(tag);
        } else {
          tags[idx] = tag;
        }
      }

      for (final item in importedAnime) {
        final idx = anime.indexWhere((a) => a.id == item.id);
        if (idx == -1) {
          anime.add(item);
        } else {
          anime[idx] = item;
        }
      }

      notifyListeners();
      await _saveAnime();
      await _saveTags();
    }
  }
}

// ── App ──────────────────────────────────────────────────

class AnimeTrackerApp extends StatelessWidget {
  const AnimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Store(),
      child: MaterialApp(
        title: 'Anime Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0D0D1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C3AED),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        home: const RootScreen(),
      ),
    );
  }
}

// ── Root ─────────────────────────────────────────────────

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const AnimeListScreen(),
      const TagsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF1A1A2E),
        indicatorColor: const Color(0xFF7C3AED).withOpacity(0.3),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie, color: Color(0xFF7C3AED)),
            label: 'Аниме',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline),
            selectedIcon: Icon(Icons.label, color: Color(0xFF7C3AED)),
            label: 'Теги',
          ),
        ],
      ),
    );
  }
}

// ── Anime List ───────────────────────────────────────────

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  String _query = '';
  final Set<String> _filterTagIds = {};
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AnimeItem> _filtered(List<AnimeItem> all) {
    return all.where((item) {
      final matchesTitle =
          _query.isEmpty || item.title.toLowerCase().contains(_query.toLowerCase());
      final matchesTags = _filterTagIds.isEmpty ||
          _filterTagIds.any((id) => item.tagIds.contains(id));
      return matchesTitle && matchesTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final filtered = _filtered(store.anime);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Поиск...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Аниме',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search,
                color: Colors.white70),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _query = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white70),
            tooltip: 'Экспорт',
            onPressed: () async {
              await store.exportToFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Экспорт выполнен')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white70),
            tooltip: 'Импорт',
            onPressed: () async {
              await store.importFromFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Импорт выполнен (объединение)')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (store.tags.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: store.tags.map((tag) {
                  final sel = _filterTagIds.contains(tag.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag.name,
                          style: TextStyle(
                              color: sel ? Color(tag.color) : Colors.white54,
                              fontSize: 12,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.normal)),
                      selected: sel,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _filterTagIds.add(tag.id);
                        } else {
                          _filterTagIds.remove(tag.id);
                        }
                      }),
                      backgroundColor: const Color(0xFF1A1A2E),
                      selectedColor: Color(tag.color).withOpacity(0.15),
                      checkmarkColor: Color(tag.color),
                      side: BorderSide(
                          color: sel
                              ? Color(tag.color).withOpacity(0.5)
                              : Colors.white12),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Ничего не найдено',
                        style: TextStyle(color: Colors.white38)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _AnimeCard(item: filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditSheet(context, null),
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AnimeCard extends StatelessWidget {
  final AnimeItem item;
  const _AnimeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final itemTags = store.tags.where((t) => item.tagIds.contains(t.id)).toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnimeDetailScreen(itemId: item.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            // Thumbnail
            if (item.imageBase64 != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.memory(
                  base64Decode(item.imageBase64!),
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 80,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF252540),
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: const Icon(Icons.image_outlined,
                    color: Colors.white12, size: 32),
              ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.description,
                          style:
                              const TextStyle(color: Colors.white54, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                    if (itemTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: itemTags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(t.color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Color(t.color).withOpacity(0.4)),
                                  ),
                                  child: Text(t.name,
                                      style: TextStyle(
                                          color: Color(t.color),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              color: const Color(0xFF1A1A2E),
              icon: const Icon(Icons.more_vert, color: Colors.white38),
              onSelected: (v) async {
                if (v == 'edit') {
                  _openEditSheet(context, item);
                } else if (v == 'delete') {
                  await context.read<Store>().deleteAnime(item.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Text('Редактировать',
                        style: TextStyle(color: Colors.white70))),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить',
                        style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail Screen ─────────────────────────────────────────

class AnimeDetailScreen extends StatelessWidget {
  final String itemId;
  const AnimeDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();
    final item = store.anime.firstWhere(
      (a) => a.id == itemId,
      orElse: () => AnimeItem(id: '', title: '', createdAt: DateTime.now()),
    );
    if (item.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Не найдено')));
    }
    final itemTags =
        store.tags.where((t) => item.tagIds.contains(t.id)).toList();

    // FIX: картинка — фиксированная высота, contain чтобы не обрезать
    const double imgHeight = 240;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: item.imageBase64 != null ? imgHeight : 56,
            pinned: true,
            backgroundColor: const Color(0xFF0D0D1A),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 12, right: 100),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                ),
              ),
              background: item.imageBase64 != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // FIX: BoxFit.contain — картинка целиком, без обрезки
                        Image.memory(
                          base64Decode(item.imageBase64!),
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                        // тёмный градиент снизу для читаемости заголовка
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.5, 1.0],
                              colors: [Colors.transparent, Color(0xEE0D0D1A)],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                // FIX: сохраняем store ДО Navigator.pop, чтобы context не деактивировался
                onPressed: () {
                  final s = store; // захватываем store до pop
                  Navigator.pop(context);
                  _openEditSheetWithStore(context, item, s);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('Удалить?',
                          style: TextStyle(color: Colors.white)),
                      content: Text('«${item.title}» будет удалено.',
                          style: const TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Отмена')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Удалить',
                                style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await store.deleteAnime(item.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (itemTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: itemTags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color(t.color).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Color(t.color).withOpacity(0.4)),
                                ),
                                child: Text(t.name,
                                    style: TextStyle(
                                        color: Color(t.color),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Description
                  if (item.description.isNotEmpty) ...[
                    _sectionLabel('Описание'),
                    const SizedBox(height: 8),
                    Text(item.description,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15, height: 1.6)),
                    const SizedBox(height: 20),
                  ],
                  // Note
                  if (item.note.isNotEmpty) ...[
                    _sectionLabel('Заметка'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252540),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF7C3AED).withOpacity(0.2)),
                      ),
                      child: Text(item.note,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 14, height: 1.5)),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Buttons
                  if (item.buttons.isNotEmpty) ...[
                    _sectionLabel('Ссылки'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: item.buttons.map((btn) {
                        return ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.tryParse(btn.url);
                            if (uri != null) {
                              launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: Text(btn.label),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(btn.color).withOpacity(0.85),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Created date
                  _sectionLabel('Добавлено'),
                  const SizedBox(height: 4),
                  Text(
                    '${item.createdAt.day.toString().padLeft(2, '0')}.${item.createdAt.month.toString().padLeft(2, '0')}.${item.createdAt.year}',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600));
}

// ── Tags Screen ───────────────────────────────────────────

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<Store>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text('Теги',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: store.tags.isEmpty
          ? const Center(
              child: Text('Нет тегов', style: TextStyle(color: Colors.white38)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.tags.length,
              itemBuilder: (ctx, i) {
                final tag = store.tags[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(tag.color).withOpacity(0.2),
                      child: Text(
                        tag.name[0].toUpperCase(),
                        style: TextStyle(
                            color: Color(tag.color),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(tag.name,
                        style: const TextStyle(color: Colors.white)),
                    trailing: PopupMenuButton<String>(
                      color: const Color(0xFF1A1A2E),
                      icon: const Icon(Icons.more_vert, color: Colors.white38),
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _openTagSheet(context, tag);
                        } else if (v == 'delete') {
                          await context.read<Store>().deleteTag(tag.id);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit',
                            child: Text('Редактировать',
                                style: TextStyle(color: Colors.white70))),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Удалить',
                                style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTagSheet(context, null),
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── Sheets ────────────────────────────────────────────────

const _tagColors = [
  0xFF7C3AED, 0xFF2563EB, 0xFF16A34A, 0xFFDC2626,
  0xFFEA580C, 0xFFDB2777, 0xFF0891B2, 0xFFD97706,
];

void _openTagSheet(BuildContext context, AnimeTag? existing) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  int pickedColor = existing?.color ?? _tagColors[0];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(existing == null ? 'Новый тег' : 'Редактировать тег',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec('Название тега'),
            ),
            const SizedBox(height: 16),
            const Text('Цвет',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _tagColors.map((c) {
                final sel = pickedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => pickedColor = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 2.5),
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Отмена',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    // FIX: захватываем store ДО await/pop
                    final store = context.read<Store>();
                    if (existing == null) {
                      await store.addTag(AnimeTag(
                          id: const Uuid().v4(),
                          name: nameCtrl.text.trim(),
                          color: pickedColor));
                    } else {
                      await store.updateTag(existing.copyWith(
                          name: nameCtrl.text.trim(), color: pickedColor));
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(existing == null ? 'Создать' : 'Сохранить',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

// Обёртка: передаём store явно — для вызова после Navigator.pop
void _openEditSheetWithStore(
    BuildContext context, AnimeItem? existing, Store store) {
  _openEditSheetImpl(context, existing, store);
}

void _openEditSheet(BuildContext context, AnimeItem? existing) {
  final store = context.read<Store>();
  _openEditSheetImpl(context, existing, store);
}

void _openEditSheetImpl(
    BuildContext context, AnimeItem? existing, Store store) {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final noteCtrl = TextEditingController(text: existing?.note ?? '');
  final selectedTags = Set<String>.from(existing?.tagIds ?? []);
  String? imageBase64 = existing?.imageBase64;
  final buttons = List<AnimeButton>.from(existing?.buttons ?? []);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        // Для тегов читаем store напрямую (не через ctx.watch — ctx — это sheet)
        final currentTags = store.tags;

        return Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? 'Новое аниме' : 'Редактировать',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // ── Image picker ──
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 75,
                      maxWidth: 800,
                    );
                    if (picked != null) {
                      final bytes = await File(picked.path).readAsBytes();
                      setState(() => imageBase64 = base64Encode(bytes));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF7C3AED).withOpacity(0.3)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageBase64 != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(
                                base64Decode(imageBase64!),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => imageBase64 = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit,
                                          color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text('Изменить',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: Colors.white24, size: 36),
                              SizedBox(height: 8),
                              Text('Добавить изображение',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec('Название *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec('Описание'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec('Заметка'),
                ),

                // ── Tags ──
                if (currentTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Теги',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentTags.map((tag) {
                      final sel = selectedTags.contains(tag.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (sel) {
                            selectedTags.remove(tag.id);
                          } else {
                            selectedTags.add(tag.id);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? Color(tag.color).withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel ? Color(tag.color) : Colors.white12,
                                width: sel ? 1.5 : 1),
                          ),
                          child: Text(tag.name,
                              style: TextStyle(
                                  color: sel
                                      ? Color(tag.color)
                                      : Colors.white38,
                                  fontSize: 13,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // ── Buttons ──
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Кнопки-ссылки',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () {
                        _openButtonEditor(ctx, null, (btn) {
                          setState(() => buttons.add(btn));
                        });
                      },
                      icon: const Icon(Icons.add, size: 16,
                          color: Color(0xFF7C3AED)),
                      label: const Text('Добавить',
                          style: TextStyle(
                              color: Color(0xFF7C3AED), fontSize: 12)),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ),
                if (buttons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    children: buttons.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final btn = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252540),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color(btn.color).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(btn.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(btn.label,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(btn.url,
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.white38, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _openButtonEditor(ctx, btn, (updated) {
                                  setState(() => buttons[idx] = updated);
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.redAccent, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  setState(() => buttons.removeAt(idx)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Отмена',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.trim().isEmpty) return;
                        // FIX: используем уже захваченный store, не ctx/context
                        if (existing == null) {
                          await store.addAnime(AnimeItem(
                            id: const Uuid().v4(),
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            note: noteCtrl.text.trim(),
                            tagIds: selectedTags.toList(),
                            createdAt: DateTime.now(),
                            imageBase64: imageBase64,
                            buttons: buttons,
                          ));
                        } else {
                          await store.updateAnime(existing.copyWith(
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            note: noteCtrl.text.trim(),
                            tagIds: selectedTags.toList(),
                            imageBase64: imageBase64,
                            clearImage: imageBase64 == null,
                            buttons: buttons,
                          ));
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text(
                          existing == null ? 'Добавить' : 'Сохранить',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Редактор одной кнопки-ссылки
void _openButtonEditor(
    BuildContext context, AnimeButton? existing, void Function(AnimeButton) onSave) {
  final labelCtrl = TextEditingController(text: existing?.label ?? '');
  final urlCtrl = TextEditingController(text: existing?.url ?? '');
  int pickedColor = existing?.color ?? _tagColors[0];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(existing == null ? 'Новая кнопка' : 'Редактировать кнопку',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec('Текст кнопки'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDec('URL (https://...)'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Цвет',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tagColors.map((c) {
                final sel = pickedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => pickedColor = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 2),
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (labelCtrl.text.trim().isEmpty ||
                  urlCtrl.text.trim().isEmpty) return;
              final btn = AnimeButton(
                id: existing?.id ?? const Uuid().v4(),
                label: labelCtrl.text.trim(),
                color: pickedColor,
                url: urlCtrl.text.trim(),
              );
              onSave(btn);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED)),
            child: Text(existing == null ? 'Добавить' : 'Сохранить',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

InputDecoration _inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF252540),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
    );

// ── Extension ─────────────────────────────────────────────

extension WatchExt on BuildContext {
  T watch<T extends ChangeNotifier>() =>
      _InheritedStore.of<T>(this, listen: true);
  T read<T extends ChangeNotifier>() =>
      _InheritedStore.of<T>(this, listen: false);
}

class ChangeNotifierProvider extends StatefulWidget {
  final Store Function(BuildContext) create;
  final Widget child;

  const ChangeNotifierProvider(
      {super.key, required this.create, required this.child});

  @override
  State<ChangeNotifierProvider> createState() =>
      _ChangeNotifierProviderState();
}

class _ChangeNotifierProviderState extends State<ChangeNotifierProvider> {
  late final Store _store;

  @override
  void initState() {
    super.initState();
    _store = widget.create(context);
    _store.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _InheritedStore(store: _store, child: widget.child);
}

class _InheritedStore extends InheritedWidget {
  final Store store;

  const _InheritedStore({required this.store, required super.child});

  static T of<T extends ChangeNotifier>(BuildContext context,
      {required bool listen}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<_InheritedStore>()!
          .store as T;
    } else {
      return context
          .findAncestorWidgetOfExactType<_InheritedStore>()!
          .store as T;
    }
  }

  @override
  bool updateShouldNotify(_InheritedStore old) => true;
}