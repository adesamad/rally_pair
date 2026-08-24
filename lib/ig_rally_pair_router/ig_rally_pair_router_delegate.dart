import 'package:flutter/material.dart';

class IgRallyPairRouter {
  IgRallyPairRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> push<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return pushRoute<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  static Future<T?> pushRoute<T extends Object?>(Route<T> route) {
    final state = navigator;
    return state == null ? Future<T?>.value() : state.push<T>(route);
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
    RouteSettings? settings,
  }) {
    final state = navigator;
    if (state == null) return Future<T?>.value();
    return state.pushReplacement<T, TO>(
      MaterialPageRoute<T>(builder: (_) => page, settings: settings),
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    Widget page,
    RoutePredicate predicate,
  ) {
    final state = navigator;
    if (state == null) return Future<T?>.value();
    return state.pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(builder: (_) => page),
      predicate,
    );
  }

  static void pop<T extends Object?>([T? result]) => navigator?.pop<T>(result);

  static Future<bool> maybePop<T extends Object?>([T? result]) {
    return navigator?.maybePop<T>(result) ?? Future<bool>.value(false);
  }

  static bool canPop() => navigator?.canPop() ?? false;
  static void popUntil(RoutePredicate predicate) =>
      navigator?.popUntil(predicate);
  static void popToFirst() => popUntil((route) => route.isFirst);
}
