import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nextpay/core/utils/route_config.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/widget/common/dot-loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoFadeAnimation;
  bool _showLoader = false;
  bool _isInitialized = false;
  Timer? _loaderTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAppFlow();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> _startAppFlow() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _loaderTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoader = true;
        });
      }
    });

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3500)),
      _performInitialization(),
    ]);

    _loaderTimer?.cancel();
    _loaderTimer = null;

    // CORRECTED NAVIGATION - Using the extension method properly
    if (mounted) {
      // Use the navigation extension from context
      context.nav.goToOnboarding();
      debugPrint('Splash navigation completed - going to onboarding');
    }
  }

  Future<void> _performInitialization() async {
    try {
      // Add your actual initialization logic here
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Example initialization tasks:
      // 1. Check if user is logged in
      // 2. Load user preferences
      // 3. Initialize services
      // 4. Check for updates
      
      final isFirstLaunch = true; // Replace with your logic
      final isLoggedIn = false; // Replace with your logic
      
      debugPrint('Initialization completed - First launch: $isFirstLaunch, Logged in: $isLoggedIn');
      
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Even if initialization fails, navigate to onboarding
      if (mounted) {
        context.nav.goToOnboarding();
      }
    }
  }

  void _cancelTimers() {
    _loaderTimer?.cancel();
    _loaderTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Logo and Title
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: SvgPicture.asset(
                        Assets.nextpaylogo,
                        height: 150.0,
                        color: ThemeColors.buttonBackground(context),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: MyText(
                      text: "NextPay",
                      color: context.text,
                      size: 30,
                      weight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section with Loader and Footer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loader
                    AnimatedOpacity(
                      opacity: _showLoader ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NextPayLoader(size: 40.0, dotSize: 10.0),
                        ],
                      ),
                    ),
                    32.height,

                    // Footer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          MyText(
                            text: "By",
                            color: context.subtitle.withOpacity(0.5),
                            size: 16.0,
                            weight: FontWeight.w400,
                          ),
                          4.height,
                          MyText(
                            text: "nextpay.com",
                            color: context.buttonBackground,
                            size: 18.0,
                            weight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Theme Toggle (Debug only)
            if (kDebugMode)
              Positioned(
                top: 20,
                right: 20,
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => themeProvider.toggleTheme(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            context.isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: context.icon,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}