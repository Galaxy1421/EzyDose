import '../../models/medication_model.dart';
import '../../repository/medication_repository.dart';

class GetMedicationByIdUseCase {
  final MedicationRepository repository;

  GetMedicationByIdUseCase(this.repository);

  Future<MedicationModel?> call(String id) async {
    return await repository.getMedicationById(id);
  }
}