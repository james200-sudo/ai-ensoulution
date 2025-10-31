import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  bool _biometricAvailable = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get biometricAvailable => _biometricAvailable;

  static const String _settingsKey = 'app_settings';

  SettingsProvider() {
    _loadSettings();
    _checkBiometricAvailability();
  }

  Future<void> _loadSettings() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(settingsMap);
      } else {
        // First time user, detect device language
        final deviceLanguage = await _getDeviceLanguage();
        _settings = AppSettings(language: deviceLanguage);
        await _saveSettings();
      }
    } catch (e) {
      //debugPrint('Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String> _getDeviceLanguage() async {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final languageCode = locale.languageCode;
      
      // Check if we support the device language
      if (languageCode == 'fr' || languageCode == 'es') {
        return languageCode;
      }
      
      // Default to English
      return 'en';
    } catch (e) {
      //debugPrint('Error getting device language: $e');
      return 'en'; // Fallback to English
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      //debugPrint('Error saving settings: $e');
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      _biometricAvailable = isAvailable && 
                           isDeviceSupported && 
                           availableBiometrics.isNotEmpty;
      notifyListeners();
    } catch (e) {
      //debugPrint('Error checking biometric availability: $e');
      _biometricAvailable = false;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> updatePushNotifications(bool value) async {
    _settings = _settings.copyWith(pushNotifications: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateMessageSounds(bool value) async {
    _settings = _settings.copyWith(messageSounds: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateAutoSaveConversations(bool value) async {
    _settings = _settings.copyWith(autoSaveConversations: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateLanguage(String value) async {
    _settings = _settings.copyWith(language: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateFontSize(double value) async {
    _settings = _settings.copyWith(fontSize: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateBiometricAuth(bool value) async {
    _settings = _settings.copyWith(biometricAuth: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateCompanyCode(String? value) async {
    _settings = _settings.copyWith(companyCode: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> resetSettings() async {
    _settings = const AppSettings();
    notifyListeners();
    await _saveSettings();
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _settings = const AppSettings();
      notifyListeners();
    } catch (e) {
      //debugPrint('Error clearing data: $e');
    }
  }
}