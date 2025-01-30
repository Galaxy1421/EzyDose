


import '../models/medication_model.dart';

abstract class MedicationRepository {
  Future<void> addMedication(MedicationModel medication);
  Future<void> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(MedicationModel medication);
  Future<MedicationModel?> getMedication(String id);
  Future<List<MedicationModel>> getAllMedications();
  Future<MedicationModel?> getMedicationById(String medicationId);
}
