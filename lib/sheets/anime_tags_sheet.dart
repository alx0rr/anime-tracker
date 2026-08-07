import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';

void openAnimeTagsSheet(BuildContext context, AnimeItem item) {
  final store = context.storeR;
  final s = context.s;
  final selectedTags = Set<String>.from(item.tagIds);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s['tags_manage'],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.getSortedTags().map((tag) {
                final sel = selectedTags.contains(tag.id);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      selectedTags.remove(tag.id);
                    } else {
                      selectedTags.add(tag.id);
                    }
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? Color(tag.color).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? Color(tag.color) : Colors.white12,
                          width: sel ? 1.5 : 1),
                    ),
                    child: Text(tag.name,
                        style: TextStyle(
                            color: sel ? Color(tag.color) : Colors.white38,
                            fontSize: 13,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(s['btn_cancel'],
                      style: const TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await store.updateAnime(
                        item.copyWith(tagIds: selectedTags.toList()));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(s['btn_save'],
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}