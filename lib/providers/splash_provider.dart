import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nextpay/export.dart';

class SplashProvider with ChangeNotifier {
  bool _showLoader = false;
  bool _isInitialized = false;
  Timer? _loaderTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoFadeAnimation;

  bool get showLoader => _showLoader;
  bool get isInitialized => _isInitialized;
  AnimationController get animationController => _animationController;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get logoFadeAnimation => _logoFadeAnimation;

  void initializeAnimations(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
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
}
