import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reminder/app/data/usecases/medication/get_all_medications_usecase.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/services/settings_service.dart';

class NotificationsController extends GetxController {
  final _storage = GetStorage();
  final GetAllMedicationsUseCase _allMedicationsUseCase = Get.find();
  final medications = <MedicationModel>[].obs;
  final expiryDaysThreshold = 30.0.obs;
  final quantityThreshold = 5.0.obs;

  // Reminder settings
  final selectedExpiryReminderDays = 3.obs;
  final selectedQuantityReminderDays = 3.obs;
  final expiryReminderOptions = [3, 7, 14, 30];
  final quantityReminderOptions = [3, 7, 14, 30];

  @override
  void onInit() {
    super.onInit();
    loadThresholds();
    loadMedications();
    selectedExpiryReminderDays.value = _storage.read('expiry_reminder_days') ?? 3;
    selectedQuantityReminderDays.value = _storage.read('quantity_reminder_days') ?? 3;
  }

  void loadThresholds() {
    expiryDaysThreshold.value = _storage.read('expiryDaysThreshold')?.toDouble() ?? 30.0;
    quantityThreshold.value = _storage.read('quantityThreshold')?.toDouble() ?? 5.0;
  }

  void updateExpiryThreshold(double value) {
    expiryDaysThreshold.value = value;
    _storage.write('expiryDaysThreshold', value);
    loadMedications();
  }

  void updateQuantityThreshold(double value) {
    quantityThreshold.value = value;
    _storage.write('quantityThreshold', value);
    loadMedications();
  }

  Future<void> loadMedications() async {
    medications.value = await _allMedicationsUseCase.call();
    // TODO: Load medications from your data source
    // This is where you'll implement the actual medication loading logic
    // For now, we'll just work with the thresholds
  }

  void onExpiryReminderDaysChanged(int days) {
    selectedExpiryReminderDays.value = days;
    _storage.write('expiry_reminder_days', days);
  }

  void onQuantityReminderDaysChanged(int days) {
    selectedQuantityReminderDays.value = days;
    _storage.write('quantity_reminder_days', days);
  }

  List<MedicationModel> getExpiringMedications() {
    final now = DateTime.now();
    return medications.where((med) {
      if (med.expiryDate == null) return false;
      final daysUntilExpiry = med.expiryDate!.difference(now).inDays;
      return daysUntilExpiry <= expiryDaysThreshold.value;
    }).toList();
  }

  List<MedicationModel> getLowQuantityMedications() {
    return medications.where((med) {
      return med.remainingQuantity <= quantityThreshold.value;
    }).toList();
  }
}
