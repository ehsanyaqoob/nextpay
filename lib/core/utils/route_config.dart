import 'package:flutter/material.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';

// Import all your screens here
import 'package:nextpay/features/screens/splash/splash_screen.dart';
import 'package:nextpay/features/boarding/on_boarding.dart';
import 'package:nextpay/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    // Auth Flow
    AppLinks.splashScreen: (context) => const SplashScreen(),
    AppLinks.onboardingScreen: (context) => const OnBoardingScreen(),
        AppLinks.home: (context) => const HomeScreen(),

    // AppLinks.loginScreen: (context) => const LoginScreen(),
    // AppLinks.signupScreen: (context) => const SignupScreen(),
    // AppLinks.forgotPasswordScreen: (context) => const ForgotPasswordScreen(),
    
    // Main App Flow
    // AppLinks.homeScreen: (context) => const HomeScreen(),
    // AppLinks.dashboardScreen: (context) => const DashboardScreen(),
    
    // Feature Screens
    // AppLinks.productsScreen: (context) => const ProductsScreen(),
    // AppLinks.categoriesScreen: (context) => const CategoriesScreen(),
    // AppLinks.searchScreen: (context) => const SearchScreen(),
    // AppLinks.profileScreen: (context) => const ProfileScreen(),
    // AppLinks.cartScreen: (context) => const CartScreen(),
  };
}

class AppLinks {
  // Auth & Onboarding
  static const splashScreen = '/';
  static const onboardingScreen = '/onboarding';
  static const loginScreen = '/login';
  static const signupScreen = '/signup';
  static const forgotPasswordScreen = '/forgot-password';
  
  // Main Tabs
  static const home = '/home';
  static const dashboardScreen = '/dashboard';
  
  // Features
  static const productsScreen = '/products';
  static const categoriesScreen = '/categories';
  static const searchScreen = '/search';
  static const profileScreen = '/profile';
  static const cartScreen = '/cart';
  
  // Details
  static const productDetailScreen = '/product-detail';
  static const transactionDetailScreen = '/transaction-detail';
  static const orderDetailScreen = '/order-detail';
  
  // Settings
  static const settingsScreen = '/settings';
  static const editProfileScreen = '/edit-profile';
  static const changePasswordScreen = '/change-password';
  
  // Payment
  static const paymentScreen = '/payment';
  static const checkoutScreen = '/checkout';
  static const orderConfirmationScreen = '/order-confirmation';
}

// Screen type classification for back press handling
class ScreenTypes {
  static const exitInstantly = [
    AppLinks.splashScreen,
    AppLinks.onboardingScreen,
  ];
  
  static const showExitConfirmation = [
    AppLinks.home,
    AppLinks.dashboardScreen,
  ];
  
  static const authScreens = [
    AppLinks.loginScreen,
    AppLinks.signupScreen,
    AppLinks.forgotPasswordScreen,
  ];
}

extension NavigationExtension on BuildContext {
  NavigationProvider get nav => Provider.of<NavigationProvider>(this, listen: false);
  
  // Quick access to common flows
  void goToSplash() => nav.goToSplash();
  void goToOnboarding() => nav.goToOnboarding();
  void goToLogin() => nav.goToLogin();
  void goToHome() => nav.goToHome();
  void goToDashboard() => nav.goToDashboard();
  void goToProducts() => nav.goToProducts();
  void goToProductDetail(dynamic productId) => nav.goToProductDetail(productId);
  void goToProfile() => nav.goToProfile();
  void goToCart() => nav.goToCart();
  void goToSettings() => nav.goToSettings();
  
  // Basic navigation
  Future<T?> to<T>({
    required String routeName,
    dynamic arguments,
    Transition transition = Transition.rightToLeft,
  }) => nav.to<T>(
    routeName: routeName,
    arguments: arguments,
    transition: transition,
  );
  
  Future<T?> off<T, TO>({
    required String routeName,
    dynamic arguments,
  }) => nav.off<T, TO>(
    routeName: routeName,
    arguments: arguments,
  );
  
  Future<T?> offAll<T>({
    required String routeName,
    dynamic arguments,
  }) => nav.offAll<T>(
    routeName: routeName,
    arguments: arguments,
  );
  
  void back<T>([T? result]) => nav.back<T>(result);
  
  // Current route info
  String? get currentRoute => nav.currentRoute;
  dynamic get currentArguments => nav.currentArguments;
  bool get canPop => nav.canPop;
}