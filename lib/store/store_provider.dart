import 'package:flutter/material.dart';
import 'store.dart';

extension StoreExt on BuildContext {
  Store get store => _InheritedStore.of(this, listen: true);
  Store get storeR => _InheritedStore.of(this, listen: false);
}

class StoreProvider extends StatefulWidget {
  final Widget child;
  const StoreProvider({super.key, required this.child});

  @override
  State<StoreProvider> createState() => _StoreProviderState();
}

class _StoreProviderState extends State<StoreProvider> {
  final _store = Store();

  @override
  void initState() {
    super.initState();
    _store.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _InheritedStore(store: _store, child: widget.child);
}

class _InheritedStore extends InheritedWidget {
  final Store store;
  const _InheritedStore({required this.store, required super.child});

  static Store of(BuildContext context, {required bool listen}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<_InheritedStore>()!
          .store;
    } else {
      return context.findAncestorWidgetOfExactType<_InheritedStore>()!.store;
    }
  }

  @override
  bool updateShouldNotify(_InheritedStore old) => true;
}