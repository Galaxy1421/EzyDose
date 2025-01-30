

 import 'package:reminder/app/data/repository/reminder_repository.dart';

import '../../models/reminder_model.dart';

class AddReminderUseCase{
  final ReminderRepository repository;

  AddReminderUseCase({required this.repository});

  Future<void> call(ReminderModel reminder) => repository.addReminder(reminder);
 }