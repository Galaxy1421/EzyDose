

 import 'package:reminder/app/data/repository/reminder_repository.dart';

import '../../models/reminder_model.dart';

class UpdateReminderUseCase{
  final ReminderRepository repository;

  UpdateReminderUseCase({required this.repository});

  Future<void> call(ReminderModel reminder) => repository.updateReminder(reminder);
 }
 class GetReminderUseCase{
  final ReminderRepository repository;

  GetReminderUseCase({required this.repository});

  Future<ReminderModel?> call(String reminderId) => repository.getReminder(reminderId);
 }
 class DeleteMedicationRemindersUseCase{
  final ReminderRepository repository;

  DeleteMedicationRemindersUseCase({required this.repository});

  Future<void> call(String id) => repository.deleteMedicationReminders(id);
 }