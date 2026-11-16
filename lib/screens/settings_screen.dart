import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/accent_picker.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l10n = context.l10n;
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s['settings_title'])),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(s['settings_language']),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: store.locale,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: AppColors.surfaceHigh,
                      iconEnabledColor: AppColors.textDim,
                      style: TextStyle(color: AppColors.text),
                      items: L10n.supported.map((loc) {
                        final label = s['settings_lang_$loc'];
                        final sel = store.locale == loc;
                        return DropdownMenuItem<String>(
                          value: loc,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: sel ? AppColors.accent : AppColors.textDim,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (loc) async {
                        if (loc != null) {
                          await store.saveLocale(loc);
                          await l10n.setLocale(loc);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(s['settings_theme']),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textDim,
                      selectedBackgroundColor:
                          AppColors.accent.withOpacity(0.16),
                      selectedForegroundColor: AppColors.accent,
                      side: BorderSide(color: AppColors.outline),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    segments: [
                      ButtonSegment(
                        value: 'dark',
                        icon: const Icon(Icons.dark_mode_outlined, size: 18),
                        label: Text(s['theme_dark']),
                      ),
                      ButtonSegment(
                        value: 'light',
                        icon: const Icon(Icons.light_mode_outlined, size: 18),
                        label: Text(s['theme_light']),
                      ),
                    ],
                    selected: {store.themeMode == 'light' ? 'light' : 'dark'},
                    onSelectionChanged: (v) => store.setThemeMode(v.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(s['settings_accent']),
                const SizedBox(height: 12),
                AccentPicker(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeSlideIn(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(s['settings_about']),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.logoGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text('A',
                                  style: TextStyle(
                                      color: AppColors.onAccent,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['settings_made_by'],
                                  style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Anime Tracker',
                                  style: TextStyle(
                                      color: AppColors.textFaint,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 14),
                      _LinkTile(
                        icon: Icons.code,
                        urlKey: 'settings_github',
                      ),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: Icons.language_rounded,
                        url: 'https://alx0rr.github.io/',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            index: 4,
            child: Center(
              child: Text(
                'v2.3.0',
                style: TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String? url;
  final String? urlKey;
  _LinkTile({required this.icon, this.url, this.urlKey});

  @override
  Widget build(BuildContext context) {
    final link = url ?? context.s[urlKey!];
    final shown = link.replaceFirst(RegExp(r'^https?://'), '');
    return Pressable(
      onTap: () {
        final uri = Uri.tryParse(link);
        if (uri != null) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                shown,
                style: TextStyle(color: AppColors.accent, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.open_in_new, color: AppColors.textFaint, size: 14),
          ],
        ),
      ),
    );
  }
}
