import 'package:flutter/material.dart';
import 'package:nextpay/core/navigation/route_transition.dart';

class NavigationProvider extends ChangeNotifier {
  NavigationProvider({int tabCount = 4})
      : _navigatorKeys = List.generate(tabCount, (_) => GlobalKey<NavigatorState>());

  final List<GlobalKey<NavigatorState>> _navigatorKeys;

  int _currentIndex = 0;
  DateTime? _lastBackTime;

  int get currentIndex => _currentIndex;
  List<GlobalKey<NavigatorState>> get navigatorKeys => _navigatorKeys;
  GlobalKey<NavigatorState> get currentNavigatorKey => _navigatorKeys[_currentIndex];
  NavigatorState? get currentNavigator => currentNavigatorKey.currentState;

  void selectTab(int index) {
    if (index == _currentIndex) {
      popToRootOf(index);
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

  void popToRootOf(int index) {
    final navigator = _navigatorKeys[index].currentState;
    navigator?.popUntil((route) => route.isFirst);
  }

  bool canPopCurrentTab() => currentNavigator?.canPop() ?? false;

  bool popCurrentTab() {
    if (canPopCurrentTab()) {
      currentNavigator!.pop();
      return true;
    }
    return false;
  }

  Future<bool> handleSystemBack() async {
    if (popCurrentTab()) return false;

    if (_currentIndex != 0) {
      _currentIndex = 0;
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final within = _lastBackTime != null &&
        now.difference(_lastBackTime!) < const Duration(seconds: 2);
    
    if (!within) {
      _lastBackTime = now;
      return false;
    }
    return true;
  }

  Route<T> buildPageRoute<T>({
    required Widget page,
    RouteTransition transition = RouteTransition.rightToLeft, // Default set to rightToLeft
    Duration duration = const Duration(milliseconds: 300),
    Object? arguments,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(arguments: arguments),
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (_, animation, __, child) {
        switch (transition) {
          case RouteTransition.fade:
            return FadeTransition(opacity: animation, child: child);
          case RouteTransition.rightToLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          case RouteTransition.leftToRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          case RouteTransition.bottomToTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          case RouteTransition.topToBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          case RouteTransition.none:
            return child;
        }
      },
    );
  }
}