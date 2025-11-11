import 'package:flutter/material.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/features/auth/screens/details_form_screen.dart';
import 'package:nextpay/features/auth/screens/forgot_pass_screen.dart';
import 'package:nextpay/features/auth/screens/get_start_screen.dart';
import 'package:nextpay/features/auth/screens/signIn_screen.dart';
import 'package:nextpay/features/auth/screens/sign_up_screen.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:nextpay/features/screens/splash/splash_screen.dart';
import 'package:nextpay/features/boarding/on_boarding.dart';

class AppLinks {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const getstart = '/getstart';
  static const signin = '/signin';
  static const signup = '/signup';
  static const detailsform = '/detailsform';
  static const forgot = '/forgot';
  static const home = '/home';

}

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppLinks.splash:
        return _buildRoute(const SplashScreen(), RouteTransition.fade);
      case AppLinks.getstart:
        return _buildRoute(const GetStartScreen(), RouteTransition.rightToLeft);
      case AppLinks.signin:
        return _buildRoute(const SigninScreen(), RouteTransition.rightToLeft);
      case AppLinks.signup:
        return _buildRoute(const SignUpScreen(), RouteTransition.leftToRight);
        case AppLinks.detailsform:
        return _buildRoute(const DetailsFormScreen(), RouteTransition.rightToLeft);
      case AppLinks.forgot:
        return _buildRoute(
          const ForgotPasswordScreen(),
          RouteTransition.rightToLeft,
        );
        
      case AppLinks.onboarding:
        return _buildRoute(const OnBoardingScreen());

      case AppLinks.home:
        return _buildRoute(const HomeScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }

  static PageRouteBuilder<T> _buildRoute<T>(
    Widget page, [
    RouteTransition transition = RouteTransition.rightToLeft,
  ]) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        switch (transition) {
          case RouteTransition.fade:
            return FadeTransition(opacity: animation, child: child);
          case RouteTransition.rightToLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.leftToRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.bottomToTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.topToBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.none:
            return child;
        }
      },
    );
  }
}
