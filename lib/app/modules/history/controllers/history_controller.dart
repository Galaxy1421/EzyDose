import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/usecases/reminder/get_all_reminders_usecase.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/reminder_state.dart';

class HistoryController extends GetxController {
  final _logger = Logger();
  final _reminderService = GetAllRemindersUsecase(repository: Get.find());
  
  final selectedDate = DateTime.now().obs;
  final reminders = <ReminderModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  Future<void> selectDate(DateTime date) async {
    selectedDate.value = date;
    await loadReminders();
  }

  Future<void> loadReminders() async {
    try {
      isLoading.value = true;
      final allReminders = await _reminderService();
      
      // Filter reminders for selected date
      reminders.value = allReminders.where((reminder) {
        final reminderDate = reminder.dateTime;
        return reminderDate.year == selectedDate.value.year &&
               reminderDate.month == selectedDate.value.month &&
               reminderDate.day == selectedDate.value.day;
      }).toList();
    } catch (e) {
      _logger.e('Error loading reminders: $e');
      Get.snackbar(
        'Error',
        'Failed to load reminders',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReminderStatus(String id, ReminderState newState) async {
    // try {
    //   final status = ReminderStatus(
    //     timestamp: DateTime.now(),
    //     state: newState,
    //   );
    //
    //   // final success = await _reminderService.updateReminderStatus(id, status);
    //   // if (success) {
    //   //   await loadReminders();
    //   // } else {
    //   //   Get.snackbar(
    //   //     'Error',
    //   //     'Failed to update reminder status',
    //   //     snackPosition: SnackPosition.BOTTOM,
    //   //   );
    //   }
    // } catch (e) {
    //   _logger.e('Error updating reminder status: $e');
    //   Get.snackbar(
    //     'Error',
    //     'Failed to update reminder status',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }

  Color getStatusColor(ReminderState status) {
    switch (status) {
      case ReminderState.taken:
        return AppColors.success;
      case ReminderState.missed:
        return AppColors.error;
      case ReminderState.skipped:
        return AppColors.warning;
      case ReminderState.pending:
        return AppColors.primary;
      default:
        return AppColors.textLight;
    }
  }

  IconData getStatusIcon(ReminderState status) {
    switch (status) {
      case ReminderState.taken:
        return Icons.check_circle;
      case ReminderState.missed:
        return Icons.cancel;
      case ReminderState.skipped:
        return Icons.skip_next;
      case ReminderState.pending:
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String getStatusText(ReminderState status) {
    return status.toString().split('.').last.toUpperCase();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  ReminderState getCurrentStatus(ReminderModel reminder) {
    if (reminder.statusHistory.isEmpty) {
      return ReminderState.pending;
    }

    final statusForDate = reminder.statusHistory
        .where((status) => isSameDay(status.timestamp, selectedDate.value))
        .toList();

    if (statusForDate.isEmpty) {
      return ReminderState.pending;
    }

    return statusForDate.last.state;
  }
}
