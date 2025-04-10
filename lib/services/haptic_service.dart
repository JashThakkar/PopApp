import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static const String _hapticEnabledKey = 'haptic_enabled';
  static final HapticService _instance = HapticService._internal();
  SharedPreferences? _prefs;
  bool _isHapticEnabled = true;

  factory HapticService() {
    return _instance;
  }

  HapticService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isHapticEnabled = _prefs?.getBool(_hapticEnabledKey) ?? true;
  }

  bool get isHapticEnabled => _isHapticEnabled;

  Future<void> setHapticEnabled(bool enabled) async {
    _isHapticEnabled = enabled;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_hapticEnabledKey, enabled);
  }
} 