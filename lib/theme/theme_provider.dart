import 'package:flutter/material.dart';
import 'package:nextpay/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _prefKey = 'theme';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _initialize();
  }

  void _initialize() {
    // Load saved preference first (synchronously check what was saved)
    _loadThemePreference();

    // Listen to system theme changes
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_themeMode == ThemeMode.system) {
        _updateSystemTheme();
        notifyListeners();
      }
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
    super.dispose();
  }

  void _updateSystemTheme() {
    final Brightness platformBrightness = 
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode = platformBrightness == Brightness.dark;
  }

  void _loadThemePreference() {
    try {
      SharedPreferences.getInstance().then((prefs) async {
        final String? savedTheme = prefs.getString(_prefKey);

        if (savedTheme != null) {
          switch (savedTheme) {
            case 'light':
              _themeMode = ThemeMode.light;
              _isDarkMode = false;
              break;
            case 'dark':
              _themeMode = ThemeMode.dark;
              _isDarkMode = true;
              break;
            case 'system':
            default:
              _themeMode = ThemeMode.system;
              _updateSystemTheme();
          }
        } else {
          _themeMode = ThemeMode.system;
          _updateSystemTheme();
          await prefs.setString(_prefKey, 'system');
        }
        
        _updateSystemUIOverlay();
        _isInitialized = true;
        notifyListeners();
      }).catchError((e) {
        print('Error loading theme: $e');
        _themeMode = ThemeMode.system;
        _updateSystemTheme();
        _updateSystemUIOverlay();
        _isInitialized = true;
        notifyListeners();
      });
    } catch (e) {
      print('Error loading theme: $e');
      _themeMode = ThemeMode.system;
      _updateSystemTheme();
      _updateSystemUIOverlay();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> switchTheme(ThemeMode mode) async {
    _themeMode = mode;

    // Update isDarkMode based on mode
    switch (mode) {
      case ThemeMode.system:
        _updateSystemTheme();
        break;
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
    }

    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = mode == ThemeMode.light 
          ? 'light' 
          : mode == ThemeMode.dark 
              ? 'dark' 
              : 'system';
      await prefs.setString(_prefKey, modeString);
    } catch (e) {
      print('Error saving theme: $e');
    }
    
    _updateSystemUIOverlay();
    notifyListeners();
  }

  void _updateSystemUIOverlay() {
    final isDarkMode = effectiveIsDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await switchTheme(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await switchTheme(ThemeMode.system);
    } else {
      // System mode - toggle to opposite
      _updateSystemTheme();
      await switchTheme(_isDarkMode ? ThemeMode.light : ThemeMode.dark);
    }
  }

  // Get the effective dark mode status
  bool get effectiveIsDarkMode {
    if (_themeMode == ThemeMode.system) {
      final currentBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return currentBrightness == Brightness.dark;
    }
    return _isDarkMode;
  }

  // Convenience methods
  Future<void> setLightTheme() async => await switchTheme(ThemeMode.light);
  Future<void> setDarkTheme() async => await switchTheme(ThemeMode.dark);
  Future<void> setSystemTheme() async => await switchTheme(ThemeMode.system);
}