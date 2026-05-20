import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/anime_button.dart';
import '../l10n/strings.dart';
import '../utils/input_decoration.dart';

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
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          existing == null ? s['btn_editor_new'] : s['btn_editor_edit'],
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: inputDec(s['btn_editor_label']),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: inputDec(s['btn_editor_url']),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(s['btn_editor_color'],
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 13)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: kTagColors.map((c) {
                final sel = pickedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => pickedColor = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 2),
                    ),
                    child: sel
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s['btn_cancel'],
                style: const TextStyle(color: Colors.white54)),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED)),
            child: Text(
              existing == null ? s['btn_add'] : s['btn_save'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}