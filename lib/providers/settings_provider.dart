import 'package:flutter/material.dart';
import '../data/models/notification_settings.dart';
import '../data/repositories/contest_repository.dart';

/// State management for notification settings.
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  NotificationSettings _settings = NotificationSettings();
  Map<String, String> _handles = {};
  bool _isLoading = false;

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  NotificationSettings get settings => _settings;
  Map<String, String> get handles => _handles;
  bool get isLoading => _isLoading;
  bool get isOnboarded => _handles.isNotEmpty;

  /// Load all settings from storage.
  Future<void> loadSettings() async {
    _isLoading = true;
    // Don't notify yet — widget tree might still be building.

    _settings = await _repository.loadSettings();
    _handles = await _repository.loadHandles();

    _isLoading = false;
    notifyListeners();
  }

  /// Save notification settings.
  Future<void> saveSettings(NotificationSettings settings) async {
    _settings = settings;
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  /// Update a single setting.
  Future<void> updateSetting(void Function(NotificationSettings) updater) async {
    updater(_settings);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  /// Save user handles.
  Future<void> saveHandles(Map<String, String> handles) async {
    _handles = handles;
    await _repository.saveHandles(handles);
    await _repository.setOnboardingComplete();
    notifyListeners();
  }

  /// Check if onboarding is complete.
  Future<bool> isOnboardingComplete() async {
    return _repository.isOnboardingComplete();
  }
}
