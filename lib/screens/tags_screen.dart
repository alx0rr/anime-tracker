import 'package:flutter/material.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../sheets/tag_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;
    final sorted = store.getSortedTags();

    return Scaffold(
      appBar: AppBar(title: Text(s['nav_tags'])),
      body: store.tags.isEmpty
          ? EmptyState(icon: Icons.style_outlined, text: s['tags_empty'])
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: sorted.length,
              onReorder: (oldIndex, newIndex) =>
                  store.reorderTags(oldIndex, newIndex),
              proxyDecorator: (child, index, animation) => AnimatedBuilder(
                animation: animation,
                builder: (_, c) {
                  final t = Curves.easeOut.transform(animation.value);
                  return Transform.scale(
                    scale: 1 + 0.03 * t,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10 * t,
                      shadowColor: Colors.black,
                      borderRadius: BorderRadius.circular(18),
                      child: c,
                    ),
                  );
                },
                child: child,
              ),
              itemBuilder: (ctx, i) {
                final tag = sorted[i];
                final color = Color(tag.color);
                return FadeSlideIn(
                  key: Key(tag.id),
                  index: i,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withOpacity(0.22)),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 14, right: 4),
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              tag.name.isNotEmpty
                                  ? tag.name[0].toUpperCase()
                                  : '',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                      title: Text(tag.name,
                          style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600)),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: AppColors.textFaint),
                        onSelected: (v) async {
                          if (v == 'edit') {
                            openTagSheet(context, tag);
                          } else if (v == 'delete') {
                            await store.deleteTag(tag.id);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              value: 'edit', child: Text(s['btn_save'])),
                          PopupMenuItem(
                              value: 'delete',
                              child: Text(s['btn_delete'],
                                  style: TextStyle(
                                      color: AppColors.danger))),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openTagSheet(context, null),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
