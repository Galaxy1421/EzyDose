class SettingsModel {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String language;
  final String wakeUpTime;
  final String bedTime;
  final int beforeMealMinutes;
  final int afterMealMinutes;
  final int afterWakeUpMinutes;
  final int beforeBedMinutes;
  final Map<String, String> routineTimes;

  SettingsModel({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'en',
    this.wakeUpTime = '07:00',
    this.bedTime = '22:00',
    this.beforeMealMinutes = 30,
    this.afterMealMinutes = 30,
    this.afterWakeUpMinutes = 30,
    this.beforeBedMinutes = 30,
    Map<String, String>? routineTimes,
  }) : routineTimes = routineTimes ?? {
          'breakfast_time': '08:00',
          'lunch_time': '13:00',
          'dinner_time': '19:00',
          'wake_up_time': '07:00',
          'bed_time': '22:00',
        };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      darkMode: json['darkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
      wakeUpTime: json['wakeUpTime'] as String? ?? '07:00',
      bedTime: json['bedTime'] as String? ?? '22:00',
      beforeMealMinutes: json['beforeMealMinutes'] as int? ?? 30,
      afterMealMinutes: json['afterMealMinutes'] as int? ?? 30,
      afterWakeUpMinutes: json['afterWakeUpMinutes'] as int? ?? 30,
      beforeBedMinutes: json['beforeBedMinutes'] as int? ?? 30,
      routineTimes: Map<String, String>.from(json['routineTimes'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'language': language,
      'wakeUpTime': wakeUpTime,
      'bedTime': bedTime,
      'beforeMealMinutes': beforeMealMinutes,
      'afterMealMinutes': afterMealMinutes,
      'afterWakeUpMinutes': afterWakeUpMinutes,
      'beforeBedMinutes': beforeBedMinutes,
      'routineTimes': routineTimes,
    };
  }

  SettingsModel copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? language,
    String? wakeUpTime,
    String? bedTime,
    int? beforeMealMinutes,
    int? afterMealMinutes,
    int? afterWakeUpMinutes,
    int? beforeBedMinutes,
    Map<String, String>? routineTimes,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      bedTime: bedTime ?? this.bedTime,
      beforeMealMinutes: beforeMealMinutes ?? this.beforeMealMinutes,
      afterMealMinutes: afterMealMinutes ?? this.afterMealMinutes,
      afterWakeUpMinutes: afterWakeUpMinutes ?? this.afterWakeUpMinutes,
      beforeBedMinutes: beforeBedMinutes ?? this.beforeBedMinutes,
      routineTimes: routineTimes ?? Map<String, String>.from(this.routineTimes),
    );
  }
}
