import 'package:flutter/material.dart';
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
    // Set initial system theme immediately
    _updateSystemTheme();
    
    // Load saved preference
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

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
            _themeMode = ThemeMode.system;
            _updateSystemTheme();
            break;
          default:
            _themeMode = ThemeMode.system;
            _updateSystemTheme();
        }
      } else {
        // First time - use system default
        _themeMode = ThemeMode.system;
        _updateSystemTheme();
        await prefs.setString(_prefKey, 'system');
      }
    } catch (e) {
      print('Error loading theme: $e');
      _themeMode = ThemeMode.system;
      _updateSystemTheme();
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> switchTheme(ThemeMode mode) async {
    _themeMode = mode;

    // Update isDarkMode based on mode
    if (mode == ThemeMode.system) {
      _updateSystemTheme();
    } else if (mode == ThemeMode.light) {
      _isDarkMode = false;
    } else if (mode == ThemeMode.dark) {
      _isDarkMode = true;
    }

    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.light:
          await prefs.setString(_prefKey, 'light');
          break;
        case ThemeMode.dark:
          await prefs.setString(_prefKey, 'dark');
          break;
        case ThemeMode.system:
          await prefs.setString(_prefKey, 'system');
          break;
      }
    } catch (e) {
      print('Error saving theme: $e');
    }
    
    notifyListeners();
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
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
          Brightness.dark;
    }
    return _isDarkMode;
  }

  // Convenience methods
  Future<void> setLightTheme() async => await switchTheme(ThemeMode.light);
  Future<void> setDarkTheme() async => await switchTheme(ThemeMode.dark);
  Future<void> setSystemTheme() async => await switchTheme(ThemeMode.system);
}