import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import 'package:reminder/app/data/usecases/medication/get_all_medications_usecase.dart';
import 'package:reminder/app/modules/medications/controllers/custom_medication_contoller.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/models/reminder_state.dart';
import '../../../data/services/medication_service.dart';
import '../../../data/usecases/reminder/update_reminder_usecase.dart';
import '../../../routes/app_pages.dart';
import '../../dashboard/controllers/custom_reminder_controller.dart';

class MedicationsController extends GetxController {
  final MedicationService _medicationService = Get.find();
  final medications = <MedicationModel>[].obs;
  final medicationsMultiSelected = <MedicationModel>[].obs;
  final isLoading = false.obs;
  final logger = Logger();
  final CustomReminderController _reminderController = Get.find();
  final GetMedicationUseCase getMedicationUseCase = Get.find();

  RxBool  showMore = false.obs;
  RxBool  enableMultiSelectMed = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedications();
    ever(_medicationService.medications, (_) => loadMedications());
  }
  Future<int> calculateTakenReminders(String medicationId) async{
    MedicationModel? medicationModel = await getMedicationUseCase(medicationId);
    int does = medicationModel!.doseQuantity;
    int count = 0;
    final reminders = await _reminderController.getRemindersByMedicationId(medicationId);
   for(var reminder in reminders){
     for(var state in reminder.statusHistory){
       if(state.state == ReminderState.taken){
         count = count + does;
       }
     }
   }
   return count;
  }

  Future<void> loadMedications() async {
    try {
      isLoading.value = true;
      await _medicationService.loadMedications();
      medications.value = _medicationService.medications.toList()
        ..sort((a, b) => (b.expiryDate ?? DateTime.now())
            .compareTo(a.expiryDate ?? DateTime.now()));
    } catch (e) {
      logger.e('Error loading medications: $e');
      Get.snackbar(
        'Error',
        'Failed to load medications: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'No date set';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  bool isExpired(DateTime? expirationDate) {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    return expirationDate.isBefore(now);
  }

  void showMedicationOptions(MedicationModel medication) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title:  Text('edit_medication'.tr),
              onTap: () {
                Get.back();
                editMedication(medication);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:  Text('delete_medication'.tr, style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.dialog(
                  // barrierColor: Colors.white,
                    AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      title: Text('delete_medication'.tr),
                      content: Text(
                        'delete_medication_confirmation'.trParams({'name': medication.name}),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('cancel'.tr),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.find<CustomMedicationController>().deleteMedication(medication);
                            Get.find<DeleteMedicationRemindersUseCase>().call(medication.id);
                            // Get.back();
                            if (Get.isDialogOpen ?? false) {
                              Get.back(); // يغلق الـ Dialog
                            }

                            // إغلاق الـ BottomSheet إذا كان مفتوحًا
                            if (Get.isBottomSheetOpen ?? false) {
                              Get.back(); // يغلق الـ BottomSheet
                            }
                          },
                          child: Text(
                            'delete'.tr,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                );

              },
            ),
          ],
        ),
      ),
    );
  }

  void editMedication(MedicationModel medication) {
    Get.toNamed(Routes.ADD_MEDICATION, arguments: medication);
  }



  Future<void> _deleteMedication(MedicationModel medication) async {
    try {
      await _medicationService.deleteMedication(medication.id);
      Get.snackbar(
        'Success',
        'Medication deleted successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadMedications();
    } catch (e) {
      logger.e('Error deleting medication: $e');
      Get.snackbar(
        'Error',
        'Failed to delete medication: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<bool> isQuantitySufficient(MedicationModel medication) async {
    final _storage = GetStorage();
    int? selectedQuantityReminderDays =_storage.read('quantity_reminder_days') ?? 3;
    final takenQuantity = await calculateTakenReminders(medication.id);
    final remainingQuantity = medication.totalQuantity - takenQuantity;

    // حساب الجرعات اليومية بناءً على إعدادات المستخدم
    final dosesPerDay = medication.doseQuantity;
    final daysLeft = remainingQuantity ~/ dosesPerDay;

    return daysLeft >= selectedQuantityReminderDays;
  }
  Future<bool> isExpiryDateNear(MedicationModel medication) async {
    final _storage = GetStorage();
    // استرجاع إعداد "نبهني قبل انتهاء صلاحية الدواء"
    int? selectedExpiryReminderDays = _storage.read('expiry_reminder_days') ?? 3;

    if (medication.expiryDate == null) {
      return false; // إذا كان تاريخ الصلاحية غير موجود
    }

    final daysUntilExpiry = medication.expiryDate!.difference(DateTime.now()).inDays;

    // إذا كانت الأيام المتبقية أقل من أو تساوي الأيام المحددة في الإعدادات
    return daysUntilExpiry <= selectedExpiryReminderDays;
  }

}
