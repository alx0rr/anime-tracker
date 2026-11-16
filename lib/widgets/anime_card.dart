import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../sheets/edit_sheet.dart';
import '../screens/anime_detail_screen.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class AnimeCard extends StatelessWidget {
  final AnimeItem item;
  const AnimeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final itemTags =
        store.tags.where((t) => item.tagIds.contains(t.id)).toList();

    const posterW = 84.0;
    const posterH = 116.0;
    final radius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Pressable(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AnimeDetailScreen(itemId: item.id)),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: radius,
                child: item.imageBase64 != null
                    ? Image.memory(
                        base64Decode(item.imageBase64!),
                        width: posterW,
                        height: posterH,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : Container(
                        width: posterW,
                        height: posterH,
                        color: AppColors.surfaceHigh,
                        child: const Icon(Icons.movie_outlined,
                            color: AppColors.textFaint, size: 30),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w700)),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(item.description,
                            style: const TextStyle(
                                color: AppColors.textDim,
                                fontSize: 13,
                                height: 1.35),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      if (itemTags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: itemTags
                              .map((t) =>
                                  TagPill(name: t.name, color: Color(t.color)))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textFaint),
                padding: EdgeInsets.zero,
                onSelected: (v) async {
                  if (v == 'edit') {
                    openEditSheet(context, item, store);
                  } else if (v == 'delete') {
                    await store.deleteAnime(item.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                  PopupMenuItem(
                      value: 'delete',
                      child: Text('Удалить',
                          style: TextStyle(color: AppColors.danger))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
