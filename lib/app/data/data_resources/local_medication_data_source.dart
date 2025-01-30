import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reminder/app/data/models/medication_model.dart';

abstract class LocalMedicationDataSource {
  Future<List<MedicationModel>> getAllMedications();
  Future<MedicationModel?> getMedicationById(String id);
  Future<void> addMedication(MedicationModel model);
  Future<void> removeMedication(MedicationModel model);
  Future<MedicationModel?> getMedication(String id);
  Future<void> updateMedication(MedicationModel model);
}

class LocalMedicationDataSourceImpl extends LocalMedicationDataSource {
  final String boxName = "local_medication";
  late final GetStorage _box;

  LocalMedicationDataSourceImpl() {
    _box = GetStorage(boxName);
  }

  @override
  Future<List<MedicationModel>> getAllMedications() async {
    try {
      final List<dynamic> rawList = _box.read('medications') ?? [];
      return rawList.map((item) => MedicationModel.fromJson(item)).toList();
    } catch (e) {
      print('Error getting all medications: $e');
      return [];
    }
  }

  @override
  Future<void> addMedication(MedicationModel model) async {
    try {
      List<dynamic> medications = _box.read('medications') ?? [];
      medications.add(model.toJson());
      await _box.write('medications', medications);
    } catch (e) {
      print('Error adding medication: $e');
      throw e;
    }
  }

  @override
  Future<void> removeMedication(MedicationModel model) async {
    try {
      List<dynamic> medications = _box.read('medications') ?? [];
      medications.removeWhere((item) =>
      MedicationModel.fromJson(item).id == model.id
      );
      await _box.write('medications', medications);
    } catch (e) {
      print('Error removing medication: $e');
      throw e;
    }
  }

  @override
  Future<void> updateMedication(MedicationModel model) async {
    try {
      List<dynamic> medications = _box.read('medications') ?? [];
      int index = medications.indexWhere((item) =>
      MedicationModel.fromJson(item).id == model.id
      );
      if (index != -1) {
        medications[index] = model.toJson();
        await _box.write('medications', medications);
      } else {
        throw Exception('Medication not found');
      }
    } catch (e) {
      print('Error updating medication: $e');
      throw e;
    }
  }

  @override
  Future<MedicationModel?> getMedicationById(String id) async {
    try {
      List<dynamic> medications = _box.read('medications') ?? [];
      final medication = medications
          .map((item) => MedicationModel.fromJson(item))
          .firstWhere((medication) => medication.id == id);
      return medication;
    } catch (e) {
      print('Error getting medication by ID: $e');
      return null;
    }
  }

  @override
  Future<MedicationModel?> getMedication(String id) async {
    try {
      List<dynamic> medications = _box.read('medications') ?? [];
      final medicationList = medications
          .map((item) => MedicationModel.fromJson(item))
          .toList();
          
      final medication = medicationList.firstWhere(
        (medication) => medication.id == id,
        orElse: () => throw Exception('Medication not found'),
      );
      return medication;
    } catch (e) {
      print('Error getting medication by ID: $e');
      return null;
    }
  }
}