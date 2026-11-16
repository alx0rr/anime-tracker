import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/anime_item.dart';
import '../theme/app_theme.dart';
import 'common.dart';

Color statusColor(WatchStatus st) {
  switch (st) {
    case WatchStatus.planned:
      return AppColors.info;
    case WatchStatus.watching:
      return AppColors.accent;
    case WatchStatus.completed:
      return AppColors.success;
    case WatchStatus.dropped:
      return AppColors.danger;
  }
}

String statusLabel(AppStrings s, WatchStatus st) => s['status_${st.name}'];

String progressText(AnimeItem item) {
  if (item.totalEpisodes > 0) {
    if (item.progress == 0) return '';
    return '${item.progress} / ${item.totalEpisodes}';
  }
  return item.progress > 0 ? '${item.progress}' : '';
}

class RatingBadge extends StatelessWidget {
  final int rating;
  final double fontSize;
  final Color? color;
  const RatingBadge(
      {super.key, required this.rating, this.fontSize = 12.5, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: fontSize + 2, color: c),
        const SizedBox(width: 2),
        Text('$rating',
            style: TextStyle(
                color: c, fontSize: fontSize, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class StatusPicker extends StatelessWidget {
  final WatchStatus value;
  final ValueChanged<WatchStatus> onChanged;
  const StatusPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WatchStatus.values
          .map((st) => SelectableTagChip(
                label: statusLabel(s, st),
                color: statusColor(st),
                selected: value == st,
                onTap: () => onChanged(st),
              ))
          .toList(),
    );
  }
}

class RatingPicker extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const RatingPicker({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      const gap = 6.0;
      final size =
          ((box.maxWidth - gap * 9) / 10).clamp(24.0, 40.0).toDouble();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(10, (i) {
          final n = i + 1;
          final sel = value == n;
          return GestureDetector(
            onTap: () => onChanged(sel ? null : n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.accent : AppColors.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(
                    color: sel ? AppColors.accent : AppColors.outline),
              ),
              child: Text(
                '$n',
                style: TextStyle(
                  color: sel ? AppColors.onAccent : AppColors.textDim,
                  fontSize: size < 30 ? 12 : 14,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
