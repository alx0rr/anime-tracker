import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/anime_item.dart';
import '../models/anime_button.dart';
import '../store/store.dart';
import '../l10n/strings.dart';
import '../utils/input_decoration.dart';
import 'button_editor.dart';


void openEditSheetWithStore(
    BuildContext context, AnimeItem? existing, Store store) {
  _show(context, existing, store);
}


void openEditSheet(BuildContext context, AnimeItem? existing, Store store) {
  _show(context, existing, store);
}

void _show(BuildContext context, AnimeItem? existing, Store store) {
  final s = context.s;
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final noteCtrl = TextEditingController(text: existing?.note ?? '');
  final selectedTags = Set<String>.from(existing?.tagIds ?? []);
  String? imageBase64 = existing?.imageBase64;
  final buttons = List<AnimeButton>.from(existing?.buttons ?? []);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final currentTags = store.tags;

        return Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? s['edit_new_anime'] : s['edit_edit_anime'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 75,
                      maxWidth: 800,
                    );
                    if (picked != null) {
                      final bytes = await File(picked.path).readAsBytes();
                      setState(() => imageBase64 = base64Encode(bytes));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF7C3AED).withOpacity(0.3)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageBase64 != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(base64Decode(imageBase64!),
                                  fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => imageBase64 = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit,
                                          color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(s['edit_change_image'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined,
                                  color: Colors.white24, size: 36),
                              const SizedBox(height: 8),
                              Text(s['edit_add_image'],
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDec(s['edit_field_title']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDec(s['edit_field_desc']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDec(s['edit_field_note']),
                ),

                // Tags
                if (currentTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(s['edit_tags'],
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentTags.map((tag) {
                      final sel = selectedTags.contains(tag.id);
                      return GestureDetector(
                        onTap: () => setState(() => sel
                            ? selectedTags.remove(tag.id)
                            : selectedTags.add(tag.id)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? Color(tag.color).withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    sel ? Color(tag.color) : Colors.white12,
                                width: sel ? 1.5 : 1),
                          ),
                          child: Text(tag.name,
                              style: TextStyle(
                                  color: sel
                                      ? Color(tag.color)
                                      : Colors.white38,
                                  fontSize: 13,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Buttons
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['edit_buttons'],
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () => openButtonEditor(ctx, null, (btn) {
                        setState(() => buttons.add(btn));
                      }),
                      icon: const Icon(Icons.add,
                          size: 16, color: Color(0xFF7C3AED)),
                      label: Text(s['edit_add_button'],
                          style: const TextStyle(
                              color: Color(0xFF7C3AED), fontSize: 12)),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ),
                if (buttons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    children: buttons.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final btn = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252540),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color(btn.color).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: Color(btn.color),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(btn.label,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(btn.url,
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.white38, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => openButtonEditor(ctx, btn,
                                  (updated) => setState(
                                      () => buttons[idx] = updated)),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.redAccent, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () =>
                                  setState(() => buttons.removeAt(idx)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

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
                        if (titleCtrl.text.trim().isEmpty) return;
                        if (existing == null) {
                          await store.addAnime(AnimeItem(
                            id: const Uuid().v4(),
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            note: noteCtrl.text.trim(),
                            tagIds: selectedTags.toList(),
                            createdAt: DateTime.now(),
                            imageBase64: imageBase64,
                            buttons: buttons,
                          ));
                        } else {
                          await store.updateAnime(existing.copyWith(
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            note: noteCtrl.text.trim(),
                            tagIds: selectedTags.toList(),
                            imageBase64: imageBase64,
                            clearImage: imageBase64 == null,
                            buttons: buttons,
                          ));
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );
}