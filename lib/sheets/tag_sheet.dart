import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/anime_tag.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../utils/input_decoration.dart';
import '../widgets/common.dart';

void openTagSheet(BuildContext context, AnimeTag? existing) {
  final s = context.s;
  final store = context.storeR;
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  int pickedColor = existing?.color ?? kTagColors[0];

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
              existing == null ? s['tag_new'] : s['tag_edit'],
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration: inputDec(s['tag_name']),
            ),
            const SizedBox(height: 18),
            Text(s['tag_color'],
                style:
                    const TextStyle(color: AppColors.textDim, fontSize: 13)),
            const SizedBox(height: 12),
            ColorPalettePicker(
              selected: pickedColor,
              size: 36,
              onPick: (c) => setState(() => pickedColor = c),
            ),
            const SizedBox(height: 26),
            SheetActions(
              cancelLabel: s['btn_cancel'],
              confirmLabel: existing == null ? s['btn_add'] : s['btn_save'],
              onCancel: () => Navigator.pop(ctx),
              onConfirm: () async {
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
            ),
          ],
        ),
      ),
    ),
  );
}
