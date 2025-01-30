import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import 'package:reminder/app/data/services/auth_service.dart';
import 'package:reminder/app/data/services/medication_service.dart';
import '../../../data/models/medication_model.dart';

class MedicationReminderController extends GetxController {
  final _reminderService = Get.find<MedicationService>();
  final _logger = Logger();

  // Observable variables for UI
  final selectedDate = DateTime.now().obs;
  final upcomingReminders = <MedicationModel>[].obs;
  final missedReminders = <MedicationModel>[].obs;
  final takenReminders = <MedicationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRemindersForDate(selectedDate.value);
    // Listen for date changes
    ever(selectedDate, (date) => loadRemindersForDate(date));
  }

  Future<void> loadRemindersForDate(DateTime date) async {
    try {
      _logger.d('Loading reminders for date: $date');
      isLoading.value = true;

      // final allMedications = _reminderService.medications.value;
      // _logger.d('Total medications: ${allMedications.length}');
      //
      // // Filter medications for the selected date
      // final medicationsForDate = allMedications.where((med) {
      //   final isScheduled = med.isScheduledForDate(date);
      //   _logger.d('Medication ${med.name} scheduled for $date: $isScheduled');
      //   return isScheduled;
      // }).toList();
      
      // _logger.d('Found ${medicationsForDate.length} medications for date $date');
      //
      // // Categorize medications based on their status for this date
      // upcomingReminders.value = medicationsForDate
      //     .where((med) => med.getStatusForDate(date) == 'upcoming')
      //     .toList();
      //
      // missedReminders.value = medicationsForDate
      //     .where((med) => med.getStatusForDate(date) == 'skipped')
      //     .toList();
      //
      // takenReminders.value = medicationsForDate
      //     .where((med) => med.getStatusForDate(date) == 'taken')
      //     .toList();
      //
      // _logger.d('Categorized reminders for $date:');
      // _logger.d('- Upcoming: ${upcomingReminders.length}');
      // _logger.d('- Missed: ${missedReminders.length}');
      // _logger.d('- Taken: ${takenReminders.length}');
      
    } catch (e, stackTrace) {
      _logger.e('Error loading reminders', error: e, stackTrace: stackTrace);
      // Reset lists on error
      upcomingReminders.value = [];
      missedReminders.value = [];
      takenReminders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markReminderAsTaken(MedicationModel medication, DateTime reminderTime) async {
    try {
      _logger.d('Marking reminder as taken: ${medication.name} at $reminderTime');
      
      // Update the medication's status
      // medication.updateStatusForDate(reminderTime, 'taken');
      
      // Update the medication in storage
      // await _reminderService.updateMedication(medication);
      
      // Move medication to taken list
      upcomingReminders.value = upcomingReminders.where((med) => med.id != medication.id).toList();
      takenReminders.value = [...takenReminders, medication];
      
      // Get.snackbar(
      //   'Success',
      //   'Medication marked as taken',
      //   backgroundColor: Colors.green.withOpacity(0.1),
      //   colorText: Colors.green,
      // );
      SnackbarService().showSuccess(
          AppHelper.isArabic
              ? "تم تسجيل تناول الدواء بنجاح"
              : "Medication marked as taken successfully"
      );

    } catch (e) {
      _logger.e('Error marking reminder as taken: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to mark medication as taken',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في تسجيل تناول الدواء"
              : "Failed to mark medication as taken"
      );

    }
  }

  Future<void> markReminderAsSkipped(MedicationModel medication, DateTime reminderTime) async {
    try {
      _logger.d('Marking reminder as skipped: ${medication.name} at $reminderTime');
      
      // Update the medication's status
      // medication.updateStatusForDate(reminderTime, 'skipped');
      
      // Update the medication in storage
      // await _reminderService.updateMedication(medication);
      
      // Move medication to missed list
      upcomingReminders.value = upcomingReminders.where((med) => med.id != medication.id).toList();
      missedReminders.value = [...missedReminders, medication];
      
      // Get.snackbar(
      //   'Reminder Skipped',
      //   'Medication marked as skipped',
      //   backgroundColor: Colors.orange.withOpacity(0.1),
      //   colorText: Colors.orange,
      // );
      SnackbarService().showWarning(
          AppHelper.isArabic
              ? "تم تجاهل التذكير: تم وسم الدواء كمتخطى"
              : "Reminder skipped: Medication marked as skipped"
      );

    } catch (e) {
      _logger.e('Error marking reminder as skipped: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to mark medication as skipped',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في تسجيل الدواء كمتخطى"
              : "Failed to mark medication as skipped"
      );

    }
  }

  Future<void> scheduleReminder(MedicationModel medication, DateTime reminderTime) async {
    try {
      // await _reminderService.scheduleReminder(medication, reminderTime);
      // await loadRemindersForDate(selectedDate.value);
      
      // Get.snackbar(
      //   'Success',
      //   'Reminder scheduled successfully',
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
      SnackbarService().showSuccess(
          AppHelper.isArabic
              ? "تم جدولة التذكير بنجاح"
              : "Reminder scheduled successfully"
      );

    } catch (e) {
      _logger.e('Error scheduling reminder: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to schedule reminder',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في جدولة التذكير"
              : "Failed to schedule reminder"
      );

    }
  }

  Future<void> cancelReminder(MedicationModel medication, DateTime reminderTime) async {
    try {
      // await _reminderService.cancelReminder(medication, reminderTime);
      // await loadRemindersForDate(selectedDate.value);
      
      // Get.snackbar(
      //   'Success',
      //   'Reminder cancelled successfully',
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
      SnackbarService().showSuccess(
          AppHelper.isArabic
              ? "تم إلغاء التذكير بنجاح"
              : "Reminder cancelled successfully"
      );

    } catch (e) {
      _logger.e('Error cancelling reminder: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to cancel reminder',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في إلغاء التذكير"
              : "Failed to cancel reminder"
      );

    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  String getReminderStatus(MedicationModel medication, DateTime reminderTime) {
    final now = DateTime.now();
    
    if (takenReminders.any((med) => med.id == medication.id)) {
      return 'Taken';
    } else if (missedReminders.any((med) => med.id == medication.id)) {
      return 'Missed';
    } else if (reminderTime.isAfter(now)) {
      return 'Upcoming';
    } else {
      return 'Due';
    }
  }

  Color getReminderStatusColor(String status) {
    switch (status) {
      case 'Taken':
        return Colors.green;
      case 'Missed':
        return Colors.red;
      case 'Upcoming':
        return Colors.blue;
      case 'Due':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<MedicationModel> getAllRemindersForDate(DateTime date) {
    return [
      ...upcomingReminders,
      ...missedReminders,
      ...takenReminders,
    ];
  }

  bool hasRemindersForDate(DateTime date) {
    return upcomingReminders.isNotEmpty ||
           missedReminders.isNotEmpty ||
           takenReminders.isNotEmpty;
  }
}
