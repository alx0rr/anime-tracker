import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/anime_button.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../utils/input_decoration.dart';
import '../widgets/common.dart';

void openButtonEditor(
  BuildContext context,
  AnimeButton? existing,
  void Function(AnimeButton) onSave,
) {
  final s = context.s;
  final labelCtrl = TextEditingController(text: existing?.label ?? '');
  final urlCtrl = TextEditingController(text: existing?.url ?? '');
  int pickedColor = existing?.color ?? kTagColors[0];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.outline),
        ),
        title: Text(
          existing == null ? s['btn_editor_new'] : s['btn_editor_edit'],
          style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                style: const TextStyle(color: AppColors.text),
                decoration: inputDec(s['btn_editor_label']),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: AppColors.text),
                decoration: inputDec(s['btn_editor_url']),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(s['btn_editor_color'],
                    style: const TextStyle(
                        color: AppColors.textDim, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ColorPalettePicker(
                  selected: pickedColor,
                  size: 32,
                  spacing: 8,
                  onPick: (c) => setState(() => pickedColor = c),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s['btn_cancel'],
                style: const TextStyle(color: AppColors.textDim)),
          ),
          ElevatedButton(
            onPressed: () {
              if (labelCtrl.text.trim().isEmpty ||
                  urlCtrl.text.trim().isEmpty) return;
              onSave(AnimeButton(
                id: existing?.id ?? const Uuid().v4(),
                label: labelCtrl.text.trim(),
                color: pickedColor,
                url: urlCtrl.text.trim(),
              ));
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? s['btn_add'] : s['btn_save']),
          ),
        ],
      ),
    ),
  );
}
