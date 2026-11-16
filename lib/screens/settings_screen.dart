import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
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
                      style: const TextStyle(color: AppColors.text),
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
                              gradient: const LinearGradient(
                                colors: AppColors.logoGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
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
                                  style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                const Text(
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
                      Pressable(
                        onTap: () {
                          final uri = Uri.tryParse(s['settings_github']);
                          if (uri != null) {
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.code,
                                  color: AppColors.accent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  s['settings_github'],
                                  style: const TextStyle(
                                      color: AppColors.accent, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.open_in_new,
                                  color: AppColors.textFaint, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FadeSlideIn(
            index: 2,
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
