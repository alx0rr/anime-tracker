import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';

Future<void> deleteWithUndo(BuildContext context, AnimeItem item) async {
  final store = context.storeR;
  final s = context.s;
  final messenger = ScaffoldMessenger.of(context);
  final message = '«${item.title}» ${s['deleted_suffix']}';
  final undoLabel = s['undo'];

  final removed = store.deleteAnime(item.id);
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: undoLabel,
        onPressed: () => store.restoreAnime(item),
      ),
    ));
  await removed;
}
