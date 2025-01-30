

 import 'package:reminder/app/data/repository/reminder_repository.dart';

import '../../models/reminder_model.dart';

class GetAllRemindersUsecase{
  final ReminderRepository repository;

  GetAllRemindersUsecase({required this.repository});

  Future<List<ReminderModel>> call() => repository.getAllReminders();
 }
 class GetAllRemindersByDateUsecase{
  final ReminderRepository repository;

  GetAllRemindersByDateUsecase({required this.repository});

  Future<List<ReminderModel>> call(DateTime day) => repository.getAllRemindersByTime(day);
 }