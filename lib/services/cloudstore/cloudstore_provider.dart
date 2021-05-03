import 'package:flutter/material.dart';

import 'cloudstore_service.dart';

class CloudStoreProvider extends InheritedWidget {
  final CloudStoreService storage;

  CloudStoreProvider({
    Key key,
    Widget child,
    this.storage,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWiddget) {
    return true;
  }

  static CloudStoreProvider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<CloudStoreProvider>());
}
