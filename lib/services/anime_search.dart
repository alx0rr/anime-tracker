import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes;

const kAnimeHttpHeaders = {'User-Agent': 'AnimeTracker/2.4 (personal app)'};

enum AnimeSource {
  shikimori('Shikimori', 0xFF5F9AA8, 'https://shikimori.one'),
  anilist('AniList', 0xFF6F86B8, 'https://anilist.co');

  final String label;

  final int color;
  final String site;
  const AnimeSource(this.label, this.color, this.site);
}

class AnimeSearchResult {
  final AnimeSource source;
  final String id;
  final String title;

  final String altTitle;
  final String year;
  final int episodes;
  final String? posterUrl;

  final String url;

  String description;
  String? imageBase64;

  AnimeSearchResult({
    required this.source,
    required this.id,
    required this.title,
    this.altTitle = '',
    this.year = '',
    this.episodes = 0,
    this.posterUrl,
    this.url = '',
    this.description = '',
    this.imageBase64,
  });
}

class AnimeSearchService {
  AnimeSearchService._();


  static Future<List<int>> _send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.openUrl(method, uri);
      kAnimeHttpHeaders.forEach((k, v) => req.headers.set(k, v));
      headers.forEach((k, v) => req.headers.set(k, v));
      if (body != null) {
        final bytes = utf8.encode(body);
        req.contentLength = bytes.length;
        req.add(bytes);
      }
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('HTTP ${res.statusCode}', uri: uri);
      }
      return await consolidateHttpClientResponseBytes(res)
          .timeout(const Duration(seconds: 20));
    } finally {
      client.close(force: true);
    }
  }

  static Future<dynamic> _getJson(Uri uri) async =>
      jsonDecode(utf8.decode(await _send('GET', uri)));


  static Future<List<AnimeSearchResult>> search(
    AnimeSource source,
    String query, {
    bool preferRussian = true,
  }) {
    switch (source) {
      case AnimeSource.shikimori:
        return _searchShikimori(query, preferRussian);
      case AnimeSource.anilist:
        return _searchAniList(query);
    }
  }

  static Future<List<AnimeSearchResult>> _searchShikimori(
      String query, bool ru) async {
    final uri = Uri.https('shikimori.one', '/api/animes', {
      'search': query,
      'limit': '12',
    });
    final data = await _getJson(uri) as List<dynamic>;
    return data.map((e) {
      final m = e as Map<String, dynamic>;
      final name = (m['name'] as String?) ?? '';
      final rus = (m['russian'] as String?) ?? '';
      final title = (ru && rus.isNotEmpty) ? rus : name;
      final alt = title == name ? rus : name;
      final aired = (m['aired_on'] as String?) ?? '';
      final preview = (m['image'] as Map<String, dynamic>?)?['preview'];
      final path = (m['url'] as String?) ?? '';
      return AnimeSearchResult(
        source: AnimeSource.shikimori,
        id: '${m['id']}',
        title: title,
        altTitle: alt == title ? '' : alt,
        year: aired.length >= 4 ? aired.substring(0, 4) : '',
        episodes: (m['episodes'] as num?)?.toInt() ?? 0,
        posterUrl: _absolute(AnimeSource.shikimori.site, preview as String?),
        url: path.isEmpty ? '' : '${AnimeSource.shikimori.site}$path',
      );
    }).toList();
  }

  static const _aniListQuery = r'''
query ($search: String) {
  Page(page: 1, perPage: 12) {
    media(search: $search, type: ANIME, sort: SEARCH_MATCH) {
      id
      siteUrl
      title { romaji english }
      coverImage { large }
      episodes
      startDate { year }
      description(asHtml: false)
    }
  }
}''';

  static Future<List<AnimeSearchResult>> _searchAniList(String query) async {
    final raw = await _send(
      'POST',
      Uri.https('graphql.anilist.co', '/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': _aniListQuery,
        'variables': {'search': query},
      }),
    );
    final json = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
    final media = (((json['data'] as Map<String, dynamic>?)?['Page']
            as Map<String, dynamic>?)?['media'] as List<dynamic>?) ??
        const [];
    return media.map((e) {
      final m = e as Map<String, dynamic>;
      final t = (m['title'] as Map<String, dynamic>?) ?? const {};
      final romaji = (t['romaji'] as String?) ?? '';
      final english = (t['english'] as String?) ?? '';
      final title = english.isNotEmpty ? english : romaji;
      final year = (m['startDate'] as Map<String, dynamic>?)?['year'];
      final cover = (m['coverImage'] as Map<String, dynamic>?)?['large'];
      return AnimeSearchResult(
        source: AnimeSource.anilist,
        id: '${m['id']}',
        title: title,
        altTitle: romaji == title ? '' : romaji,
        year: year == null ? '' : '$year',
        episodes: (m['episodes'] as num?)?.toInt() ?? 0,
        posterUrl: cover as String?,
        url: (m['siteUrl'] as String?) ?? '',
        description: _cleanHtml((m['description'] as String?) ?? ''),
      );
    }).toList();
  }


  static Future<AnimeSearchResult> loadDetails(AnimeSearchResult r) async {
    await Future.wait([_loadDescription(r), _loadPoster(r)]);
    return r;
  }

  static Future<void> _loadDescription(AnimeSearchResult r) async {
    if (r.source != AnimeSource.shikimori || r.description.isNotEmpty) return;
    try {
      final m = await _getJson(Uri.https('shikimori.one', '/api/animes/${r.id}'))
          as Map<String, dynamic>;
      r.description = _cleanBbCode((m['description'] as String?) ?? '');
    } catch (_) {}
  }

  static Future<void> _loadPoster(AnimeSearchResult r) async {
    final url = r.posterUrl;
    if (url == null || url.isEmpty) return;
    try {
      r.imageBase64 = base64Encode(await _send('GET', Uri.parse(url)));
    } catch (_) {}
  }


  static String? _absolute(String site, String? path) {
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : '$site$path';
  }

  static String _cleanBbCode(String s) {
    var out = s.replaceAllMapped(
        RegExp(r'\[\[([^\]]*)\]\]'), (m) => m.group(1) ?? '');
    out = out.replaceAll(RegExp(r'\[/?[a-zA-Z_]+(?:=[^\]]*)?\]'), '');
    return out.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  static String _cleanHtml(String s) {
    var out = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    out = out.replaceAll(RegExp(r'<[^>]+>'), '');
    out = out
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return out.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}
