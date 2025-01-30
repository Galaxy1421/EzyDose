import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reminder/app/data/data_resources/local_medication_data_source.dart';
import 'package:reminder/app/data/data_resources/remote_medication_data_source.dart';
import 'package:reminder/app/data/repository/medication_repository.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final LocalMedicationDataSource _localMedicationDataSource;
  final RemoteMedicationDataSource _remoteMedicationDataSource;
  final Connectivity _connectivity = Connectivity();

  MedicationRepositoryImpl({
    required LocalMedicationDataSource localMedicationDataSource,
    required RemoteMedicationDataSource remoteMedicationDataSource,
  })
      : _localMedicationDataSource = localMedicationDataSource,
        _remoteMedicationDataSource = remoteMedicationDataSource;

  Future<bool> _isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<List<MedicationModel>> getAllMedications() async {
    try {
      if (await _isConnected()) {
        final medications = await _remoteMedicationDataSource
            .getAllMedications();
        await Future.wait(medications.map((medication) =>
            _localMedicationDataSource.addMedication(medication)));
        return medications;
      } else {
        return await _localMedicationDataSource.getAllMedications();
      }
    } catch (e) {
      print('Error getting all medications: $e');
      return [];
    }
  }

  @override
  Future<MedicationModel?> getMedicationById(String medicationId) async {
    try {
      if (await _isConnected()) {
        return await _remoteMedicationDataSource.getMedicationById(
            medicationId);
      } else {
        return await _localMedicationDataSource.getMedicationById(medicationId);
      }
    } catch (e) {
      print('Error getting medication by ID: $e');
      return null;
    }
  }

  @override
  Future<void> addMedication(MedicationModel medication) async {
    try {
      await _localMedicationDataSource.addMedication(medication);
      if (await _isConnected()) {
        await _remoteMedicationDataSource.addMedication(medication);
      }
    } catch (e) {
      print('Error adding medication: $e');
      throw e;
    }
  }

  @override
  Future<void> deleteMedication(MedicationModel medication) async {
    try {
      await _localMedicationDataSource.removeMedication(medication);
      if (await _isConnected()) {
        await _remoteMedicationDataSource.removeMedication(medication);
      }
    } catch (e) {
      print('Error deleting medication: $e');
      throw e;
    }
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    try {
      await _localMedicationDataSource.updateMedication(medication);
      if (await _isConnected()) {
        await _remoteMedicationDataSource.updateMedication(medication);
      }
    } catch (e) {
      print('Error updating medication: $e');
      throw e;
    }
  }

  @override
  Future<MedicationModel?> getMedication(String id) async {
    try {
      return await _localMedicationDataSource.getMedication(id);
    } catch (e) {
      print('Error getting medication by ID: $e');
      throw e;
    }
  }
}