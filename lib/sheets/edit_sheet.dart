import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/anime_item.dart';
import '../models/anime_button.dart';
import '../store/store.dart';
import '../l10n/strings.dart';
import '../utils/input_decoration.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_meta.dart';
import '../widgets/common.dart';
import 'anime_search_sheet.dart';
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
  var status = existing?.status ?? WatchStatus.planned;
  final progressCtrl = TextEditingController(
      text: (existing?.progress ?? 0) > 0 ? '${existing!.progress}' : '');
  final totalCtrl = TextEditingController(
      text: (existing?.totalEpisodes ?? 0) > 0
          ? '${existing!.totalEpisodes}'
          : '');
  int? rating = existing?.rating;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final currentTags = store.getSortedTags();

        Future<void> findOnline() async {
          final r = await openAnimeSearchSheet(ctx,
              initialQuery: titleCtrl.text.trim());
          if (r == null) return;
          setState(() {
            titleCtrl.text = r.title;
            if (r.description.isNotEmpty) descCtrl.text = r.description;
            if (r.episodes > 0) totalCtrl.text = '${r.episodes}';
            if (r.imageBase64 != null) imageBase64 = r.imageBase64;
            if (r.url.isNotEmpty && !buttons.any((b) => b.url == r.url)) {
              buttons.add(AnimeButton(
                id: const Uuid().v4(),
                label: r.source.label,
                color: r.source.color,
                url: r.url,
              ));
            }
          });
        }

        return Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 4,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? s['edit_new_anime'] : s['edit_edit_anime'],
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: findOnline,
                    icon: Icon(Icons.travel_explore_rounded,
                        size: 18, color: AppColors.accent),
                    label: Text(s['search_online']),
                  ),
                ),
                const SizedBox(height: 12),

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
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.35)),
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
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.accent, size: 36),
                              const SizedBox(height: 8),
                              Text(s['edit_add_image'],
                                  style: TextStyle(
                                      color: AppColors.textDim, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: AppColors.text),
                  decoration: inputDec(s['edit_field_title']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: TextStyle(color: AppColors.text),
                  decoration: inputDec(s['edit_field_desc']),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: TextStyle(color: AppColors.text),
                  decoration: inputDec(s['edit_field_note']),
                ),

                const SizedBox(height: 16),
                Text(s['edit_status'],
                    style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                const SizedBox(height: 8),
                StatusPicker(
                  value: status,
                  onChanged: (v) => setState(() => status = v),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: progressCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(color: AppColors.text),
                        decoration: inputDec(s['edit_progress']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: totalCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(color: AppColors.text),
                        decoration: inputDec(s['edit_total_episodes']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(s['edit_rating'],
                    style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                const SizedBox(height: 10),
                RatingPicker(
                  value: rating,
                  onChanged: (v) => setState(() => rating = v),
                ),

                if (currentTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(s['edit_tags'],
                      style: TextStyle(
                          color: AppColors.textDim, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentTags.map((tag) {
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
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['edit_buttons'],
                        style: TextStyle(
                            color: AppColors.textDim, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () => openButtonEditor(ctx, null, (btn) {
                        setState(() => buttons.add(btn));
                      }),
                      icon: Icon(Icons.add,
                          size: 16, color: AppColors.accent),
                      label: Text(s['edit_add_button'],
                          style: TextStyle(
                              color: AppColors.accent, fontSize: 12)),
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
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
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
                                      style: TextStyle(
                                          color: AppColors.text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(btn.url,
                                      style: TextStyle(
                                          color: AppColors.textFaint,
                                          fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: AppColors.textFaint, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => openButtonEditor(ctx, btn,
                                  (updated) => setState(
                                      () => buttons[idx] = updated)),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: AppColors.danger, size: 18),
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
                SheetActions(
                  cancelLabel: s['btn_cancel'],
                  confirmLabel: existing == null ? s['btn_add'] : s['btn_save'],
                  onCancel: () => Navigator.pop(ctx),
                  onConfirm: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final progress =
                        int.tryParse(progressCtrl.text.trim()) ?? 0;
                    final total = int.tryParse(totalCtrl.text.trim()) ?? 0;
                    final base = existing ??
                        AnimeItem(
                          id: const Uuid().v4(),
                          title: '',
                          createdAt: DateTime.now(),
                        );
                    var item = base.copyWith(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      note: noteCtrl.text.trim(),
                      tagIds: selectedTags.toList(),
                      imageBase64: imageBase64,
                      clearImage: imageBase64 == null,
                      buttons: buttons,
                      status: status,
                      totalEpisodes: total,
                      progress: progress,
                      rating: rating,
                      clearRating: rating == null,
                    );
                    if (status == base.status) item = item.withProgress(progress);
                    if (existing == null) {
                      await store.addAnime(item);
                    } else {
                      await store.updateAnime(item);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );
}