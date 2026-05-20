import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../sheets/edit_sheet.dart';
import '../screens/anime_detail_screen.dart';

class AnimeCard extends StatelessWidget {
  final AnimeItem item;
  const AnimeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final itemTags =
        store.tags.where((t) => item.tagIds.contains(t.id)).toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AnimeDetailScreen(itemId: item.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            if (item.imageBase64 != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
                child: Image.memory(
                  base64Decode(item.imageBase64!),
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 80,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF252540),
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(16)),
                ),
                child: const Icon(Icons.image_outlined,
                    color: Colors.white12, size: 32),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.description,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                    if (itemTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: itemTags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        Color(t.color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Color(t.color)
                                            .withOpacity(0.4)),
                                  ),
                                  child: Text(t.name,
                                      style: TextStyle(
                                          color: Color(t.color),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              color: const Color(0xFF1A1A2E),
              icon: const Icon(Icons.more_vert, color: Colors.white38),
              onSelected: (v) async {
                if (v == 'edit') {
                  openEditSheet(context, item, store);
                } else if (v == 'delete') {
                  await store.deleteAnime(item.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'edit',
                    child: Text('Редактировать',
                        style: TextStyle(color: Colors.white70))),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить',
                        style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}