import 'package:flutter/material.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/tag_sheet.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: Text(s['nav_tags'],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: store.tags.isEmpty
          ? Center(
              child: Text(s['tags_empty'],
                  style: const TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.tags.length,
              itemBuilder: (ctx, i) {
                final tag = store.tags[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Color(tag.color).withOpacity(0.2),
                      child: Text(
                        tag.name[0].toUpperCase(),
                        style: TextStyle(
                            color: Color(tag.color),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(tag.name,
                        style: const TextStyle(color: Colors.white)),
                    trailing: PopupMenuButton<String>(
                      color: const Color(0xFF1A1A2E),
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white38),
                      onSelected: (v) async {
                        if (v == 'edit') {
                          openTagSheet(context, tag);
                        } else if (v == 'delete') {
                          await store.deleteTag(tag.id);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'edit',
                            child: Text(s['btn_save'],
                                style: const TextStyle(
                                    color: Colors.white70))),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text(s['btn_delete'],
                                style: const TextStyle(
                                    color: Colors.redAccent))),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openTagSheet(context, null),
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}