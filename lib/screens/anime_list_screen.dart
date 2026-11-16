import 'package:flutter/material.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/edit_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_card.dart';
import '../widgets/common.dart';

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

    final tagOrders = {
      for (final tag in store.getSortedTags()) tag.id: tag.order
    };

    int getMinTagOrder(dynamic animeItem) {
      if (animeItem.tagIds.isEmpty) return 999999;
      return animeItem.tagIds
          .map((id) => tagOrders[id] ?? 999999)
          .reduce((a, b) => a < b ? a : b);
    }

    final filtered = store.anime.where((item) {
      final matchesTitle = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase());
      final matchesTags = _filterTagIds.isEmpty ||
          _filterTagIds.any((id) => item.tagIds.contains(id));
      return matchesTitle && matchesTags;
    }).toList()
      ..sort((a, b) {
        final orderA = getMinTagOrder(a);
        final orderB = getMinTagOrder(b);
        final tagComparison = orderA.compareTo(orderB);
        if (tagComparison != 0) return tagComparison;
        return a.title.compareTo(b.title);
      });

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0.04, 0), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: _showSearch
              ? TextField(
                  key: const ValueKey('search'),
                  controller: _searchCtrl,
                  autofocus: true,
                  style: const TextStyle(
                      color: AppColors.text, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: s['search_hint'],
                    hintStyle: const TextStyle(color: AppColors.textFaint),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                )
              : Align(
                  key: const ValueKey('title'),
                  alignment: Alignment.centerLeft,
                  child: Text(s['nav_anime']),
                ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(_showSearch ? Icons.close : Icons.search,
                  key: ValueKey(_showSearch)),
            ),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _query = '';
                _searchCtrl.clear();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: s['tooltip_export'],
            onPressed: () async {
              await store.exportToFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s['export_done'])));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: s['tooltip_import'],
            onPressed: () async {
              await store.importFromFile();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s['import_done'])));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (store.tags.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: store.getSortedTags().map((tag) {
                  final sel = _filterTagIds.contains(tag.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: SelectableTagChip(
                        label: tag.name,
                        color: Color(tag.color),
                        selected: sel,
                        fontSize: 12.5,
                        onTap: () => setState(() => sel
                            ? _filterTagIds.remove(tag.id)
                            : _filterTagIds.add(tag.id)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: store.anime.isEmpty
                        ? Icons.movie_filter_outlined
                        : Icons.search_off_rounded,
                    text: store.anime.isEmpty
                        ? s['list_empty']
                        : s['list_nothing_found'],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => FadeSlideIn(
                      key: ValueKey(filtered[i].id),
                      index: i,
                      child: AnimeCard(item: filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditSheet(context, null, store),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
