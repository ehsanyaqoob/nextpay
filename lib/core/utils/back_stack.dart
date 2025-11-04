// core/utils/back_press_handler.dart
import 'package:flutter/material.dart';
import 'package:nextpay/core/utils/route_config.dart';
import 'package:nextpay/providers/navigation_provider.dart';
import 'package:nextpay/widget/common/toasts.dart';
import 'package:provider/provider.dart';

class BackPressHandler {
  static DateTime? _lastBackPressTime;
  
  static Future<bool> handleBackPress(BuildContext context) async {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final currentRoute = navProvider.currentRoute;
    
    print("📌 --BACK PRESS-- Current: $currentRoute, CanPop: ${navProvider.canPop}");
    
    // Always try normal back navigation first
    if (navProvider.canPop) {
      print("📌 Normal back navigation - popping stack");
      navProvider.back();
      return false;
    }
    
    // Handle different root screen types
    if (ScreenTypes.exitInstantly.contains(currentRoute)) {
      print("📌 Exit instantly from: $currentRoute");
      return true; // Exit app instantly
    }
    
    if (ScreenTypes.showExitConfirmation.contains(currentRoute)) {
      print("📌 Show exit confirmation from: $currentRoute");
      return _handleExitConfirmation(context);
    }
    
    if (ScreenTypes.authScreens.contains(currentRoute)) {
      print("📌 Auth screen at root - exit: $currentRoute");
      return true; // Exit app
    }
    
    // Default case - exit app
    print("📌 Default exit from: $currentRoute");
    return true;
  }
  
  static Future<bool> _handleExitConfirmation(BuildContext context) async {
    final now = DateTime.now();
    final isWarningShown = _lastBackPressTime != null && 
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2);
    
    if (!isWarningShown) {
      _lastBackPressTime = now;
      AppToast.show('Press back again to exit the app', context);
      return false;
    }
    
    print("📌 APP EXITING ");
    return true;
  }
}
