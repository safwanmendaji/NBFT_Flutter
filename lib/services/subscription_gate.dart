import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/models/subscription/subscription_model.dart';
 import 'package:flutter_nobrokeragefortenants/screens/user/subscription_screen.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/subscription_api.dart';

class SubscriptionGate {
  static bool get isUser {
    final role = Prefs.getString(LocalStrings.userrole).toLowerCase();
    return role == 'user' || role == 'tenant';
  }

  static Future<SubscriptionStatus?> refresh(BuildContext context) async {
    if (!isUser || Prefs.getString(LocalStrings.usertoken).isEmpty) return null;
    try {
      final status = await SubscriptionApi.getMySubscription(context: context);
      await Prefs.setBool('activeSubscription', status.isActive);
      await Prefs.setString(LocalStrings.subscriptionStart, status.startDate?.toIso8601String() ?? '');
      await Prefs.setString(LocalStrings.subscriptionEnd, status.endDate?.toIso8601String() ?? '');
      await Prefs.setString(LocalStrings.subscriptionPurpose, status.propertyPurpose);
      return status;
    } catch (_) {
      // Keep verified subscription data available when the API is temporarily unreachable.
      return null;
    }
  }

  static Future<bool> ensureActive(BuildContext context) async {
    if (!isUser) return true;
    try {
      final status = await refresh(context);
      if (status?.isActive == true) return true;
    } catch (_) {}
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        (_) => false,
      );
    }
    return false;
  }
}
