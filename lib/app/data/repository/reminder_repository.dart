


import '../models/reminder_model.dart';

abstract class ReminderRepository{
  Future<void> addReminder(ReminderModel reminder);
  Future<void> updateReminder(ReminderModel reminder);
  Future<ReminderModel> getReminder(String reminderId);
  Future<void> deleteReminder(ReminderModel reminder);
  Future<void> deleteMedicationReminders(String medicationId);
  Future<List<ReminderModel>> getAllReminders();
  Future<List<ReminderModel>> getAllRemindersByTime(DateTime day);
  Future<List<ReminderModel>> getAllRemindersByMedcationId(String medicationId);

}