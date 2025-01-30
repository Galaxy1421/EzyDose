import '../../models/medication_model.dart';
import '../../repository/medication_repository.dart';

class UpdateMedicationUseCase {
  final MedicationRepository repository;

  UpdateMedicationUseCase(this.repository);

  Future<void> call(MedicationModel medication) async {
    await repository.updateMedication(medication);
  }
}