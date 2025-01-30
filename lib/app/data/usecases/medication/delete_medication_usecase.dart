
import '../../models/medication_model.dart';
import '../../repository/medication_repository.dart';

class DeleteMedicationUseCase {
  final MedicationRepository repository;

  DeleteMedicationUseCase(this.repository);

  Future<void> call(MedicationModel medication) async {
    await repository.deleteMedication(medication);
  }
}