import '../../models/medication_model.dart';
import '../../repository/medication_repository.dart';

class AddMedicationUseCase {
  final MedicationRepository repository;

  AddMedicationUseCase(this.repository);

  Future<void> call(MedicationModel medication) async {
    await repository.addMedication(medication);
  }
}