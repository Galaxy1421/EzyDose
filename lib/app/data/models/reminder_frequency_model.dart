import 'package:get/get.dart';
import 'package:reminder/app/data/models/time_unit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderFrequency {
  daily,
  custom;

  String get label => name.tr;
}

class ReminderFrequencyModel {
   ReminderFrequency type;
  Set<DateTime> customDays;
   int repeatEvery;
   int repeatEveryNumber;
   TimeUnit repeatEveryUnit;

  ReminderFrequencyModel({
    required this.type,
    required this.repeatEveryNumber,
    required this.customDays,
    required this.repeatEvery,
    required this.repeatEveryUnit
  });

  factory ReminderFrequencyModel.fromJson(Map<String, dynamic> json) {
    try {
      final typeStr = json['type'] as String? ?? 'daily';
      final customDaysJson = json['customDays'] as List? ?? [];
      final repeatEveryUnitStr = json['repeatEveryUnit'] as String? ?? 'day';

      // Convert customDays from either Timestamp or String to DateTime
      Set<DateTime> parsedCustomDays = {};
      for (var day in customDaysJson) {
        if (day is Timestamp) {
          parsedCustomDays.add(day.toDate());
        } else if (day is String) {
          parsedCustomDays.add(DateTime.parse(day));
        } else {
          print('Warning: Invalid date format in customDays: $day');
        }
      }

      return ReminderFrequencyModel(
        type: ReminderFrequency.values.byName(typeStr),
        customDays: parsedCustomDays,
        repeatEvery: (json['repeatEvery'] as num?)?.toInt() ?? 1,
        repeatEveryNumber: (json['repeatEveryNumber'] as num?)?.toInt() ?? 1,
        repeatEveryUnit: TimeUnit.values.byName(repeatEveryUnitStr),
      );
    } catch (e) {
      print('Error parsing ReminderFrequencyModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'type': type.name,
        'customDays': customDays.map((date) => date.toIso8601String()).toList(),
        'repeatEvery': repeatEvery,
        'repeatEveryNumber': repeatEveryNumber,
        'repeatEveryUnit': repeatEveryUnit.name,
      };
    } catch (e) {
      print('Error converting ReminderFrequencyModel to JSON: $e');
      rethrow;
    }
  }

  Set<DateTime> generateDays() {
    Set<DateTime> dates = {};

    if (repeatEvery == 0) {
      return dates;
    }

    // Get today's date
    DateTime today = DateTime.now();
    int startDay = today.day;
    int startMonth = today.month;
    int startYear = today.year;

    if (repeatEveryUnit == TimeUnit.day) {
      // Generate dates starting from today, every `repeatEvery` days
      for (int i = 0; i <= 365; i++) {
        if (i % repeatEvery == 0) {
          DateTime date = DateTime(startYear, startMonth, startDay).add(Duration(days: i));
          dates.add(date);
        }
      }
    } else if (repeatEveryUnit == TimeUnit.week) {
      // Generate dates starting from today, every `repeatEvery` weeks
      for (int i = 0; i <= 365; i++) {
        if (i % (repeatEvery * 7) == 0) {
          DateTime date = DateTime(startYear, startMonth, startDay).add(Duration(days: i));
          dates.add(date);
        }
      }
    } else if (repeatEveryUnit == TimeUnit.month) {
      // Generate dates starting from today, every `repeatEvery` months
      for (int i = 0; i <= 12; i++) {
        DateTime date = DateTime(startYear, startMonth + (i * repeatEvery), startDay);
        dates.add(date);
      }
    }

    return dates;
  }

  DateTime generateNextDate() {
    // Get today's date
    DateTime today = DateTime.now();

    if (repeatEveryUnit == TimeUnit.day) {
      // For daily frequency, add `repeatEvery` days to today
      return today.add(Duration(days: repeatEvery));
    } else if (repeatEveryUnit == TimeUnit.week) {
      // For weekly frequency, add `repeatEvery` weeks to today
      return today.add(Duration(days: repeatEvery * 7));
    } else if (repeatEveryUnit == TimeUnit.month) {
      // For monthly frequency, add `repeatEvery` months to today
      return DateTime(today.year, today.month + repeatEvery, today.day);
    }

    // Default: return today if no frequency is set
    return today;
  }

  String getCustomFrequencyDescription() {
    return 'every'.tr + ' ${repeatEvery} ${repeatEveryUnit.name.tr}' +
           ' repeat'.tr + ' ';
  }
}
