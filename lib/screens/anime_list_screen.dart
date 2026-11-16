import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import '../store/store.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/edit_sheet.dart';
import '../sheets/random_pick_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_card.dart';
import '../widgets/common.dart';
import 'anime_detail_screen.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  String _query = '';
  final Set<String> _filterTagIds = {};
  bool _onlyFavorites = false;
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRandom(Store store) async {
    final s = context.s;
    final planned =
        store.anime.where((a) => a.status == WatchStatus.planned).toList();
    if (planned.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(s['random_empty'])));
      return;
    }
    final picked = await showRandomPick(context, planned);
    if (picked != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AnimeDetailScreen(itemId: picked.id)),
      );
    }
  }

  Future<void> _exportBackup(Store store) async {
    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    await store.exportToFile();
    messenger.showSnackBar(SnackBar(content: Text(s['export_done'])));
  }

  Future<void> _importBackup(Store store) async {
    final s = context.s;
    final messenger = ScaffoldMessenger.of(context);
    await store.importFromFile();
    messenger.showSnackBar(SnackBar(content: Text(s['import_done'])));
  }

  List<Widget> _actions(Store store, AppStrings s) {
    if (_showSearch) {
      return [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _showSearch = false;
            _query = '';
            _searchCtrl.clear();
          }),
        ),
      ];
    }
    return [
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: s['search_hint'],
        onPressed: () => setState(() => _showSearch = true),
      ),
      IconButton(
        icon: const Icon(Icons.casino_outlined),
        tooltip: s['random_title'],
        onPressed: () => _pickRandom(store),
      ),
      IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.85, end: 1).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            store.viewGrid
                ? Icons.view_agenda_outlined
                : Icons.grid_view_rounded,
            key: ValueKey(store.viewGrid),
          ),
        ),
        tooltip: store.viewGrid ? s['view_list'] : s['view_grid'],
        onPressed: () => store.setViewGrid(!store.viewGrid),
      ),
      PopupMenuButton<SortMode>(
        icon: const Icon(Icons.sort_rounded),
        tooltip: s['sort_menu'],
        onSelected: store.setSort,
        itemBuilder: (_) => SortMode.values.map((m) {
          final sel = store.sortMode == m;
          return PopupMenuItem<SortMode>(
            value: m,
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: sel
                      ? Icon(
                          store.sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 16,
                          color: AppColors.accent)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  s['sort_${m.name}'],
                  style: TextStyle(
                    color: sel ? AppColors.accent : AppColors.text,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (v) {
          if (v == 'export') _exportBackup(store);
          if (v == 'import') _importBackup(store);
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'export',
            child: Row(children: [
              Icon(Icons.upload_file, size: 20, color: AppColors.textDim),
              const SizedBox(width: 12),
              Text(s['tooltip_export']),
            ]),
          ),
          PopupMenuItem(
            value: 'import',
            child: Row(children: [
              Icon(Icons.download, size: 20, color: AppColors.textDim),
              const SizedBox(width: 12),
              Text(s['tooltip_import']),
            ]),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;

    final filtered = store.sortItems(store.anime.where((item) {
      final matchesTitle = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase());
      final matchesTags = _filterTagIds.isEmpty ||
          _filterTagIds.any((id) => item.tagIds.contains(id));
      final matchesFav = !_onlyFavorites || item.favorite;
      return matchesTitle && matchesTags && matchesFav;
    }));

    Widget content;
    if (filtered.isEmpty) {
      content = EmptyState(
        icon: store.anime.isEmpty
            ? Icons.movie_filter_outlined
            : Icons.search_off_rounded,
        text: store.anime.isEmpty ? s['list_empty'] : s['list_nothing_found'],
      );
    } else if (store.viewGrid) {
      content = GridView.builder(
        key: const PageStorageKey('anime_grid'),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => FadeSlideIn(
          key: ValueKey(filtered[i].id),
          index: i,
          child: AnimeGridCard(item: filtered[i]),
        ),
      );
    } else {
      content = ListView.builder(
        key: const PageStorageKey('anime_list'),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => FadeSlideIn(
          key: ValueKey(filtered[i].id),
          index: i,
          child: AnimeCard(item: filtered[i]),
        ),
      );
    }

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
                  style: TextStyle(color: AppColors.text, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: s['search_hint'],
                    hintStyle: TextStyle(color: AppColors.textFaint),
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
        actions: _actions(store, s),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: SelectableTagChip(
                      label: '★ ${s['filter_favorites']}',
                      color: AppColors.accent,
                      selected: _onlyFavorites,
                      fontSize: 12.5,
                      onTap: () =>
                          setState(() => _onlyFavorites = !_onlyFavorites),
                    ),
                  ),
                ),
                ...store.getSortedTags().map((tag) {
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
                }),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEditSheet(context, null, store),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
