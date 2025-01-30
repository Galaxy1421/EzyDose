import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/medication_model.dart';
import '../models/interaction_model.dart';
import 'storage_service.dart';

class MedicationService extends GetxService {
  final _logger = Logger();
  final _storage = Get.find<StorageService>();
  final RxList<MedicationModel> medications = <MedicationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMedications();
  }

  Future<void> loadMedications() async {
    try {
      // final List<MedicationModel> loadedMedications = await _storage.getAllMedications();
      // medications.assignAll(loadedMedications);
      // _logger.i('Loaded ${medications.length} medications');
    } catch (e) {
      _logger.e('Error loading medications: $e');
      medications.clear(); // Clear the list in case of error
    }
  }

  Future<String> addMedication(MedicationModel medication) async {
    try {
      final String id = await _storage.insertMedication(medication);
      await loadMedications();
      _logger.i('Added medication: $id');
      return id;
    } catch (e) {
      _logger.e('Error adding medication: $e');
      rethrow;
    }
  }

  Future<void> updateMedication(MedicationModel medication) async {
    try {
      await _storage.updateMedication(medication);
      await loadMedications();
      _logger.i('Updated medication: ${medication.id}');
    } catch (e) {
      _logger.e('Error updating medication: $e');
      rethrow;
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _storage.deleteMedication(id);
      await loadMedications();
      _logger.i('Deleted medication: $id');
    } catch (e) {
      _logger.e('Error deleting medication: $e');
      rethrow;
    }
  }

  MedicationModel? findMedicationById(String id) {
    try {
      return medications.firstWhereOrNull((med) => med.id == id);
    } catch (e) {
      _logger.e('Error finding medication: $e');
      return null;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  Future<MedicationService> init() async {
    await loadMedications();
    return this;
  }
}
