import 'package:reminder/app/data/models/medication_model.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import 'package:reminder/app/data/models/interaction_model.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder_state.dart';
import '../models/reminder_status.dart';

class SampleData {
  static List<InteractionModel> _getAsprinInteractions() {
    return [
      InteractionModel(
        id: '3',
        medicationId: '1',
        interactingMedicationId: '2',
        medicationName: 'Ibuprofen',
        description: 'May increase risk of bleeding when taken together',
        riskLevel: RiskLevel.high,
        recommendation: 'Do not take together without medical supervision',
      ),
      InteractionModel(
        id: '4',
        medicationId: '1',
        interactingMedicationId: '3',
        medicationName: 'Paracetamol',
        description: 'May reduce effectiveness of both medications',
        riskLevel: RiskLevel.low,
        recommendation: 'Safe to take together as prescribed',
      ),
    ];
  }

  static List<InteractionModel> _getIbuprofenInteractions() {
    return [
      InteractionModel(
        id: '1',
        medicationId: '2',
        interactingMedicationId: '1',
        medicationName: 'Aspirin',
        description: 'May increase risk of bleeding when taken together',
        riskLevel: RiskLevel.high,
        recommendation: 'Do not take together without medical supervision',
      ),
      InteractionModel(
        id: '2',
        medicationId: '2',
        interactingMedicationId: '3',
        medicationName: 'Paracetamol',
        description: 'May increase risk of kidney problems',
        riskLevel: RiskLevel.moderate,
        recommendation: 'Monitor for signs of kidney problems and stay hydrated',
      ),
    ];
  }

  static List<MedicationModel> getSampleMedications() {
    return [
      MedicationModel(
        id: '1',
        name: 'Aspirin',
        instructions: 'Take with food',
        totalQuantity: 30,
        doseQuantity: 1,
        unit: 'pills',
        hasPrescription: false,
        imageUrl: 'assets/images/medications/lisinopril.jpg',
        interactions: _getAsprinInteractions(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MedicationModel(
        id: '2',
        name: 'Ibuprofen',
        instructions: 'Take after meals',
        totalQuantity: 60,
        doseQuantity: 2,
        unit: 'pills',
        hasPrescription: true,
        imageUrl: 'assets/images/medications/lisinopril.jpg',
        interactions: _getIbuprofenInteractions(),
        prescriptionText: 'Take for pain and inflammation',

        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MedicationModel(
        id: '3',
        name: 'Paracetamol',
        instructions: 'Take as needed for pain',
        totalQuantity: 40,
        doseQuantity: 1,
        unit: 'pills',
        hasPrescription: false,
        imageUrl: 'assets/images/medications/lisinopril.jpg',
        interactions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<ReminderModel> getSampleReminders() {
    return [

    ];
  }

  static List<ReminderModel> getSampleRemindersForMedication(String medicationId) {
    return getSampleReminders()
        .where((reminder) => reminder.medicationId == medicationId)
        .toList();
  }

  static List<InteractionModel> getSampleInteractionsForMedication(String medicationId) {
    final medication = findSampleMedicationById(medicationId);
    return medication?.interactions ?? [];
  }

  static MedicationModel? findSampleMedicationById(String id) {
    try {
      return getSampleMedications()
          .firstWhere((medication) => medication.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MedicationModel> searchSampleMedications(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getSampleMedications()
        .where((med) => med.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}
