import 'package:flutter/material.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;

    final tagStats = <String, int>{};
    for (final tag in store.tags) {
      final count = store.anime.where((a) => a.tagIds.contains(tag.id)).length;
      tagStats[tag.id] = count;
    }

    final totalAnime = store.anime.length;
    final totalTags = store.tags.length;
    final untaggedAnime = store.anime.where((a) => a.tagIds.isEmpty).length;
    final sortedTags = store.getSortedTags();

    return Scaffold(
      appBar: AppBar(title: Text(s['nav_statistics'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FadeSlideIn(
                    child: _OverviewCard(
                      title: s['stats_total'],
                      value: totalAnime,
                      icon: Icons.movie_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FadeSlideIn(
                    index: 1,
                    child: _OverviewCard(
                      title: s['stats_by_tags'],
                      value: totalTags,
                      icon: Icons.label_outlined,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            if (untaggedAnime > 0) ...[
              const SizedBox(height: 12),
              FadeSlideIn(
                index: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.textFaint, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${s['stats_anime']}: $untaggedAnime',
                          style: const TextStyle(
                              color: AppColors.textDim, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            if (sortedTags.isNotEmpty) ...[
              FadeSlideIn(
                index: 3,
                child: Text(
                  s['stats_by_tags'],
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...sortedTags.asMap().entries.map((e) {
                final tag = e.value;
                final count = tagStats[tag.id] ?? 0;
                final percentage = totalAnime > 0 ? (count / totalAnime) : 0.0;
                final tagColor = Color(tag.color);

                return FadeSlideIn(
                  key: ValueKey(tag.id),
                  index: 4 + e.key,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tagColor.withOpacity(0.22)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  tag.name.isNotEmpty
                                      ? tag.name[0].toUpperCase()
                                      : '',
                                  style: TextStyle(
                                    color: tagColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tag.name,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$count ${s['stats_anime']}',
                                    style: const TextStyle(
                                      color: AppColors.textFaint,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: percentage * 100),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Text(
                                '${v.round()}%',
                                style: TextStyle(
                                  color: tagColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: percentage),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => LinearProgressIndicator(
                              value: v,
                              backgroundColor: AppColors.surfaceHigh,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(tagColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              v.round().toString(),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 32,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
