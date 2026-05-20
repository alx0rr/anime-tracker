import 'package:flutter/material.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/edit_sheet.dart';
import '../widgets/anime_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;

    final filtered = store.anime.where((item) {
      final matchesTitle = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase());
      final matchesTags = _filterTagIds.isEmpty ||
          _filterTagIds.any((id) => item.tagIds.contains(id));
      return matchesTitle && matchesTags;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: s['search_hint'],
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : Text(s['nav_anime'],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search,
                color: Colors.white70),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _query = '';
                _searchCtrl.clear();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white70),
            tooltip: s['tooltip_export'],
            onPressed: () async {
              await store.exportToFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s['export_done'])));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white70),
            tooltip: s['tooltip_import'],
            onPressed: () async {
              await store.importFromFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s['import_done'])));
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
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                      selected: sel,
                      onSelected: (v) => setState(() =>
                          v ? _filterTagIds.add(tag.id) : _filterTagIds.remove(tag.id)),
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
                ? Center(
                    child: Text(
                      store.anime.isEmpty
                          ? s['list_empty']
                          : s['list_nothing_found'],
                      style: const TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => AnimeCard(item: filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditSheet(context, null, store),
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}