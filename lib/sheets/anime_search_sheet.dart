import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/anime_search.dart';
import '../theme/app_theme.dart';
import '../utils/input_decoration.dart';
import '../widgets/common.dart';

Future<AnimeSearchResult?> openAnimeSearchSheet(
  BuildContext context, {
  String initialQuery = '',
}) {
  final locale = context.l10n.locale;
  final ru = locale == 'ru' || locale == 'ua';
  return showModalBottomSheet<AnimeSearchResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SearchSheet(initialQuery: initialQuery, preferRussian: ru),
  );
}

class _SearchSheet extends StatefulWidget {
  final String initialQuery;
  final bool preferRussian;
  const _SearchSheet(
      {required this.initialQuery, required this.preferRussian});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialQuery);
  late AnimeSource _source =
      widget.preferRussian ? AnimeSource.shikimori : AnimeSource.anilist;
  Timer? _debounce;
  int _requestId = 0;

  List<AnimeSearchResult> _results = [];
  bool _loading = false;
  bool _failed = false;
  String? _pickingId;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.trim().length >= 2) _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _search);
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    final id = ++_requestId;
    if (q.length < 2) {
      setState(() {
        _results = [];
        _loading = false;
        _failed = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final res = await AnimeSearchService.search(_source, q,
          preferRussian: widget.preferRussian);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = res;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = [];
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _pick(AnimeSearchResult r) async {
    if (_pickingId != null) return;
    setState(() => _pickingId = r.id);
    final full = await AnimeSearchService.loadDetails(r);
    if (!mounted) return;
    Navigator.pop(context, full);
  }

  String _subtitle(AnimeSearchResult r) {
    final s = context.s;
    final parts = <String>[
      if (r.altTitle.isNotEmpty) r.altTitle,
      if (r.year.isNotEmpty) r.year,
      if (r.episodes > 0) '${r.episodes} ${s['search_ep_short']}',
    ];
    return parts.join(' · ');
  }

  Widget _poster(AnimeSearchResult r) {
    final placeholder = Container(
      width: 48,
      height: 68,
      color: AppColors.surfaceHigh,
      child: Icon(Icons.movie_outlined, color: AppColors.textFaint, size: 22),
    );
    final url = r.posterUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null
          ? placeholder
          : Image.network(
              url,
              width: 48,
              height: 68,
              fit: BoxFit.cover,
              headers: kAnimeHttpHeaders,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_failed) {
      body = _Hint(icon: Icons.wifi_off_rounded, text: s['search_error']);
    } else if (_ctrl.text.trim().length < 2) {
      body = _Hint(icon: Icons.travel_explore_rounded, text: s['search_hint_type']);
    } else if (_results.isEmpty) {
      body = _Hint(icon: Icons.search_off_rounded, text: s['search_nothing']);
    } else {
      body = ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _results.length,
        itemBuilder: (_, i) {
          final r = _results[i];
          final sub = _subtitle(r);
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: _poster(r),
            title: Text(r.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.text, fontWeight: FontWeight.w700)),
            subtitle: sub.isEmpty
                ? null
                : Text(sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textFaint, fontSize: 12.5)),
            trailing: _pickingId == r.id
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : null,
            onTap: () => _pick(r),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Text(s['search_title'],
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: AppColors.text),
                decoration: inputDec(s['search_field']).copyWith(
                  prefixIcon: Icon(Icons.search, color: AppColors.textFaint),
                ),
                onChanged: _onChanged,
                onSubmitted: (_) => _search(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Wrap(
                spacing: 8,
                children: AnimeSource.values
                    .map((src) => SelectableTagChip(
                          label: src.label,
                          color: Color(src.color),
                          selected: _source == src,
                          fontSize: 12.5,
                          onTap: () {
                            if (_source == src) return;
                            setState(() => _source = src);
                            _search();
                          },
                        ))
                    .toList(),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Hint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textFaint, size: 40),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textDim, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      );
}
