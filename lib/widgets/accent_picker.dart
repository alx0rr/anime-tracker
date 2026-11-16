import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../store/store_provider.dart';
import '../theme/app_theme.dart';

const _presets = <int>[
  0xFFD9822B,
  0xFFC9604A,
  0xFFB8434F,
  0xFFD17A8A,
  0xFFA66A8F,
  0xFF8672B5,
  0xFF6F86B8,
  0xFF5F9AA8,
  0xFF4FA38F,
  0xFF86A55B,
];

class AccentPicker extends StatelessWidget {
  const AccentPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.s;
    final current = store.accentColor;
    final isCustom = current != null && !_presets.contains(current);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Swatch(
          color: AppColors.defaultAccent,
          selected: current == null,
          tooltip: s['accent_default'],
          onTap: () => store.setAccentColor(null),
        ),
        for (final c in _presets)
          _Swatch(
            color: Color(c),
            selected: current == c,
            onTap: () => store.setAccentColor(c),
          ),
        _Swatch(
          color: isCustom ? Color(current!) : null,
          selected: isCustom,
          tooltip: s['accent_custom'],
          onTap: () async {
            final picked = await showAccentDialog(
                context, Color(current ?? AppColors.accent.value));
            if (picked != null) store.setAccentColor(picked.value);
          },
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color? color;
  final bool selected;
  final String? tooltip;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final fill = color;
    final child = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: fill,
          gradient: fill == null
              ? const SweepGradient(colors: [
                  Color(0xFFE53935),
                  Color(0xFFFDD835),
                  Color(0xFF43A047),
                  Color(0xFF1E88E5),
                  Color(0xFF8E24AA),
                  Color(0xFFE53935),
                ])
              : null,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.text : AppColors.outline,
            width: selected ? 2.5 : 1.2,
          ),
        ),
        child: Icon(
          selected
              ? Icons.check_rounded
              : (fill == null ? Icons.palette_outlined : null),
          size: 20,
          color: fill == null ? Colors.white : AppColors.on(fill),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

Future<Color?> showAccentDialog(BuildContext context, Color initial) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _AccentDialog(initial: initial),
  );
}

class _AccentDialog extends StatefulWidget {
  final Color initial;
  const _AccentDialog({required this.initial});

  @override
  State<_AccentDialog> createState() => _AccentDialogState();
}

class _AccentDialogState extends State<_AccentDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial);

  String get _hex =>
      '#${_hsv.toColor().value.toRadixString(16).substring(2).toUpperCase()}';

  Widget _slider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
    List<Color>? gradient,
  }) {
    final color = _hsv.toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textDim, fontSize: 12.5)),
        SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (gradient != null)
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  activeTrackColor:
                      gradient != null ? Colors.transparent : color,
                  inactiveTrackColor: gradient != null
                      ? Colors.transparent
                      : AppColors.surfaceHigh,
                  thumbColor: color,
                  overlayColor: color.withOpacity(0.15),
                ),
                child: Slider(value: value, min: 0, max: max, onChanged: onChanged),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final color = _hsv.toColor();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outline),
      ),
      title: Text(s['accent_custom'],
          style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outline),
                  ),
                ),
                const SizedBox(width: 14),
                Text(_hex,
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            _slider(
              label: s['accent_hue'],
              value: _hsv.hue,
              max: 360,
              gradient: [
                for (var h = 0; h <= 360; h += 60)
                  HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
              ],
              onChanged: (v) => setState(() => _hsv = _hsv.withHue(v)),
            ),
            _slider(
              label: s['accent_saturation'],
              value: _hsv.saturation,
              max: 1,
              gradient: [
                HSVColor.fromAHSV(1, _hsv.hue, 0, _hsv.value).toColor(),
                HSVColor.fromAHSV(1, _hsv.hue, 1, _hsv.value).toColor(),
              ],
              onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
            ),
            _slider(
              label: s['accent_brightness'],
              value: _hsv.value,
              max: 1,
              gradient: [
                HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 0).toColor(),
                HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 1).toColor(),
              ],
              onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s['btn_cancel'],
              style: TextStyle(color: AppColors.textDim)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, color),
          child: Text(s['btn_save']),
        ),
      ],
    );
  }
}
