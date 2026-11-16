import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final double dy;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.dy = 0.08,
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  Timer? _t;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 45 * widget.index.clamp(0, 10).toInt());
    if (delay == Duration.zero) {
      _c.forward();
    } else {
      _t = Timer(delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _a,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, widget.dy), end: Offset.zero)
              .animate(_a),
          child: widget.child,
        ),
      );
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

class TagPill extends StatelessWidget {
  final String name;
  final Color color;
  final double fontSize;
  final EdgeInsets padding;

  const TagPill({
    super.key,
    required this.name,
    required this.color,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(name,
            style: TextStyle(
                color: color, fontSize: fontSize, fontWeight: FontWeight.w600)),
      );
}

class SelectableTagChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;

  const SelectableTagChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.18) : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? color : AppColors.outline, width: 1.2),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: selected ? color : AppColors.textDim,
              fontSize: fontSize,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ),
      );
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
            color: AppColors.textFaint,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700),
      );
}

class ColorPalettePicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onPick;
  final double size;
  final double spacing;

  const ColorPalettePicker({
    super.key,
    required this.selected,
    required this.onPick,
    this.size = 34,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: AppColors.tagPalette.map((c) {
          final sel = selected == c;
          final color = Color(c);
          return GestureDetector(
            onTap: () => onPick(c),
            child: AnimatedScale(
              scale: sel ? 1.12 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: sel ? AppColors.text : Colors.transparent,
                      width: 2),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: sel ? 1 : 0,
                  child: Icon(Icons.check_rounded,
                      color: AppColors.on(color), size: size * 0.5),
                ),
              ),
            ),
          );
        }).toList(),
      );
}

class SheetActions extends StatelessWidget {
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const SheetActions({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: OutlinedButton(onPressed: onCancel, child: Text(cancelLabel)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(onPressed: onConfirm, child: Text(confirmLabel)),
        ),
      ]);
}

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String text;
  const EmptyState({super.key, required this.icon, required this.text});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _c,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, -8 * Curves.easeInOut.transform(_c.value)),
                  child: child,
                ),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.accent.withOpacity(0.25)),
                  ),
                  child: Icon(widget.icon, color: AppColors.accent, size: 38),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textDim, fontSize: 15, height: 1.4)),
              ),
            ],
          ),
        ),
      );
}


class ActionToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const ActionToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.16) : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? c : AppColors.outline, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? c : AppColors.textDim),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? c : AppColors.textDim,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
