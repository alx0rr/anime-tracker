import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/anime_tag.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../utils/input_decoration.dart';

void openTagSheet(BuildContext context, AnimeTag? existing) {
  final s = context.s;
  final store = context.storeR;
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  int pickedColor = existing?.color ?? kTagColors[0];

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
              existing == null ? s['tag_new'] : s['tag_edit'],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: inputDec(s['tag_name']),
            ),
            const SizedBox(height: 16),
            Text(s['tag_color'],
                style:
                    const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: kTagColors.map((c) {
                final sel = pickedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => pickedColor = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 2.5),
                    ),
                    child: sel
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
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
                    if (nameCtrl.text.trim().isEmpty) return;
                    if (existing == null) {
                      await store.addTag(AnimeTag(
                          id: const Uuid().v4(),
                          name: nameCtrl.text.trim(),
                          color: pickedColor));
                    } else {
                      await store.updateTag(existing.copyWith(
                          name: nameCtrl.text.trim(), color: pickedColor));
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(
                    existing == null ? s['btn_add'] : s['btn_save'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}