import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nextpay/core/utils/app_routes.dart';
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
  bool _initDone = false;
  Timer? _loaderTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
   _startFlow();
  }

  void _setupAnimation() {
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

  Future<void> _startFlow() async {
    if (_initDone) return;
    _initDone = true;

    _loaderTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showLoader = true);
    });

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3500)),
    _initApp(),
    ]);

    _loaderTimer?.cancel();
    if (!mounted) return;
    
    // TODO: Navigation commented out for redesign
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppLinks.getstart, (_) => false);

    // final pref = await SharedPreferences.getInstance();
    // final seen = pref.getBool('onboardingSeen') ?? false;

    // if (seen) {
    //   Navigator.of(
    //     context,
    //   ).pushNamedAndRemoveUntil(AppLinks.home, (_) => false);
    // } else {
    //   Navigator.of(
    //     context,
    //   ).pushNamedAndRemoveUntil(AppLinks.onboarding, (_) => false);
    // }
  }

  Future<void> _initApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (_) {}
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
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
                        height: 150,
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

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      opacity: _showLoader ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: NextPayLoader(size: 40.0, dotSize: 12.0),
                    ),
                    32.height,
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          MyText(
                            text: "By",
                            color: context.subtitle.withOpacity(0.5),
                            size: 16,
                          ),
                          4.height,
                          MyText(
                            text: "nextpay.com",
                            color: context.buttonBackground,
                            size: 18,
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

            if (kDebugMode)
              Positioned(
                top: 20,
                right: 20,
                child: Consumer<ThemeProvider>(
                  builder: (_, theme, __) {
                    return InkWell(
                      onTap: theme.toggleTheme,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          context.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: context.icon,
                          size: 20,
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