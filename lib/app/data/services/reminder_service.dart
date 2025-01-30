import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/reminder_model.dart';
import '../models/reminder_state.dart';
import '../models/reminder_status.dart';
import 'storage_service.dart';

class ReminderService extends GetxService {
  final _logger = Logger();
  final _storageService = Get.find<StorageService>();

  Future<List<ReminderModel>> getReminders() async {
    try {
      return await _storageService.getReminders();
    } catch (e) {
      _logger.e('Error getting reminders: $e');
      return [];
    }
  }

  Future<List<ReminderModel>> getDayReminders(DateTime date) async {
    try {
      final allReminders = await getReminders();
      return allReminders.where((reminder) {
        final reminderDate = reminder.dateTime;
        return reminderDate.year == date.year &&
               reminderDate.month == date.month &&
               reminderDate.day == date.day;
      }).toList();
    } catch (e) {
      _logger.e('Error getting day reminders: $e');
      return [];
    }
  }

  Future<List<ReminderModel>> getRemindersForMedication(String medicationId) async {
    try {
      final allReminders = await getReminders();
      return allReminders.where((reminder) => reminder.medicationId == medicationId).toList();
    } catch (e) {
      _logger.e('Error getting reminders for medication: $e');
      return [];
    }
  }

  Future<bool> saveReminder(ReminderModel reminder) async {
    try {
      return await _storageService.createReminder(reminder);
    } catch (e) {
      _logger.e('Error saving reminder: $e');
      return false;
    }
  }

  Future<bool> updateReminderStatus(String id, ReminderStatus newStatus) async {
    try {
      final reminder = await getReminderById(id);
      if (reminder == null) return false;

      final updatedReminder = reminder.copyWith(
        statusHistory: [
          ...reminder.statusHistory,
          newStatus,
        ],
      );

      return await _storageService.updateReminder(updatedReminder);
    } catch (e) {
      _logger.e('Error updating reminder status: $e');
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      return await _storageService.deleteReminder(id);
    } catch (e) {
      _logger.e('Error deleting reminder: $e');
      return false;
    }
  }

  Future<ReminderModel?> getReminderById(String id) async {
    try {
      return await _storageService.getReminderById(id);
    } catch (e) {
      _logger.e('Error getting reminder by id: $e');
      return null;
    }
  }
}
