import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class AppStrings {
  final Map<String, String> _data;
  const AppStrings._(this._data);

  String operator [](String key) => _data[key] ?? key;

  static Future<AppStrings> load(String locale) async {
    final raw = await rootBundle.loadString('assets/l10n/$locale.yaml');
    final yaml = loadYaml(raw) as YamlMap;
    final map = <String, String>{};
    for (final entry in yaml.entries) {
      map[entry.key.toString()] = entry.value.toString();
    }
    return AppStrings._(map);
  }
}


class L10n extends ChangeNotifier {
  static const _supportedLocales = [
    'en',
    'ru',
    'ua',
    'de',
    'fr',
    'es',
    'ja',
    'zh',
    'pt',
    'ko',
    'it',
    'nl'
  ];
  static const _defaultLocale = 'en';

  String _locale = _defaultLocale;
  AppStrings _strings = AppStrings._({});

  String get locale => _locale;
  AppStrings get s => _strings;

  Future<void> init(String locale) async {
    _locale = _supportedLocales.contains(locale) ? locale : _defaultLocale;
    _strings = await AppStrings.load(_locale);
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    await init(locale);
  }

  static List<String> get supported => _supportedLocales;
}

extension L10nExt on BuildContext {
  AppStrings get s => _InheritedL10n.of(this).s;
  L10n get l10n => _InheritedL10n.of(this);
}

class L10nProvider extends StatefulWidget {
  final Widget child;
  final String initialLocale;
  const L10nProvider(
      {super.key, required this.child, this.initialLocale = 'ru'});

  @override
  State<L10nProvider> createState() => _L10nProviderState();
}

class _L10nProviderState extends State<L10nProvider> {
  final _l10n = L10n();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _l10n.addListener(() => setState(() {}));
    _l10n.init(widget.initialLocale).then((_) => setState(() => _ready = true));
  }

  @override
  void dispose() {
    _l10n.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0D0D1A),
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
        ),
      );
    }
    return _InheritedL10n(l10n: _l10n, child: widget.child);
  }
}

class _InheritedL10n extends InheritedWidget {
  final L10n l10n;
  const _InheritedL10n({required this.l10n, required super.child});

  static L10n of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedL10n>()!.l10n;

  @override
  bool updateShouldNotify(_InheritedL10n old) => true;
}