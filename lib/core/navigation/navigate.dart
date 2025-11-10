import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextpay/core/navigation/navigation_provider.dart';
import 'package:nextpay/core/navigation/route_transition.dart';

class Navigate {
  static NavigationProvider _provider(BuildContext context) =>
      Provider.of<NavigationProvider>(context, listen: false);

  /// Navigate to a new screen using named routes (recommended for auth screens)
  static Future<T?> toNamed<T>({
    required BuildContext context,
    required String routeName,
    Object? arguments,
  }) {
    return Navigator.of(context, rootNavigator: true).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a new screen with custom transition
  static Future<T?> to<T>({
    required BuildContext context,
    required Widget page,
    RouteTransition transition = RouteTransition.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
    Object? arguments,
  }) {
    final provider = _provider(context);
    final navigator = provider.currentNavigator ?? 
        Navigator.of(context, rootNavigator: true);
    
    final route = provider.buildPageRoute<T>(
      page: page,
      transition: transition,
      duration: duration,
      arguments: arguments,
    );
    return navigator.push<T>(route);
  }

  /// Replace current screen
  static Future<T?> replace<T>({
    required BuildContext context,
    required Widget page,
    RouteTransition transition = RouteTransition.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
    Object? arguments,
  }) {
    final provider = _provider(context);
    final navigator = provider.currentNavigator ?? 
        Navigator.of(context, rootNavigator: true);
    
    final route = provider.buildPageRoute<T>(
      page: page,
      transition: transition,
      duration: duration,
      arguments: arguments,
    );
    return navigator.pushReplacement(route);
  }

  /// Go back
  static void back<T>({
    required BuildContext context,
    T? result,
  }) {
    Navigator.of(context, rootNavigator: false).pop<T>(result);
  }

  /// Go back to root
  static void popUntilRoot(BuildContext context) {
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  }

  /// Close multiple screens and go back
  static void backMultiple({
    required BuildContext context,
    int count = 2,
  }) {
    final navigator = Navigator.of(context, rootNavigator: false);
    for (int i = 0; i < count; i++) {
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }
}