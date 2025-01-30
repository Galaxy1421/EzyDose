import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import 'dart:convert';
import '../models/settings_model.dart';
import 'auth_service.dart';

class SettingsService extends GetxService {
  static SettingsService get to => Get.find();
  final _storage = GetStorage();
  final _logger = Logger();
  final _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final Rxn<SettingsModel> _settings = Rxn<SettingsModel>();
  final _key = 'settings';

  SettingsModel get settings => _settings.value ?? SettingsModel();

  String get wakeUpTime => settings.routineTimes['wake_up_time'] ?? '07:00';
  String get beforeBreakfastTime => settings.routineTimes['before_breakfast_time'] ?? '07:45';
  String get breakfastTime => settings.routineTimes['breakfast_time'] ?? '08:00';
  String get afterBreakfastTime => settings.routineTimes['after_breakfast_time'] ?? '08:15';
  String get beforeLunchTime => settings.routineTimes['before_lunch_time'] ?? '12:45';
  String get lunchTime => settings.routineTimes['lunch_time'] ?? '13:00';
  String get afterLunchTime => settings.routineTimes['after_lunch_time'] ?? '13:15';
  String get beforeDinnerTime => settings.routineTimes['before_dinner_time'] ?? '18:45';
  String get dinnerTime => settings.routineTimes['dinner_time'] ?? '19:00';
  String get afterDinnerTime => settings.routineTimes['after_dinner_time'] ?? '19:15';
  String get bedTime => settings.routineTimes['bed_time'] ?? '22:00';

  final routineTimes = {
    'wakeup': Rx<TimeOfDay?>(const TimeOfDay(hour: 7, minute: 0)),
    'breakfast': Rx<TimeOfDay?>(const TimeOfDay(hour: 8, minute: 0)),
    'lunch': Rx<TimeOfDay?>(const TimeOfDay(hour: 12, minute: 0)),
    'dinner': Rx<TimeOfDay?>(const TimeOfDay(hour: 18, minute: 0)),
    'bedtime': Rx<TimeOfDay?>(const TimeOfDay(hour: 22, minute: 0)),
  }.obs;

  static const String _breakfastTimeKey = 'breakfastTime';
  static const String _lunchTimeKey = 'lunchTime';
  static const String _dinnerTimeKey = 'dinnerTime';

  TimeOfDay getBreakfastTime() {
    final timeStr = _storage.read(_breakfastTimeKey) ?? '08:00';
    return _parseTimeString(timeStr);
  }

  TimeOfDay getLunchTime() {
    final timeStr = _storage.read(_lunchTimeKey) ?? '13:00';
    return _parseTimeString(timeStr);
  }

  TimeOfDay getDinnerTime() {
    final timeStr = _storage.read(_dinnerTimeKey) ?? '19:00';
    return _parseTimeString(timeStr);
  }

  Future<void> setBreakfastTime(TimeOfDay time) async {
    await _storage.write(_breakfastTimeKey, _formatTimeOfDay(time));
  }

  Future<void> setLunchTime(TimeOfDay time) async {
    await _storage.write(_lunchTimeKey, _formatTimeOfDay(time));
  }

  Future<void> setDinnerTime(TimeOfDay time) async {
    await _storage.write(_dinnerTimeKey, _formatTimeOfDay(time));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  int? getInt(String key) => _storage.read<int>(key);
  
  Future<void> setInt(String key, int value) async {
    await _storage.write(key, value);
  }

  @override
  void onInit() {
    super.onInit();
    loadRoutineTimes();
  }

  Future<void> init() async {
    await GetStorage.init();
    await loadRoutineTimes();
  }

  Future<void> _loadSettings() async {
    try {
      isLoading.value = true;
      final userId = _authService.getLocalUser()?.id;
      if (userId == null) {
        _logger.w('No user logged in, cannot load settings');
        return;
      }

      final data = await _storage.read('settings_$userId');
      if (data != null) {
        _settings.value = SettingsModel.fromJson(Map<String, dynamic>.from(data));
        _logger.i('Settings loaded successfully for user: $userId');
      } else {
        _settings.value = SettingsModel();
        await _saveSettings();
        _logger.i('Created default settings for user: $userId');
      }
    } catch (e) {
      _logger.e('Error loading settings', error: e, stackTrace: StackTrace.current);
      // Get.snackbar(
      //   'Error',
      //   'Failed to load settings',
      //   backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.error,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في تحميل الإعدادات"
              : "Failed to load settings"
      );

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveSettings() async {
    try {
      final userId = _authService.getLocalUser()?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await _storage.write('settings_$userId', settings.toJson());
      _logger.i('Settings saved successfully');
      // Get.snackbar(
      //   'Success',
      //   'Settings saved successfully',
      //   backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.primary,
      // );
      SnackbarService().showSuccess(
          AppHelper.isArabic
              ? "تم حفظ الإعدادات بنجاح"
              : "Settings saved successfully"
      );

    } catch (e) {
      _logger.e('Error saving settings', error: e, stackTrace: StackTrace.current);
      // Get.snackbar(
      //   'Error',
      //   'Failed to save settings',
      //   backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.error,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في حفظ الإعدادات"
              : "Failed to save settings"
      );

      rethrow;
    }
  }

  Future<void> updateDarkMode(bool value) async {
    _settings.value = settings.copyWith(darkMode: value);
    await _saveSettings();
  }

  Future<void> updateNotifications(bool value) async {
    _settings.value = settings.copyWith(notificationsEnabled: value);
    await _saveSettings();
  }

  Future<void> updateSound(bool value) async {
    _settings.value = settings.copyWith(soundEnabled: value);
    await _saveSettings();
  }

  Future<void> updateVibration(bool value) async {
    _settings.value = settings.copyWith(vibrationEnabled: value);
    await _saveSettings();
  }

  Future<void> updateLanguage(String value) async {
    _settings.value = settings.copyWith(language: value);
    await _saveSettings();
  }

  Future<void> updateWakeUpTime(String value) async {
    _settings.value = settings.copyWith(
      wakeUpTime: value,
      routineTimes: {...settings.routineTimes, 'wake_up_time': value},
    );
    await _saveSettings();
  }

  Future<void> updateBedTime(String value) async {
    _settings.value = settings.copyWith(
      bedTime: value,
      routineTimes: {...settings.routineTimes, 'bed_time': value},
    );
    await _saveSettings();
  }

  Future<void> updateBeforeMealMinutes(int value) async {
    _settings.value = settings.copyWith(beforeMealMinutes: value);
    await _saveSettings();
  }

  Future<void> updateAfterMealMinutes(int value) async {
    _settings.value = settings.copyWith(afterMealMinutes: value);
    await _saveSettings();
  }

  Future<void> updateAfterWakeUpMinutes(int value) async {
    _settings.value = settings.copyWith(afterWakeUpMinutes: value);
    await _saveSettings();
  }

  Future<void> updateBeforeBedMinutes(int value) async {
    _settings.value = settings.copyWith(beforeBedMinutes: value);
    await _saveSettings();
  }

  Future<void> updateRoutineTime(String key, String value) async {
    _settings.value = settings.copyWith(
      routineTimes: {...settings.routineTimes, key: value},
    );
    await _saveSettings();
  }

  Future<SettingsModel> getSettings() async {
    try {
      final box = GetStorage();
      final settingsJson = box.read<Map<String, dynamic>>('settings');
      if (settingsJson != null) {
        return SettingsModel.fromJson(settingsJson);
      }
      return SettingsModel(); // Return default settings if none exist
    } catch (e) {
      print('Error loading settings: $e');
      return SettingsModel(); // Return default settings on error
    }
  }

  Future<void> loadRoutineTimes() async {
    try {
      final times = _storage.read('routine_times');
      if (times != null) {
        final Map<String, dynamic> timesMap = jsonDecode(times);
        timesMap.forEach((key, value) {
          if (value != null) {
            final parts = value.split(':');
            routineTimes[key]?.value = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        });
      } else {
        await saveRoutineTimes(); // Save default times
      }
    } catch (e) {
      _logger.e('Error loading routine times', error: e);
    }
  }

  Future<void> saveRoutineTimes() async {
    try {
      final Map<String, String> times = {};
      routineTimes.forEach((key, value) {
        if (value.value != null) {
          times[key] = '${value.value!.hour}:${value.value!.minute.toString().padLeft(2, '0')}';
        }
      });
      await _storage.write('routine_times', jsonEncode(times));
    } catch (e) {
      _logger.e('Error saving routine times', error: e);
    }
  }

  // Future<void> updateRoutineTime(String routine, TimeOfDay time) async {
  //   if (routineTimes.containsKey(routine)) {
  //     routineTimes[routine]?.value = time;
  //     await saveRoutineTimes();
  //   }
  // }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? getRoutineTime(String routine) {
    return routineTimes[routine]?.value;
  }

  Future<SettingsModel> loadSettings() async {
    await init();
    return settings;
  }
}
