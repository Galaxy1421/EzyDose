import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/reminder_model.dart';

import '../models/medication_model.dart';
import 'local_medication_data_source.dart';

/// Abstract class for local reminder data source
abstract class LocalReminderDataSource {
  Future<List<ReminderModel>> getAllReminders();
  Future<List<ReminderModel>> getAllRemindersByDate(int day);
  Future<List<ReminderModel>> getReminderByMedcationId(String id);
  Future<void> addReminder(ReminderModel model);
  Future<void> getReminder(String id);
  Future<void> removeReminder(ReminderModel model);
  Future<void> updateReminder(ReminderModel model);
}

/// Implementation of local reminder data source
class LocalReminderDatSourceImpl extends LocalReminderDataSource {
  final String boxName = "local_reminders";
  late final GetStorage _box;

  LocalReminderDatSourceImpl() {
    _box = GetStorage(boxName);
  }

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final List<dynamic> rawList = _box.read('reminders') ?? [];
      return rawList.map((item) => ReminderModel.fromJson(item)).toList();
    } catch (e) {
      print('Error getting all reminders: $e');
      return [];
    }
  }

  @override
  Future<void> addReminder(ReminderModel model) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      reminders.add(model.toJson());
      await _box.write('reminders', reminders);
    } catch (e) {
      print('Error adding reminder: $e');
      throw e;
    }
  }

  @override
  Future<void> removeReminder(ReminderModel model) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      reminders.removeWhere((item) =>
      ReminderModel.fromJson(item).id == model.id
      );
      await _box.write('reminders', reminders);
    } catch (e) {
      print('Error removing reminder: $e');
      throw e;
    }
  }
  @override
  Future<void> removeMedicationReminders(String medicationId) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      reminders.removeWhere((item) =>
      ReminderModel.fromJson(item).medicationId == medicationId
      );
      await _box.write('reminders', reminders);
    } catch (e) {
      print('Error removing reminder: $e');
      throw e;
    }
  }

  @override
  Future<void> updateReminder(ReminderModel model) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      int index = reminders.indexWhere((item) =>
      ReminderModel.fromJson(item).id == model.id
      );
      if (index != -1) {
        reminders[index] = model.toJson();
        await _box.write('reminders', reminders);
      } else {
        throw Exception('Reminder not found');
      }
    } catch (e) {
      print('Error updating reminder: $e');
      throw e;
    }
  }

  @override
  Future<List<ReminderModel>> getReminderByMedcationId(String id) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      return reminders
          .map((item) => ReminderModel.fromJson(item))
          .where((reminder) => reminder.medicationId == id)
          .toList();
    } catch (e) {
      print('Error getting reminders by medication ID: $e');
      return [];
    }
  }

  @override
  Future<ReminderModel?> getReminder(String id) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      return reminders
          .map((item) => ReminderModel.fromJson(item))
          .firstWhere((reminder) => reminder.id == id);
    } catch (e) {
      print('Error getting reminder by ID: $e');
      return null;
    }
  }

  @override
  Future<List<ReminderModel>> getAllRemindersByDate(int day) async {
    try {
      List<dynamic> reminders = _box.read('reminders') ?? [];
      List<ReminderModel> allReminders = reminders
          .map((item) => ReminderModel.fromJson(item))
          .toList();

      List<ReminderModel> remindersByDate = [];
      final medicationDataSource = Get.find<LocalMedicationDataSource>();

      for (ReminderModel reminder in allReminders) {
        try {
          // Skip reminders without medication ID
          if (reminder.medicationId == null) {
            Logger().w('Reminder ${reminder.id} has no medication ID');
            continue;
          }

          // Get medication for the reminder
          MedicationModel? medication = await medicationDataSource
              .getMedicationById(reminder.medicationId!);

          // Skip if medication not found
          if (medication == null) {
            Logger().w('Medication not found for reminder ${reminder.id}');
            continue;
          }

          // Check frequency and add to list based on rules
          switch (medication.frequency) {
            case MedicationFrequency.monthly:
              if (reminder.dateTime.day == day) {
                remindersByDate.add(reminder);
                Logger().d('Added monthly reminder for day $day');
              }
              break;

            case MedicationFrequency.daily:
              remindersByDate.add(reminder);
              Logger().d('Added daily reminder');
              break;

            case MedicationFrequency.weekly:
              if (reminder.dateTime.weekday == day) {
                remindersByDate.add(reminder);
                Logger().d('Added weekly reminder for weekday $day');
              }
              break;

            default:
              Logger().w('Unknown frequency for medication ${medication.id}');
              break;
          }
        } catch (e) {
          // Log error but continue processing other reminders
          Logger().e('Error processing reminder ${reminder.id}: $e');
          continue;
        }
      }

      Logger().i('Found ${remindersByDate.length} reminders for day $day');
      return remindersByDate;

    } catch (e) {
      Logger().e('Error getting reminders by date: $e');
      return [];
    }
  }
}