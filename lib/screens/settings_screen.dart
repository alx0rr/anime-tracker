import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../store/store_provider.dart';
import '../l10n/strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l10n = context.l10n;
    final s = context.s;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: Text(s['settings_title'],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          _SectionLabel(s['settings_language']),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: store.locale,
                dropdownColor: const Color(0xFF1A1A2E),
                iconEnabledColor: Colors.white54,
                style: const TextStyle(color: Colors.white),
                items: L10n.supported.map((loc) {

                  final key = 'settings_lang_$loc';
                  final label = s[key];
                  return DropdownMenuItem<String>(
                    value: loc,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: store.locale == loc
                            ? const Color(0xFF7C3AED)
                            : Colors.white54,
                        fontWeight: store.locale == loc
                            ? FontWeight.w600
                            : FontWeight.normal,
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


          const SizedBox(height: 32),


          _SectionLabel(s['settings_about']),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('A',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['settings_made_by'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Anime Tracker',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () {
                    final uri = Uri.tryParse(s['settings_github']);
                    if (uri != null) {
                      launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252540),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code,
                            color: Color(0xFF7C3AED), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s['settings_github'],
                            style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.open_in_new,
                            color: Colors.white24, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600),
      );
}