import 'package:flutter/material.dart';
import 'package:nextpay/widget/common/toasts.dart';

class AuthProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Forgot password state
  String? _forgotPasswordContact;
  String? _generatedOtp;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // ======================== FORGOT PASSWORD FLOW ========================

  /// Step 1: Send forgot password code (6-digit OTP)
  Future<bool> sendForgotPasswordCode({
    required String contact,
    required BuildContext context,
  }) async {
    if (contact.isEmpty) {
      AppToast.show('Email or phone is required', context);
      return false;
    }

    if (_isValidEmail(contact) == false && _isValidPhone(contact) == false) {
      AppToast.show('Please enter a valid email or phone number', context);
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Generate 6-digit OTP (123456 for easy testing)
      _generatedOtp = '123456';
      _forgotPasswordContact = contact;

      print('6-digit OTP $_generatedOtp sent to: $contact');
      print('For testing, use OTP: 123456');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppToast.show('Failed to send code', context);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Step 2: Verify 6-digit OTP
  Future<bool> verifyForgotPasswordOtp({
    required String otp,
    required BuildContext context,
  }) async {
    if (otp.isEmpty) {
      AppToast.show('OTP is required', context);
      return false;
    }

    if (otp.length != 6) {
      AppToast.show('OTP must be 6 digits', context);
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Verify OTP - accept 123456 for testing
      if (otp == _generatedOtp || otp == '123456') {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        AppToast.show('Invalid OTP. Please try again.', context);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppToast.show('OTP verification failed', context);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Step 3: Set new password after OTP verification
  Future<bool> setNewPassword({
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      AppToast.show('Passwords are required', context);
      return false;
    }

    if (newPassword.length < 6) {
      AppToast.show('Password must be at least 6 characters', context);
      return false;
    }

    if (newPassword != confirmPassword) {
      AppToast.show('Passwords do not match', context);
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Clear forgot password state
      _generatedOtp = null;
      _forgotPasswordContact = null;

      print('Password reset successful');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppToast.show('Password reset failed', context);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ======================== SIGN IN ========================
  Future<bool> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      AppToast.show('Email and password are required', context);
      return false;
    }

    if (!_isValidEmail(email)) {
      AppToast.show('Please enter a valid email', context);
      return false;
    }

    if (password.length < 6) {
      AppToast.show('Password must be at least 6 characters', context);
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call for 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      // Mock successful sign in
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      AppToast.show('Sign in failed', context);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ======================== SIGN UP ========================
  Future<bool> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      AppToast.show('All fields are required', context);
      return false;
    }

    if (!_isValidEmail(email)) {
      AppToast.show('Please enter a valid email', context);
      return false;
    }

    if (password.length < 6) {
      AppToast.show('Password must be at least 6 characters', context);
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call for 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful sign up
      _isAuthenticated = true;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      AppToast.show('Sign up failed', context);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ======================== SIGN OUT ========================
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _isAuthenticated = false;
      _error = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================== VALIDATION HELPERS ========================

  /// Email validation helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Phone validation helper (basic)
  bool _isValidPhone(String phone) {
    // Remove any non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Basic validation - at least 10 digits
    return digitsOnly.length >= 10;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset auth state completely
  void reset() {
    _isLoading = false;
    _error = null;
    _isAuthenticated = false;
    _forgotPasswordContact = null;
    _generatedOtp = null;
    notifyListeners();
  }
}
