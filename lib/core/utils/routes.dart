// import 'package:flutter/material.dart';
// import 'package:nextpay/features/boarding/on_boarding.dart';
// import 'package:nextpay/features/screens/splash/splash_screen.dart';

// class AppLinks {
//   static const splash = '/splash';
//   static const onboarding = '/onboarding';
//   static const initial = '/initial';
//   static const home = '/home';
// }

// enum TransitionType {
//   fade,
//   slideLeft,
//   slideRight,
//   slideUp,
//   slideDown,
//   scale,
//   rotate,
// }

// class RouteConfig {
//   final String name;
//   final Widget Function(Object? args) page;
//   final TransitionType transition;
//   final Duration duration;
//   final bool isRoot;
//   const RouteConfig({
//     required this.name,
//     required this.page,
//     this.transition = TransitionType.fade,
//     this.duration = const Duration(milliseconds: 300),
//     this.isRoot = false,
//   });
// }

// class AppLogger {
//   static void log(String type, String message) {
//     final time = DateTime.now().toIso8601String();
//     debugPrint("[$time] $type: $message");
//   }

//   static void appStarts() => log("APP STARTS", "Application Launched");
//   static void goingToScreen(String toRoute, String fromRoute) => log("GOING TO SCREEN", "$toRoute from: $fromRoute");
//   static void comingFrom(String fromRoute, String toRoute) => log("COMING FROM", "$fromRoute back to: $toRoute");
//   static void routeOpened(String route) => log("ROUTE OPENED", route);
//   static void routePopped(String fromRoute, String toRoute) => log("ROUTE POPPED", "$fromRoute back to: $toRoute");
//   static void appExiting(String fromRoute) => log("APP EXITING", fromRoute);
//   static void backPress(String route, String action) => log("BACK PRESS", "$route action: $action");

//   static void _printRouteStack(List<String> history) {
//     debugPrint("ROUTE STACK [Depth: ${history.length}]: ${history.join(' → ')}");
//   }
// }

// class AppRoutes {
//   static final List<String> _routeHistory = [];
  
//   static final Map<String, RouteConfig> routes = {
//     AppLinks.splash: RouteConfig(
//       name: AppLinks.splash,
//       page: (_) => const SplashScreen(),
//       isRoot: true,
//       transition: TransitionType.fade,
//       duration: const Duration(milliseconds: 500),
//     ), 
//     AppLinks.onboarding: RouteConfig(
//       name: AppLinks.onboarding,
//       page: (_) => const OnBoardingScreen(),
//       isRoot: true,
//       transition: TransitionType.slideRight,
//       duration: const Duration(milliseconds: 400),
//     ),
//   };

//   static String? get currentRoute => _routeHistory.isNotEmpty ? _routeHistory.last : null;
  
//   static String? get previousRoute => _routeHistory.length > 1 ? _routeHistory[_routeHistory.length - 2] : null;
  
//   static int get stackDepth => _routeHistory.length;

//   static void _addToHistory(String route) {
//     final fromRoute = currentRoute;
//     _routeHistory.add(route);
    
//     if (fromRoute != null) {
//       AppLogger.goingToScreen(route, fromRoute);
//     } else {
//       AppLogger.routeOpened(route);
//     }
    
//     AppLogger._printRouteStack(_routeHistory);
//   }

//   static void _removeFromHistory() {
//     if (_routeHistory.isNotEmpty) {
//       final poppedRoute = _routeHistory.removeLast();
//       final current = currentRoute;
      
//       if (current != null) {
//         AppLogger.comingFrom(poppedRoute, current);
//       }
      
//       AppLogger._printRouteStack(_routeHistory);
//     }
//   }

//   static bool get isCurrentRouteRoot {
//     final current = currentRoute;
//     if (current == null) return false;
//     return routes[current]?.isRoot == true;
//   }

//   static Route<dynamic> generate(RouteSettings settings) {
//     final routeName = settings.name;

//     if (routeName == null || routeName.isEmpty || routeName == '/') {
//       AppLogger.routeOpened('ROUTE_SKIPPED: $routeName');
//       final splashConfig = routes[AppLinks.splash];
//       return MaterialPageRoute(
//         builder: (_) => splashConfig!.page(settings.arguments),
//       );
//     }
    
//     final config = routes[routeName];
    
//     if (config == null) {
//       AppLogger.routeOpened('ROUTE_NOT_FOUND: $routeName');
//       return MaterialPageRoute(
//         builder: (_) => const Scaffold(
//           body: Center(
//             child: Text("Route not found"),
//           ),
//         ),
//       );
//     }

//     if (_routeHistory.isEmpty || _routeHistory.last != routeName) {
//         _addToHistory(routeName);
//     }

//     return PageRouteBuilder(
//       settings: settings,
//       transitionDuration: config.duration,
//       pageBuilder: (_, animation, secondaryAnimation) => config.page(settings.arguments),
//       transitionsBuilder: (_, anim, __, child) {
//         switch (config.transition) {
//           case TransitionType.fade:
//             return FadeTransition(opacity: anim, child: child);
//           case TransitionType.slideLeft:
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(1, 0),
//                 end: Offset.zero,
//               ).animate(anim),
//               child: child,
//             );
//           case TransitionType.slideRight:
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(-1, 0),
//                 end: Offset.zero,
//               ).animate(anim),
//               child: child,
//             );
//           case TransitionType.slideUp:
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(0, 1),
//                 end: Offset.zero,
//               ).animate(anim),
//               child: child,
//             );
//           case TransitionType.slideDown:
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(0, -1),
//                 end: Offset.zero,
//               ).animate(anim),
//               child: child,
//             );
//           case TransitionType.scale:
//             return ScaleTransition(scale: anim, child: child);
//           case TransitionType.rotate:
//             return RotationTransition(turns: anim, child: child);
//         }
//       },
//     );
//   }
// }

// class Navigate {
//   static final navigatorKey = GlobalKey<NavigatorState>();
//   static BuildContext? get context => navigatorKey.currentContext;

//   static Future<T?> to<T>(String route, {Object? arguments}) {
//     final fromRoute = AppRoutes.currentRoute ?? 'none';
//     AppLogger.goingToScreen(route, fromRoute);
    
//     final navigator = navigatorKey.currentState;
//     return navigator?.pushNamed(route, arguments: arguments) ?? Future.value(null);
//   }

//   static Future<T?> off<T>(String route, {Object? arguments}) {
//     final fromRoute = AppRoutes.currentRoute ?? 'none';
//     AppLogger.comingFrom(fromRoute, route);
    
//     if (AppRoutes._routeHistory.isNotEmpty) {
//       AppRoutes._routeHistory.removeLast();
//     }

//     final navigator = navigatorKey.currentState;
//     return navigator?.pushReplacementNamed(route, arguments: arguments) ?? Future.value(null);
//   }

//   static Future<T?> offAll<T>(String route, {Object? arguments}) {
//     final fromRoute = AppRoutes.currentRoute ?? 'none';
//     AppLogger.comingFrom(fromRoute, route);
    
//     AppRoutes._routeHistory.clear();
    
//     final navigator = navigatorKey.currentState;
//     return navigator?.pushNamedAndRemoveUntil(
//       route, 
//       (_) => false, 
//       arguments: arguments
//     ) ?? Future.value(null);
//   }

//   static void back<T>([T? result]) {
//     if (navigatorKey.currentState?.canPop() ?? false) {
//       AppRoutes._removeFromHistory();
//       navigatorKey.currentState?.pop(result);
//     } else {
//       AppLogger.backPress(AppRoutes.currentRoute ?? 'unknown', 'CANNOT_POP');
//     }
//   }

//   static void startApp() {
//     AppLogger.appStarts();
//     offAll(AppLinks.splash);
//   }
// }