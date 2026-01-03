import 'package:flutter/material.dart';

class RouteTracker extends NavigatorObserver {
  static final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(
    null,
  );

  void _set(Route? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      currentRoute.value = name;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _set(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _set(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _set(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
