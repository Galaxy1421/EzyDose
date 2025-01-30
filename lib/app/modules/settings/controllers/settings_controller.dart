import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/settings_service.dart';
import '../../../data/models/settings_model.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = Get.find<SettingsService>();

  SettingsModel get settings => _settingsService.settings;

  bool get darkMode => settings.darkMode;
  bool get notificationsEnabled => settings.notificationsEnabled;
  bool get soundEnabled => settings.soundEnabled;
  bool get vibrationEnabled => settings.vibrationEnabled;
  String get language => settings.language;
  String get wakeUpTime => settings.wakeUpTime;
  String get bedTime => settings.bedTime;
  int get beforeMealMinutes => settings.beforeMealMinutes;
  int get afterMealMinutes => settings.afterMealMinutes;
  int get afterWakeUpMinutes => settings.afterWakeUpMinutes;
  int get beforeBedMinutes => settings.beforeBedMinutes;
  Map<String, String> get routineTimes => settings.routineTimes;

  Future<void> toggleDarkMode() async {
    await _settingsService.updateDarkMode(!darkMode);
    Get.changeThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleNotifications() async {
    await _settingsService.updateNotifications(!notificationsEnabled);
  }

  Future<void> toggleSound() async {
    await _settingsService.updateSound(!soundEnabled);
  }

  Future<void> toggleVibration() async {
    await _settingsService.updateVibration(!vibrationEnabled);
  }

  Future<void> updateLanguage(String value) async {
    await _settingsService.updateLanguage(value);
    // TODO: Implement language change
  }

  Future<void> updateWakeUpTime(TimeOfDay time) async {
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _settingsService.updateWakeUpTime(timeString);
  }

  Future<void> updateBedTime(TimeOfDay time) async {
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _settingsService.updateBedTime(timeString);
  }

  Future<void> updateBeforeMealMinutes(int value) async {
    await _settingsService.updateBeforeMealMinutes(value);
  }

  Future<void> updateAfterMealMinutes(int value) async {
    await _settingsService.updateAfterMealMinutes(value);
  }

  Future<void> updateAfterWakeUpMinutes(int value) async {
    await _settingsService.updateAfterWakeUpMinutes(value);
  }

  Future<void> updateBeforeBedMinutes(int value) async {
    await _settingsService.updateBeforeBedMinutes(value);
  }

  Future<void> updateRoutineTime(String key, TimeOfDay time) async {
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _settingsService.updateRoutineTime(key, timeString);
  }

  TimeOfDay getTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
