import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../theme/app_theme.dart';
import '../utils/delete_undo.dart';
import 'edit_sheet.dart';

void showAnimeActions(BuildContext context, AnimeItem item) {
  final store = context.storeR;
  final s = context.s;

  Widget tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.text;
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textDim),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          tile(
            icon: item.favorite
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            label: item.favorite ? s['action_unfavorite'] : s['action_favorite'],
            onTap: () {
              Navigator.pop(ctx);
              store.toggleFavorite(item.id);
            },
          ),
          tile(
            icon: item.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: item.pinned ? s['action_unpin'] : s['action_pin'],
            onTap: () {
              Navigator.pop(ctx);
              store.togglePin(item.id);
            },
          ),
          tile(
            icon: Icons.edit_outlined,
            label: s['edit_edit_anime'],
            onTap: () {
              Navigator.pop(ctx);
              openEditSheet(context, item, store);
            },
          ),
          tile(
            icon: Icons.delete_outline_rounded,
            label: s['btn_delete'],
            color: AppColors.danger,
            onTap: () {
              Navigator.pop(ctx);
              deleteWithUndo(context, item);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
