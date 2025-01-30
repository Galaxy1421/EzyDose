

 import 'package:reminder/app/data/repository/reminder_repository.dart';

import '../../models/reminder_model.dart';

class DeleteReminderUsecase{
  final ReminderRepository repository;

  DeleteReminderUsecase({required this.repository});

  Future<void> call(ReminderModel reminder) => repository.deleteReminder(reminder);
 }