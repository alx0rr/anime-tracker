import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../models/anime_item.dart';
import '../models/anime_tag.dart';

class Store extends ChangeNotifier {
  static const _animeKey = 'anime_v3';
  static const _tagsKey = 'tags_v3';
  static const _localeKey = 'locale';

  List<AnimeItem> anime = [];
  List<AnimeTag> tags = [];
  String locale = 'ru';

  Store() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final ar = p.getString(_animeKey);
    final tr = p.getString(_tagsKey);
    locale = p.getString(_localeKey) ?? 'ru';
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
    final data = jsonEncode({
      'anime': anime.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
    });
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save backup',
      fileName: 'anime_backup.json',
    );
    if (path != null) await File(path).writeAsString(data);
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