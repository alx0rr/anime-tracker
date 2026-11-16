import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../models/anime_item.dart';
import '../models/anime_tag.dart';

enum SortMode { tags, added, title, rating }

class Store extends ChangeNotifier {
  static const _animeKey = 'anime_v3';
  static const _tagsKey = 'tags_v3';
  static const _localeKey = 'locale';
  static const themeModeKey = 'theme_mode';
  static const viewGridKey = 'view_grid';
  static const accentKey = 'accent_color';
  static const _sortModeKey = 'sort_mode';
  static const _sortAscKey = 'sort_asc';

  List<AnimeItem> anime = [];
  List<AnimeTag> tags = [];
  String locale = 'ru';

  String themeMode;
  bool viewGrid;

  int? accentColor;
  SortMode sortMode = SortMode.tags;
  bool sortAscending = true;

  Store({
    this.themeMode = 'dark',
    this.viewGrid = false,
    this.accentColor,
  }) {
    _load();
  }

  static bool _defaultAsc(SortMode m) =>
      m == SortMode.tags || m == SortMode.title;

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final ar = p.getString(_animeKey);
    final tr = p.getString(_tagsKey);
    locale = p.getString(_localeKey) ?? 'ru';
    themeMode = p.getString(themeModeKey) ?? themeMode;
    viewGrid = p.getBool(viewGridKey) ?? viewGrid;
    accentColor = p.getInt(accentKey) ?? accentColor;
    final sm = p.getString(_sortModeKey);
    sortMode = SortMode.values.firstWhere((m) => m.name == sm,
        orElse: () => SortMode.tags);
    sortAscending = p.getBool(_sortAscKey) ?? _defaultAsc(sortMode);
    if (ar != null) {
      anime =
          (jsonDecode(ar) as List).map((e) => AnimeItem.fromJson(e)).toList();
    }
    if (tr != null) {
      tags = (jsonDecode(tr) as List).map((e) => AnimeTag.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveAnime() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _animeKey, jsonEncode(anime.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveTags() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _tagsKey, jsonEncode(tags.map((e) => e.toJson()).toList()));
  }

  Future<void> saveLocale(String loc) async {
    locale = loc;
    final p = await SharedPreferences.getInstance();
    await p.setString(_localeKey, loc);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    themeMode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(themeModeKey, mode);
  }

  Future<void> setAccentColor(int? color) async {
    accentColor = color;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    if (color == null) {
      await p.remove(accentKey);
    } else {
      await p.setInt(accentKey, color);
    }
  }

  Future<void> setViewGrid(bool grid) async {
    viewGrid = grid;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(viewGridKey, grid);
  }

  Future<void> setSort(SortMode mode) async {
    if (mode == sortMode) {
      sortAscending = !sortAscending;
    } else {
      sortMode = mode;
      sortAscending = _defaultAsc(mode);
    }
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_sortModeKey, sortMode.name);
    await p.setBool(_sortAscKey, sortAscending);
  }

  List<AnimeItem> sortItems(Iterable<AnimeItem> items) {
    final tagOrders = {for (final t in tags) t.id: t.order};
    int minTag(AnimeItem a) => a.tagIds.isEmpty
        ? 999999
        : a.tagIds
            .map((id) => tagOrders[id] ?? 999999)
            .reduce((x, y) => x < y ? x : y);
    int byTitle(AnimeItem a, AnimeItem b) =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase());

    int cmp(AnimeItem a, AnimeItem b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      int r;
      switch (sortMode) {
        case SortMode.tags:
          r = minTag(a).compareTo(minTag(b));
          if (r == 0) r = byTitle(a, b);
          return sortAscending ? r : -r;
        case SortMode.added:
          r = a.createdAt.compareTo(b.createdAt);
          return sortAscending ? r : -r;
        case SortMode.title:
          r = byTitle(a, b);
          return sortAscending ? r : -r;
        case SortMode.rating:
          if (a.rating == null && b.rating == null) return byTitle(a, b);
          if (a.rating == null) return 1;
          if (b.rating == null) return -1;
          r = a.rating!.compareTo(b.rating!);
          if (r == 0) return byTitle(a, b);
          return sortAscending ? r : -r;
      }
    }

    return items.toList()..sort(cmp);
  }

  Future<void> toggleFavorite(String id) async {
    final i = anime.indexWhere((a) => a.id == id);
    if (i == -1) return;
    anime[i] = anime[i].copyWith(favorite: !anime[i].favorite);
    notifyListeners();
    await _saveAnime();
  }

  Future<void> togglePin(String id) async {
    final i = anime.indexWhere((a) => a.id == id);
    if (i == -1) return;
    anime[i] = anime[i].copyWith(pinned: !anime[i].pinned);
    notifyListeners();
    await _saveAnime();
  }

  Future<void> restoreAnime(AnimeItem item) async {
    if (anime.any((a) => a.id == item.id)) return;
    anime.add(item);
    notifyListeners();
    await _saveAnime();
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
        .map((a) =>
            a.copyWith(tagIds: a.tagIds.where((t) => t != id).toList()))
        .toList();
    notifyListeners();
    await _saveTags();
    await _saveAnime();
  }

  Future<void> exportToFile() async {
    final jsonString = jsonEncode({
      'anime': anime.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
    });

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save backup',
      fileName: 'anime_backup.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path != null) {
      final file = File(path);
      await file.writeAsString(jsonString);
    }
  }

  Future<void> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath == null) return;

      final raw = await File(filePath).readAsString();
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

  Future<void> reorderTags(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final tagsList = getSortedTags();

    final item = tagsList.removeAt(oldIndex);
    tagsList.insert(newIndex, item);

    for (int i = 0; i < tagsList.length; i++) {
      tagsList[i] = tagsList[i].copyWith(order: i);
    }

    this.tags = tagsList;
    notifyListeners();
    await _saveTags();
  }

  List<AnimeTag> getSortedTags() {
    final sorted = List<AnimeTag>.from(tags);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }
}