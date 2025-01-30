import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import '../models/reminder_model.dart';
import '../models/medication_model.dart';
import '../models/interaction_model.dart';

class StorageService extends GetxService {
  static const String _remindersKey = 'reminders';
  static const String _medicationsKey = 'medications';
  static const String _interactionsKey = 'interactions';
  
  final _logger = Logger();
  final _reminderBox = GetStorage('reminders');
  final _medicationBox = GetStorage('medications');
  final _interactionBox = GetStorage('interactions');

  Future<StorageService> init() async {
    try {
      await GetStorage.init('medications');
      await GetStorage.init('reminders');
      await GetStorage.init('interactions');
      
      _logger.i('Storage service initialized');
      return this;
    } catch (e) {
      _logger.e('Error initializing storage service: $e');
      rethrow;
    }
  }

  Future<void> _addSampleData() async {
    try {
      // Add a sample medication
      final medication = MedicationModel(
        id: 'med1',
        name: 'Ibuprofen',
        instructions: 'Take with food',
        totalQuantity: 30,
        doseQuantity: 1,
        unit: 'tablet',
        frequency: MedicationFrequency.daily,
      );
      await insertMedication(medication);

      // Add a sample reminder

      _logger.i('Added sample data');
    } catch (e) {
      _logger.e('Error adding sample data: $e');
      rethrow;
    }
  }

  // Medication Methods
  Future<String> insertMedication(MedicationModel medication) async {
    try {
      final id = medication.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : medication.id;
      final medicationWithId = medication.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final json = {
        'id': medicationWithId.id,
        'name': medicationWithId.name,
        'instructions': medicationWithId.instructions,
        'totalQuantity': medicationWithId.totalQuantity,
        'remainingQuantity': medicationWithId.remainingQuantity ?? medicationWithId.totalQuantity,
        'doseQuantity': medicationWithId.doseQuantity,
        'unit': medicationWithId.unit,
        'interactions': medicationWithId.interactions.map((i) => i.toJson()).toList(),
        'imageUrl': medicationWithId.imageUrl,
        'hasPrescription': medicationWithId.hasPrescription,
        'prescriptionText': medicationWithId.prescriptionText,
        'prescriptionImage': medicationWithId.prescriptionImage,
        'expiryDate': medicationWithId.expiryDate?.toIso8601String(),
        'createdAt': medicationWithId.createdAt.toIso8601String(),
        'updatedAt': medicationWithId.updatedAt.toIso8601String(),
        'frequency': medicationWithId.frequency.toString(),
      };
      _logger.d('Inserting medication with ID $id: $json');
      await _medicationBox.write(id, json);
      _logger.i('Successfully inserted medication with ID $id');
      return id;
    } catch (e) {
      _logger.e('Error inserting medication: $e');
      throw Exception('Failed to insert medication');
    }
  }

  Future<void> updateMedication(MedicationModel medication) async {
    try {
      await _medicationBox.write(medication.id, medication.toJson());
      _logger.i('Updated medication: ${medication.id}');
    } catch (e) {
      _logger.e('Error updating medication: $e');
      throw Exception('Failed to update medication');
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _medicationBox.remove(id);
      // Delete related interactions
      final interactions = await getMedicationInteractions(id);
      for (var interaction in interactions) {
        await deleteInteraction(interaction.id);
      }
      _logger.i('Deleted medication: $id');
    } catch (e) {
      _logger.e('Error deleting medication: $e');
      throw Exception('Failed to delete medication');
    }
  }

  Future<MedicationModel?> getMedicationById(String id) async {
    try {
      final json = _medicationBox.read(id);
      _logger.i('Retrieved medication: $id');
      return json != null ? MedicationModel.fromJson(Map<String, dynamic>.from(json)) : null;
    } catch (e) {
      _logger.e('Error getting medication by id: $e');
      throw Exception('Failed to get medication');
    }
  }

  Future<List<MedicationModel>> getAllMedications() async {
    try {
      final keys = _medicationBox.getKeys();
      _logger.i('Found ${keys.length} medications in storage');
      
      if (keys.isEmpty) {
        _logger.i('No medications found in storage');
        return [];
      }

      final List<MedicationModel> medications = [];
      
      for (final key in keys) {
        try {
          final json = _medicationBox.read(key);
          _logger.d('Reading medication $key: $json');
          
          if (json == null) {
            _logger.w('Null JSON found for medication $key');
            continue;
          }

          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(json);
          final medication = MedicationModel.fromJson(jsonMap);
          medications.add(medication);
          _logger.d('Successfully parsed medication $key');
        } catch (e) {
          _logger.e('Error parsing medication $key: $e');
          continue;
        }
      }
      
      _logger.i('Successfully retrieved ${medications.length} medications');
      return medications;
    } catch (e) {
      _logger.e('Error getting all medications: $e');
      throw Exception('Failed to get medications');
    }
  }

  // Reminder Methods
  Future<List<ReminderModel>> getReminders() async {
    try {
      final List<ReminderModel> reminders = [];
      final keys = _reminderBox.getKeys();
      
      for (final key in keys) {
        try {
          final json = _reminderBox.read(key);
          _logger.d('Reading reminder $key: $json');
          
          if (json == null) {
            _logger.w('Null JSON found for reminder $key');
            continue;
          }

          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(json);
          final reminder = ReminderModel.fromJson(jsonMap);
          reminders.add(reminder);
          _logger.d('Successfully parsed reminder $key');
        } catch (e) {
          _logger.e('Error parsing reminder $key: $e');
          continue;
        }
      }
      
      _logger.i('Successfully retrieved ${reminders.length} reminders');
      return reminders;
    } catch (e) {
      _logger.e('Error getting reminders: $e');
      return [];
    }
  }

  Future<ReminderModel?> getReminderById(String id) async {
    try {
      final json = _reminderBox.read(id);
      if (json == null) return null;
      return ReminderModel.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      _logger.e('Error getting reminder by id: $e');
      return null;
    }
  }

  Future<bool> createReminder(ReminderModel reminder) async {
    try {
      final json = reminder.toJson();
      await _reminderBox.write(reminder.id, json);
      _logger.i('Created reminder: ${reminder.id}');
      return true;
    } catch (e) {
      _logger.e('Error creating reminder: $e');
      return false;
    }
  }

  Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      final json = reminder.toJson();
      await _reminderBox.write(reminder.id, json);
      _logger.i('Updated reminder: ${reminder.id}');
      return true;
    } catch (e) {
      _logger.e('Error updating reminder: $e');
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      await _reminderBox.remove(id);
      _logger.i('Deleted reminder: $id');
      return true;
    } catch (e) {
      _logger.e('Error deleting reminder: $e');
      return false;
    }
  }

  Future<void> deleteAllReminders() async {
    try {
      await _reminderBox.erase();
      _logger.i('Deleted all reminders');
    } catch (e) {
      _logger.e('Error deleting all reminders: $e');
      rethrow;
    }
  }

  // Interaction Methods
  Future<void> insertInteraction(InteractionModel interaction) async {
    try {
      await _interactionBox.write(interaction.id, interaction.toJson());
      _logger.i('Inserted interaction: ${interaction.id}');
    } catch (e) {
      _logger.e('Error inserting interaction: $e');
      throw Exception('Failed to insert interaction');
    }
  }

  Future<void> deleteInteraction(String id) async {
    try {
      await _interactionBox.remove(id);
      _logger.i('Deleted interaction: $id');
    } catch (e) {
      _logger.e('Error deleting interaction: $e');
      throw Exception('Failed to delete interaction');
    }
  }

  Future<List<InteractionModel>> getMedicationInteractions(String medicationId) async {
    try {
      final interactions = _interactionBox.getKeys().map((key) {
        final json = _interactionBox.read(key);
        return InteractionModel.fromJson(Map<String, dynamic>.from(json));
      }).where((interaction) => 
        interaction.medicationId == medicationId || 
        interaction.interactingMedicationId == medicationId
      ).toList();
      _logger.i('Retrieved ${interactions.length} interactions for medication: $medicationId');
      return interactions;
    } catch (e) {
      _logger.e('Error getting medication interactions: $e');
      throw Exception('Failed to get interactions');
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    try {
      await _medicationBox.erase();
      await _reminderBox.erase();
      await _interactionBox.erase();
      _logger.i('Cleared all storage');
    } catch (e) {
      _logger.e('Error clearing storage: $e');
      throw Exception('Failed to clear storage');
    }
  }
}
