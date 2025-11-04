// providers/navigation_provider.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nextpay/core/utils/route_config.dart';
import 'package:nextpay/features/screens/splash/splash_screen.dart';

class NavigationProvider extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<RouteHistory> _routeHistory = [];

  List<RouteHistory> get routeHistory => List.unmodifiable(_routeHistory);
  String? get currentRoute =>
      _routeHistory.isNotEmpty ? _routeHistory.last.routeName : null;
  dynamic get currentArguments =>
      _routeHistory.isNotEmpty ? _routeHistory.last.arguments : null;
  bool get canPop => navigatorKey.currentState?.canPop() ?? false;

  // ============ NAVIGATION METHODS ============

  // Basic navigation
  Future<T?> to<T>({
    required String routeName,
    dynamic arguments,
    Transition transition = Transition.rightToLeft,
    Duration? duration,
    bool fullscreenDialog = false,
  }) {
    _logNavigation(
      action: 'NAVIGATE.TO',
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );

    _routeHistory.add(
      RouteHistory(
        routeName: routeName,
        arguments: arguments,
        timestamp: DateTime.now(),
      ),
    );

    return navigatorKey.currentState!.push<T>(
      _buildPageRoute(
        routeName: routeName,
        arguments: arguments,
        transition: transition,
        duration: duration,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  // Replace current screen
  Future<T?> off<T, TO>({
    required String routeName,
    dynamic arguments,
    Transition transition = Transition.rightToLeft,
    Duration? duration,
  }) {
    _logNavigation(
      action: 'NAVIGATE.REPLACEMENT',
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );

    if (_routeHistory.isNotEmpty) {
      _routeHistory.removeLast();
    }

    _routeHistory.add(
      RouteHistory(
        routeName: routeName,
        arguments: arguments,
        timestamp: DateTime.now(),
      ),
    );

    return navigatorKey.currentState!.pushReplacement<T, TO>(
      _buildPageRoute(
        routeName: routeName,
        arguments: arguments,
        transition: transition,
        duration: duration,
      ),
    );
  }

  // Clear all and go to new screen
  Future<T?> offAll<T>({
    required String routeName,
    dynamic arguments,
    Transition transition = Transition.rightToLeft,
    Duration? duration,
  }) {
    _logNavigation(
      action: 'NAVIGATE.OFF_ALL',
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );

    _routeHistory.clear();
    _routeHistory.add(
      RouteHistory(
        routeName: routeName,
        arguments: arguments,
        timestamp: DateTime.now(),
      ),
    );

    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      _buildPageRoute(
        routeName: routeName,
        arguments: arguments,
        transition: transition,
        duration: duration,
      ),
      (route) => false,
    );
  }

  // Go back
  void back<T>([T? result]) {
    if (_routeHistory.isNotEmpty) {
      final removedRoute = _routeHistory.removeLast();
      _logNavigation(
        action: 'NAVIGATE.BACK',
        routeName: removedRoute.routeName,
        arguments: removedRoute.arguments,
      );
    } else {
      _logNavigation(
        action: 'NAVIGATE.BACK',
        routeName: 'NO_HISTORY',
        arguments: null,
      );
    }

    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  // ============ APP-SPECIFIC NAVIGATION FLOWS ============

  // App Launch Flow
  void goToSplash() {
    offAll<void>(routeName: AppLinks.splashScreen);
  }

  void goToOnboarding() {
    off<void, void>(routeName: AppLinks.onboardingScreen);
  }

  void goToLogin() {
    off<void, void>(routeName: AppLinks.loginScreen);
  }

  void goToHome() {
    offAll<void>(routeName: AppLinks.home);
  }

  void goToDashboard() {
    offAll<void>(routeName: AppLinks.dashboardScreen);
  }

  // Auth Flow
  void goToSignup() {
    to<void>(routeName: AppLinks.signupScreen);
  }

  void goToForgotPassword() {
    to<void>(routeName: AppLinks.forgotPasswordScreen);
  }

  // Feature Navigation
  void goToProducts() {
    to<void>(routeName: AppLinks.productsScreen);
  }

  void goToProductDetail(dynamic productId) {
    to<void>(
      routeName: AppLinks.productDetailScreen,
      arguments: {'productId': productId},
    );
  }

  void goToProfile() {
    to<void>(routeName: AppLinks.profileScreen);
  }

  void goToEditProfile() {
    to<void>(routeName: AppLinks.editProfileScreen);
  }

  void goToSettings() {
    to<void>(routeName: AppLinks.settingsScreen);
  }

  void goToCart() {
    to<void>(routeName: AppLinks.cartScreen);
  }

  void goToCheckout() {
    to<void>(routeName: AppLinks.checkoutScreen);
  }

  void goToPayment() {
    to<void>(routeName: AppLinks.paymentScreen);
  }

  void goToOrderConfirmation() {
    to<void>(routeName: AppLinks.orderConfirmationScreen);
  }

  // ============ PRIVATE METHODS ============

  void _logNavigation({
    required String action,
    required String routeName,
    dynamic arguments,
    Transition? transition,
    Duration? duration,
  }) {
    debugPrint('=' * 50);
    debugPrint('NAVIGATION: $action');
    debugPrint('Route: $routeName');
    debugPrint('Arguments: $arguments');
    debugPrint('Transition: ${transition?.name ?? "default"}');
    debugPrint('Stack: ${_routeHistory.map((r) => r.routeName).toList()}');
    debugPrint('=' * 50);
  }

  PageRoute<T> _buildPageRoute<T>({
    required String routeName,
    required dynamic arguments,
    required Transition transition,
    Duration? duration,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName, arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) {
        final widgetBuilder = AppRoutes.routes[routeName];
        if (widgetBuilder == null) {
          // Fallback to splash if route not found
          return const SplashScreen();
        }
        return widgetBuilder(context);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          animation: animation,
          child: child,
          transition: transition,
        );
      },
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 300),
      fullscreenDialog: fullscreenDialog,
    );
  }

  Widget _buildTransition<T>({
    required Animation<double> animation,
    required Widget child,
    required Transition transition,
  }) {
    switch (transition) {
      case Transition.fade:
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      case Transition.rightToLeft:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      case Transition.leftToRight:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      case Transition.none:
        return child;
      default:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
    }
  }

  @override
  void dispose() {
    _routeHistory.clear();
    super.dispose();
  }
}

// Supporting classes
class RouteHistory {
  final String routeName;
  final dynamic arguments;
  final DateTime timestamp;

  RouteHistory({
    required this.routeName,
    required this.arguments,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'RouteHistory{routeName: $routeName, arguments: $arguments}';
  }
}

enum Transition {
  fade,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  cupertino,
  none,
}
