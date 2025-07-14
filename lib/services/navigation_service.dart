import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> navigateTo(Widget page) async {
    final navState = navigatorKey.currentState;
    if (navState != null) {
      await navState.push(
        MaterialPageRoute(builder: (_) => page),
      );
    } else {
      debugPrint("❌ NavigatorState is null!");
    }
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }
}

// ✅ Global singleton instance
final NavigationService navigationService = NavigationService();
