import '../../models/medication_model.dart';
import '../../repository/medication_repository.dart';

class GetAllMedicationsUseCase {
  final MedicationRepository repository;

  GetAllMedicationsUseCase(this.repository);

  Future<List<MedicationModel>> call() async {
    return await repository.getAllMedications();
  }
}
class GetMedicationUseCase {
  final MedicationRepository repository;

  GetMedicationUseCase(this.repository);

  Future<MedicationModel?> call(String id) async {
    return await repository.getMedication(id);
  }
}