import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/anime_item.dart';
import '../store/store_provider.dart';
import '../screens/anime_detail_screen.dart';
import '../sheets/anime_actions_sheet.dart';
import '../theme/app_theme.dart';
import '../utils/delete_undo.dart';
import 'anime_meta.dart';
import 'common.dart';

void _openDetail(BuildContext context, AnimeItem item) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnimeDetailScreen(itemId: item.id)),
    );

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
    final progress = progressText(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('dismiss_${item.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => deleteWithUndo(context, item),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 26),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.danger.withOpacity(0.4)),
          ),
          child: Icon(Icons.delete_outline_rounded,
              color: AppColors.danger, size: 28),
        ),
        child: Pressable(
          onTap: () => _openDetail(context, item),
          onLongPress: () => showAnimeActions(context, item),
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
                          cacheWidth: 252,
                          gaplessPlayback: true,
                        )
                      : Container(
                          width: posterW,
                          height: posterH,
                          color: AppColors.surfaceHigh,
                          child: Icon(Icons.movie_outlined,
                              color: AppColors.textFaint, size: 30),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 0, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.pinned)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 5, top: 1),
                                child: Icon(Icons.push_pin,
                                    size: 14, color: AppColors.accent),
                              ),
                            Expanded(
                              child: Text(item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      height: 1.2,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        if (item.status != WatchStatus.planned ||
                            progress.isNotEmpty ||
                            item.rating != null) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (item.status != WatchStatus.planned)
                                StatusPill(status: item.status),
                              if (progress.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow_rounded,
                                        size: 15, color: AppColors.textDim),
                                    Text(progress,
                                        style: TextStyle(
                                            color: AppColors.textDim,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              if (item.rating != null)
                                RatingBadge(rating: item.rating!),
                            ],
                          ),
                        ],
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(item.description,
                              style: TextStyle(
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
                                .map((t) => TagPill(
                                    name: t.name, color: Color(t.color)))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    _SmallIconButton(
                      icon: Icons.more_vert,
                      color: AppColors.textFaint,
                      onTap: () => showAnimeActions(context, item),
                    ),
                    _SmallIconButton(
                      icon: item.favorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: item.favorite
                          ? AppColors.accent
                          : AppColors.textFaint,
                      onTap: () => store.toggleFavorite(item.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallIconButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, color: color),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        onPressed: onTap,
      );
}

class StatusPill extends StatelessWidget {
  final WatchStatus status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) => TagPill(
        name: statusLabel(context.s, status),
        color: statusColor(status),
      );
}

class AnimeGridCard extends StatelessWidget {
  final AnimeItem item;
  const AnimeGridCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final progress = progressText(item);
    final hasBar = item.totalEpisodes > 0 && item.progress > 0;

    return Pressable(
      onTap: () => _openDetail(context, item),
      onLongPress: () => showAnimeActions(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageBase64 != null)
              Image.memory(
                base64Decode(item.imageBase64!),
                fit: BoxFit.cover,
                cacheWidth: 400,
                gaplessPlayback: true,
              )
            else
              Center(
                child: Icon(Icons.movie_outlined,
                    color: AppColors.textFaint, size: 38),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                  colors: [Colors.transparent, Color(0xDD000000)],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: hasBar ? 11 : 9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.rating != null || progress.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.rating != null)
                          RatingBadge(
                              rating: item.rating!,
                              fontSize: 12,
                              color: const Color(0xFFFFC970)),
                        if (item.rating != null && progress.isNotEmpty)
                          const SizedBox(width: 8),
                        if (progress.isNotEmpty)
                          Text(progress,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasBar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: (item.progress / item.totalEpisodes)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  minHeight: 3,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      statusColor(item.status)),
                ),
              ),
            if (item.pinned)
              const Positioned(
                top: 8,
                left: 8,
                child: _PosterChip(icon: Icons.push_pin, color: Colors.white),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => store.toggleFavorite(item.id),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _PosterChip(
                    icon: item.favorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: item.favorite
                        ? const Color(0xFFFFC970)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            if (item.status != WatchStatus.planned)
              Positioned(
                top: 8,
                left: item.pinned ? 40 : 8,
                child: Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: statusColor(item.status),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosterChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _PosterChip({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      );
}
