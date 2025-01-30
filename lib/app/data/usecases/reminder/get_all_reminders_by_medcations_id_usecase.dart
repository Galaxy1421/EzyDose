

 import 'package:reminder/app/data/repository/reminder_repository.dart';

import '../../models/reminder_model.dart';

class GetAllRemindersByMedicationsIdUseCase{
  final ReminderRepository repository;

  GetAllRemindersByMedicationsIdUseCase({required this.repository});

  Future<List<ReminderModel>> call(String medicationId) => repository.getAllRemindersByMedcationId(medicationId);
 }