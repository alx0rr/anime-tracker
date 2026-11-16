import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

void openAnimeTagsSheet(BuildContext context, AnimeItem item) {
  final store = context.storeR;
  final s = context.s;
  final selectedTags = Set<String>.from(item.tagIds);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 4,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s['tags_manage'],
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.getSortedTags().map((tag) {
                return SelectableTagChip(
                  label: tag.name,
                  color: Color(tag.color),
                  selected: selectedTags.contains(tag.id),
                  onTap: () => setState(() {
                    if (!selectedTags.remove(tag.id)) {
                      selectedTags.add(tag.id);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
            SheetActions(
              cancelLabel: s['btn_cancel'],
              confirmLabel: s['btn_save'],
              onCancel: () => Navigator.pop(ctx),
              onConfirm: () async {
                await store.updateAnime(
                    item.copyWith(tagIds: selectedTags.toList()));
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
