 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';

class UserPropertyStorage {
  static const wishlistKey = 'user_wishlist_ids';
  static const interestedKey = 'user_interested_ids';

  static Set<String> ids(String key) =>
      Prefs.getStringList(key).where((id) => id.isNotEmpty).toSet();

  static Future<void> toggle(String key, String id) async {
    final values = ids(key);
    if (!values.add(id)) values.remove(id);
    await Prefs.setStringList(key, values.toList());
  }
}
