import 'package:flutter/foundation.dart';

class AppBarProvider with ChangeNotifier {
  int _notificationCount = 0;
  String? _userAvatarUrl;
  int _cartItemCount = 0;
  int _messageCount = 0;

  int get notificationCount => _notificationCount;
  String? get userAvatarUrl => _userAvatarUrl;
  int get cartItemCount => _cartItemCount;
  int get messageCount => _messageCount;

  void setNotificationCount(int count) {
    _notificationCount = count;
    notifyListeners();
  }

  void setUserAvatar(String? url) {
    _userAvatarUrl = url;
    notifyListeners();
  }

  void setCartItemCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }

  void setMessageCount(int count) {
    _messageCount = count;
    notifyListeners();
  }

  void incrementNotification() {
    _notificationCount++;
    notifyListeners();
  }

  void incrementCart() {
    _cartItemCount++;
    notifyListeners();
  }

  void incrementMessage() {
    _messageCount++;
    notifyListeners();
  }

  void clearAllCounts() {
    _notificationCount = 0;
    _cartItemCount = 0;
    _messageCount = 0;
    notifyListeners();
  }
}