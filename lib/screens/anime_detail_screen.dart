import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/edit_sheet.dart';

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
      return const Scaffold(
          body: Center(child: Text('Not found')));
    }
    final itemTags =
        store.tags.where((t) => item.tagIds.contains(t.id)).toList();
    const imgHeight = 240.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: item.imageBase64 != null ? imgHeight : 56,
            pinned: true,
            backgroundColor: const Color(0xFF0D0D1A),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 12, right: 100),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                ),
              ),
              background: item.imageBase64 != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          base64Decode(item.imageBase64!),
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.5, 1.0],
                              colors: [
                                Colors.transparent,
                                Color(0xEE0D0D1A)
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  final s = store;
                  Navigator.pop(context);
                  openEditSheetWithStore(context, item, s);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: Text(s['delete_confirm_title'],
                          style: const TextStyle(color: Colors.white)),
                      content: Text(
                          '«${item.title}» ${s['delete_confirm_body']}',
                          style:
                              const TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(s['btn_cancel'])),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(s['btn_delete'],
                                style: const TextStyle(
                                    color: Colors.redAccent))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await store.deleteAnime(item.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (itemTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: itemTags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color(t.color).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          Color(t.color).withOpacity(0.4)),
                                ),
                                child: Text(t.name,
                                    style: TextStyle(
                                        color: Color(t.color),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (item.description.isNotEmpty) ...[
                    _label(s['detail_description']),
                    const SizedBox(height: 8),
                    Text(item.description,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.6)),
                    const SizedBox(height: 20),
                  ],
                  if (item.note.isNotEmpty) ...[
                    _label(s['detail_note']),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252540),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                const Color(0xFF7C3AED).withOpacity(0.2)),
                      ),
                      child: Text(item.note,
                          style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              height: 1.5)),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (item.buttons.isNotEmpty) ...[
                    _label(s['detail_links']),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: item.buttons.map((btn) {
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
                            backgroundColor:
                                Color(btn.color).withOpacity(0.85),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _label(s['detail_added']),
                  const SizedBox(height: 4),
                  Text(
                    '${item.createdAt.day.toString().padLeft(2, '0')}.${item.createdAt.month.toString().padLeft(2, '0')}.${item.createdAt.year}',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 13),
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

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600));
}