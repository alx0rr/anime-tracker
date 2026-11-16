import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/edit_sheet.dart';
import '../sheets/anime_tags_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AnimeDetailScreen extends StatelessWidget {
  final String itemId;
  const AnimeDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;
    final item = store.anime.firstWhere(
      (a) => a.id == itemId,
      orElse: () => AnimeItem(id: '', title: '', createdAt: DateTime.now()),
    );
    if (item.id.isEmpty) {
      return const Scaffold(body: Center(child: Text('Not found')));
    }
    final itemTags =
        store.tags.where((t) => item.tagIds.contains(t.id)).toList();
    final hasImage = item.imageBase64 != null;
    final imageBytes = hasImage ? base64Decode(item.imageBase64!) : null;
    final topInset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    final actionStyle = IconButton.styleFrom(
      backgroundColor: AppColors.bg.withOpacity(0.55),
    );

    int step = 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 320 : 56,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 14, right: 132),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                ),
              ),
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageFiltered(
                          imageFilter:
                              ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                          child: Image.memory(imageBytes!, fit: BoxFit.cover),
                        ),
                        Container(color: AppColors.bg.withOpacity(0.45)),
                        Padding(
                          padding: EdgeInsets.only(
                              top: topInset, bottom: 36),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(imageBytes!,
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.65, 1.0],
                              colors: [Colors.transparent, AppColors.bg],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            actions: [
              IconButton(
                style: actionStyle,
                icon: const Icon(Icons.label_outline, color: AppColors.text),
                onPressed: () => openAnimeTagsSheet(context, item),
              ),
              IconButton(
                style: actionStyle,
                icon: const Icon(Icons.edit_outlined, color: AppColors.text),
                onPressed: () {
                  final s = store;
                  Navigator.pop(context);
                  openEditSheetWithStore(context, item, s);
                },
              ),
              IconButton(
                style: actionStyle,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.danger),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: const BorderSide(color: AppColors.outline),
                      ),
                      title: Text(s['delete_confirm_title'],
                          style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700)),
                      content: Text(
                          '«${item.title}» ${s['delete_confirm_body']}',
                          style: const TextStyle(color: AppColors.textDim)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(s['btn_cancel'],
                                style: const TextStyle(
                                    color: AppColors.textDim))),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(s['btn_delete'],
                                style: const TextStyle(
                                    color: AppColors.danger))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await store.deleteAnime(item.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (itemTags.isNotEmpty) ...[
                    FadeSlideIn(
                      index: step++,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: itemTags
                            .map((t) => TagPill(
                                  name: t.name,
                                  color: Color(t.color),
                                  fontSize: 13,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 6),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (item.description.isNotEmpty) ...[
                    FadeSlideIn(
                      index: step++,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(s['detail_description']),
                          const SizedBox(height: 10),
                          Text(item.description,
                              style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 15.5,
                                  height: 1.65)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (item.note.isNotEmpty) ...[
                    FadeSlideIn(
                      index: step++,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(s['detail_note']),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                      width: 3, color: AppColors.accent),
                                  Expanded(
                                    child: Container(
                                      color: AppColors.surfaceHigh,
                                      padding: const EdgeInsets.all(16),
                                      child: Text(item.note,
                                          style: const TextStyle(
                                              color: AppColors.text,
                                              fontSize: 14.5,
                                              height: 1.55)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (item.buttons.isNotEmpty) ...[
                    FadeSlideIn(
                      index: step++,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(s['detail_links']),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: item.buttons.map((btn) {
                              final c = Color(btn.color);
                              return ElevatedButton.icon(
                                onPressed: () {
                                  final uri = Uri.tryParse(btn.url);
                                  if (uri != null) {
                                    launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.open_in_new, size: 14),
                                label: Text(btn.label),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c,
                                  foregroundColor: AppColors.on(c),
                                  textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  FadeSlideIn(
                    index: step++,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(s['detail_added']),
                        const SizedBox(height: 6),
                        Text(
                          '${item.createdAt.day.toString().padLeft(2, '0')}.${item.createdAt.month.toString().padLeft(2, '0')}.${item.createdAt.year}',
                          style: const TextStyle(
                              color: AppColors.textFaint, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
