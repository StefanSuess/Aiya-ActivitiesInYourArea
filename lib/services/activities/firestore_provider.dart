import 'package:flutter/material.dart';

import 'firestore_service.dart';

class FirestoreProvider extends InheritedWidget {
  final FirestoreService instance;

  FirestoreProvider({
    Key key,
    Widget child,
    this.instance,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWiddget) {
    return true;
  }

  static FirestoreProvider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<FirestoreProvider>());
}
