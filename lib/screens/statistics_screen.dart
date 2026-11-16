import 'package:flutter/material.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../models/anime_item.dart';
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

    final rated = store.anime.where((a) => a.rating != null).toList();
    final ratingCounts = List<int>.filled(10, 0);
    for (final a in rated) {
      ratingCounts[a.rating!.clamp(1, 10).toInt() - 1]++;
    }
    final avgRating = rated.isEmpty
        ? null
        : rated.fold<int>(0, (sum, a) => sum + a.rating!) / rated.length;
    final completed =
        store.anime.where((a) => a.status == WatchStatus.completed).length;
    final episodesSeen =
        store.anime.fold<int>(0, (sum, a) => sum + a.progress);

    final now = DateTime.now();
    final months =
        List.generate(12, (i) => DateTime(now.year, now.month - 11 + i));
    final monthCounts = {for (final m in months) m.year * 12 + m.month: 0};
    for (final a in store.anime) {
      final key = a.createdAt.year * 12 + a.createdAt.month;
      if (monthCounts.containsKey(key)) {
        monthCounts[key] = monthCounts[key]! + 1;
      }
    }

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
                      Icon(Icons.info_outline,
                          color: AppColors.textFaint, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${s['stats_anime']}: $untaggedAnime',
                          style: TextStyle(
                              color: AppColors.textDim, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            FadeSlideIn(
              index: 3,
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: s['stats_avg_rating'],
                      value: avgRating == null
                          ? '—'
                          : avgRating.toStringAsFixed(1),
                      icon: Icons.star_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      label: s['stats_completed'],
                      value: '$completed',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      label: s['stats_episodes'],
                      value: '$episodesSeen',
                      icon: Icons.play_circle_outline_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              index: 4,
              child: _ChartSection(
                title: s['stats_ratings'],
                emptyText: rated.isEmpty ? s['stats_no_ratings'] : null,
                color: AppColors.accent,
                bars: [
                  for (var i = 0; i < 10; i++)
                    _Bar(label: '${i + 1}', value: ratingCounts[i]),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              index: 5,
              child: _ChartSection(
                title: s['stats_by_month'],
                color: AppColors.info,
                bars: [
                  for (final m in months)
                    _Bar(
                      label: m.month.toString().padLeft(2, '0'),
                      sub: (m.month == 1 || m == months.first)
                          ? "’${(m.year % 100).toString().padLeft(2, '0')}"
                          : '',
                      value: monthCounts[m.year * 12 + m.month] ?? 0,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (sortedTags.isNotEmpty) ...[
              FadeSlideIn(
                index: 3,
                child: Text(
                  s['stats_by_tags'],
                  style: TextStyle(
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
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$count ${s['stats_anime']}',
                                    style: TextStyle(
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
              style: TextStyle(
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
            style: TextStyle(color: AppColors.textFaint, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textFaint, fontSize: 11.5),
            ),
          ],
        ),
      );
}

class _Bar {
  final String label;
  final String sub;
  final int value;
  const _Bar({required this.label, this.sub = '', required this.value});
}

class _ChartSection extends StatelessWidget {
  final String title;
  final List<_Bar> bars;
  final Color color;

  final String? emptyText;

  const _ChartSection({
    required this.title,
    required this.bars,
    required this.color,
    this.emptyText,
  });

  static const _chartHeight = 110.0;

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<int>(0, (m, b) => b.value > m ? b.value : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
          ),
          child: emptyText != null
              ? SizedBox(
                  height: _chartHeight,
                  child: Center(
                    child: Text(emptyText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textFaint, fontSize: 13)),
                  ),
                )
              : SizedBox(
                  height: _chartHeight + 52,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bars.map((b) {
                      final target = maxValue == 0 ? 0.0 : b.value / maxValue;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                b.value > 0 ? '${b.value}' : '',
                                style: TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: target),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) {
                                  final h = v * _chartHeight;
                                  return Container(
                                    height: h < 3 ? 3 : h,
                                    decoration: BoxDecoration(
                                      color: b.value > 0
                                          ? color
                                          : color.withOpacity(0.18),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(5)),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Text(b.label,
                                  style: TextStyle(
                                      color: AppColors.textFaint,
                                      fontSize: 10.5)),
                              SizedBox(
                                height: 12,
                                child: Text(b.sub,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: AppColors.textFaint,
                                        fontSize: 9.5)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
