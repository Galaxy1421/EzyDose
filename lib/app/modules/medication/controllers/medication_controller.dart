import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/medication_model.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import 'package:reminder/app/data/models/interaction_model.dart';
import 'package:reminder/app/data/services/medication_service.dart';
import 'package:uuid/uuid.dart';

class MedicationController extends GetxController {
  final MedicationService _medicationService = Get.find<MedicationService>();
  final logger = Logger();
  final uuid = Uuid();

  final RxList<MedicationModel> medications = <MedicationModel>[].obs;
  final RxBool isLoading = false.obs;

  // Form fields
  final nameController = TextEditingController();
  final instructionsController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  final quantityController = TextEditingController();
  final remainingQuantityController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadMedications();
  }

  Future<void> loadMedications() async {
    try {
      isLoading.value = true;
      await _medicationService.loadMedications();
      medications.assignAll(_medicationService.medications);
    } catch (e) {
      logger.e('Error loading medications: $e');
      Get.snackbar(
        'Error',
        'Failed to load medications',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMedication(MedicationModel medication) async {
    try {
      await _medicationService.addMedication(medication);
      Get.snackbar(
        'Success',
        'Medication added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadMedications();
    } catch (e) {
      logger.e('Error adding medication: $e');
      Get.snackbar(
        'Error',
        'Failed to add medication',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateMedication(MedicationModel medication) async {
    try {
      await _medicationService.updateMedication(medication);
      Get.snackbar(
        'Success',
        'Medication updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadMedications();
    } catch (e) {
      logger.e('Error updating medication: $e');
      Get.snackbar(
        'Error',
        'Failed to update medication',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _medicationService.deleteMedication(id);
      Get.snackbar(
        'Success',
        'Medication deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadMedications();
    } catch (e) {
      logger.e('Error deleting medication: $e');
      Get.snackbar(
        'Error',
        'Failed to delete medication',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _resetForm() {
    nameController.clear();
    instructionsController.clear();
    dosageController.clear();
    frequencyController.clear();
    quantityController.clear();
    remainingQuantityController.clear();
    startDateController.clear();
    endDateController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    instructionsController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    quantityController.dispose();
    remainingQuantityController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}
