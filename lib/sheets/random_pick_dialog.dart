import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/anime_item.dart';
import '../theme/app_theme.dart';

Future<AnimeItem?> showRandomPick(
    BuildContext context, List<AnimeItem> candidates) {
  return showDialog<AnimeItem>(
    context: context,
    builder: (_) => _RandomPickDialog(candidates: candidates),
  );
}

class _RandomPickDialog extends StatefulWidget {
  final List<AnimeItem> candidates;
  const _RandomPickDialog({required this.candidates});

  @override
  State<_RandomPickDialog> createState() => _RandomPickDialogState();
}

class _RandomPickDialogState extends State<_RandomPickDialog> {
  final _rng = Random();
  late AnimeItem _current = _roll(null);

  AnimeItem _roll(AnimeItem? except) {
    final pool = widget.candidates.length > 1 && except != null
        ? widget.candidates.where((a) => a.id != except.id).toList()
        : widget.candidates;
    return pool[_rng.nextInt(pool.length)];
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final item = _current;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outline),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      content: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey(item.id),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s['random_title'].toUpperCase(),
                style: TextStyle(
                    color: AppColors.textFaint,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: item.imageBase64 != null
                    ? Image.memory(base64Decode(item.imageBase64!),
                        width: 150, height: 214, fit: BoxFit.cover)
                    : Container(
                        width: 150,
                        height: 214,
                        color: AppColors.surfaceHigh,
                        child: Icon(Icons.movie_outlined,
                            color: AppColors.textFaint, size: 44),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w800),
              ),
              if (item.totalEpisodes > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${item.totalEpisodes} ${s['search_ep_short']}',
                  style: TextStyle(color: AppColors.textFaint, fontSize: 12.5),
                ),
              ],
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textDim, fontSize: 13, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      actions: [
        if (widget.candidates.length > 1)
          TextButton.icon(
            onPressed: () => setState(() => _current = _roll(_current)),
            icon: const Icon(Icons.casino_outlined, size: 18),
            label: Text(s['random_again']),
          )
        else
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(s['btn_cancel'], style: TextStyle(color: AppColors.textDim)),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _current),
          child: Text(s['random_open']),
        ),
      ],
    );
  }
}
