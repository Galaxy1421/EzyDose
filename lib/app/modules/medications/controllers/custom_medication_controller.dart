import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/models/reminder_frequency_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/reminder_state.dart';
import '../../../data/models/reminder_status.dart';
import '../../../data/services/medication_service.dart';
import '../../../data/services/reminder_service.dart';
import '../../../data/services/routine_service.dart';
import '../../../data/services/notification_service.dart';
import 'package:intl/intl.dart';

class CustomMedicationController extends GetxController {
  final _medicationService = Get.find<MedicationService>();
  final _reminderService = Get.find<ReminderService>();
  final _notificationService = Get.find<NotificationService>();
  final _routineService = Get.find<RoutineService>();
  final _uuid = const Uuid();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final nameController = TextEditingController();
  final instructionsController = TextEditingController();
  final doseQuantityController = TextEditingController();
  final totalQuantityController = TextEditingController();
  final unitController = TextEditingController();
  final prescriptionDetailsController = TextEditingController();

  // Observable values
  final currentTab = 0.obs;
  final selectedFrequency = ReminderFrequency.daily.obs;
  final reminders = <ReminderModel>[].obs;
  final selectedMedicationImage = Rx<String?>(null);
  final expiryDate = Rx<DateTime?>(null);
  final isEditing = false.obs;
  final searchResults = <MedicationModel>[].obs;

  // Methods for reminder management
  void addReminder(TimeOfDay time, {required ReminderType type}) {
    final now = DateTime.now();
    final reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final reminder = ReminderModel(
      id: _uuid.v4(),
      dateTime: reminderDateTime,
      type: type,
      statusHistory: [
        ReminderStatus(
          timestamp: DateTime.now(),
          state: ReminderState.pending,
        ),
      ], frequency: null,
    );

    reminders.add(reminder);
  }

  void removeReminder(int index) {
    if (index >= 0 && index < reminders.length) {
      reminders.removeAt(index);
    }
  }

  void onTimeSelected(TimeOfDay time) {
    addReminder(time, type: ReminderType.custom);
  }

  void updateReminderType(ReminderType type) {
    // Implementation for updating reminder type
  }

  void updateReminderFrequency(ReminderFrequency frequency) {
    selectedFrequency.value = frequency;
  }

  String getFormattedReminderTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  // Navigation methods
  void onNextTabPressed() {
    if (formKey.currentState!.validate()) {
      currentTab.value = 1;
    }
  }

  void onPreviousTabPressed() {
    currentTab.value = 0;
  }

  void onSavePressed() async {
    if (formKey.currentState!.validate()) {
      // Save medication and reminders logic here
      Get.back();
    }
  }

  // Search and medication selection methods
  void onSearchChanged(String value) {
    // Implementation for medication search
  }

  void onMedicationSelected(MedicationModel medication) {
    nameController.text = medication.name;
    selectedMedicationImage.value = medication.imageUrl;
    // Set other medication details
  }

  @override
  void onClose() {
    nameController.dispose();
    instructionsController.dispose();
    doseQuantityController.dispose();
    totalQuantityController.dispose();
    unitController.dispose();
    prescriptionDetailsController.dispose();
    super.onClose();
  }
}
