import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferences? _prefs;
  static bool _initCalled = false;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _initCalled = true;
  }

  static void dispose() {
    _prefs = null;
  }

  static void _checkInit() {
    assert(_initCalled, "Prefs.init() must be called first!");
    assert(_prefs != null, "SharedPreferences not ready yet!");
  }

  static Set<String> getKeys() {
    _checkInit();
    return _prefs!.getKeys();
  }

  static Future<Set<String>> getKeysF() async =>
      (await _getInstance()).getKeys();

  static dynamic getDynamic(String key) {
    _checkInit();
    return _prefs!.get(key);
  }

  static Future<dynamic> getDynamicF(String key) async =>
      (await _getInstance()).get(key);

  static bool? getBool(String key, [bool? defValue]) {
    _checkInit();
    return _prefs!.getBool(key) ?? defValue;
  }

  static Future<bool?> getBoolF(String key, [bool? defValue]) async =>
      (await _getInstance()).getBool(key) ?? defValue;

  static int? getInt(String key, [int? defValue]) {
    _checkInit();
    return _prefs!.getInt(key) ?? defValue;
  }

  static Future<int?> getIntF(String key, [int? defValue]) async =>
      (await _getInstance()).getInt(key) ?? defValue;

  static double getDouble(String key, [double? defValue]) {
    _checkInit();
    return _prefs!.getDouble(key) ?? defValue ?? 0.0;
  }

  static Future<double> getDoubleF(String key, [double? defValue]) async =>
      (await _getInstance()).getDouble(key) ?? defValue ?? 0.0;

  static String getString(String key, [String? defValue]) {
    _checkInit();
    return _prefs!.getString(key) ?? defValue ?? "";
  }

  static Future<String> getStringF(String key, [String? defValue]) async =>
      (await _getInstance()).getString(key) ?? defValue ?? "";

  static List<String> getStringList(String key, [List<String>? defValue]) {
    _checkInit();
    return _prefs!.getStringList(key) ?? defValue ?? [""];
  }

  static Future<List<String>> getStringListF(String key,
          [List<String>? defValue]) async =>
      (await _getInstance()).getStringList(key) ?? defValue ?? [""];

  static Future<bool> setBool(String key, bool value) async =>
      (await _getInstance()).setBool(key, value);

  static Future<bool> setInt(String key, int value) async =>
      (await _getInstance()).setInt(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      (await _getInstance()).setDouble(key, value);

  static Future<bool> setString(String key, String value) async =>
      (await _getInstance()).setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      (await _getInstance()).setStringList(key, value);

  static Future<bool> remove(String key) async =>
      (await _getInstance()).remove(key);

  static Future<bool> clear() async => (await _getInstance()).clear();

  static Future<SharedPreferences> _getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
