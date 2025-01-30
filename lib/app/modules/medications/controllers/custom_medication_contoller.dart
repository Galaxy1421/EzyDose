import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:reminder/app/data/usecases/medication/add_medication_usecase.dart';
import 'package:reminder/app/data/usecases/medication/delete_medication_usecase.dart';
import 'package:reminder/app/data/usecases/medication/get_all_medications_usecase.dart';
import 'package:reminder/app/data/usecases/medication/update_medication_usecase.dart';
import 'package:reminder/app/data/models/medication_model.dart';

import '../../../data/models/reminder_model.dart';

class CustomMedicationController extends GetxController {
  final AddMedicationUseCase _addMedicationUseCase;
  final UpdateMedicationUseCase _updateMedicationUseCase;
  final DeleteMedicationUseCase _deleteMedicationUseCase;
  final GetAllMedicationsUseCase _getAllMedicationsUseCase;
  final GetMedicationUseCase _getMedicationUseCase;

  CustomMedicationController({
    required AddMedicationUseCase addMedicationUseCase,
    required GetMedicationUseCase getMedicationUseCase,
    required UpdateMedicationUseCase updateMedicationUseCase,
    required DeleteMedicationUseCase deleteMedicationUseCase,
    required GetAllMedicationsUseCase getAllMedicationsUseCase,
  })  : _addMedicationUseCase = addMedicationUseCase,
        _updateMedicationUseCase = updateMedicationUseCase,
        _getMedicationUseCase=getMedicationUseCase,
        _deleteMedicationUseCase = deleteMedicationUseCase,
        _getAllMedicationsUseCase = getAllMedicationsUseCase;

  final RxBool isLoading = false.obs;
  final RxList<MedicationModel> medications = <MedicationModel>[].obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  Rx<MedicationModel?> selectedMedication = Rx<MedicationModel?>(null);

  final nameController = TextEditingController();
  final instructionsController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  final quantityController = TextEditingController();
  final remainingQuantityController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  final RxList<ReminderModel>  reminders = RxList.empty();

  RxInt get currentTab => 0.obs;

  get formKey => null;
  @override
  void onInit() {
    super.onInit();
    getAllMedications();
  }

  Future<void> getAllMedications() async {
    _loadingWrapper(() async {
      final result = await _getAllMedicationsUseCase();
      medications.assignAll(result);
    }, 'Failed to get medications');
  }

  Future<void> addMedication(MedicationModel medication) async {
    await _loadingWrapper(() async {
      await _addMedicationUseCase(medication);
      await getAllMedications();
      _showSuccessDialog('Medication added successfully');
    }, 'Failed to add medication');
  }

  Future<void> updateMedication(MedicationModel medication) async {
    await _loadingWrapper(() async {
      await _updateMedicationUseCase(medication);
      await getAllMedications();
      _showSuccessDialog('Medication updated successfully');
    }, 'Failed to update medication');
  }

  Future<void> deleteMedication(MedicationModel medication) async {
    await _loadingWrapper(() async {
      await _deleteMedicationUseCase(medication);
      await getAllMedications();
      _showSuccessDialog('medication_deleted'.tr);
    }, 'Failed to delete medication');
  }

  Future<void> _loadingWrapper(Future<void> Function() action, String errorMsg) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await action();
    } catch (e) {
      errorMessage.value = '$errorMsg: $e';
      _showErrorDialog(errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }

  // void _showSuccessDialog(String message) {
  //   Get.snackbar(
  //     'Success',
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: Duration(seconds: 3),
  //   );
  // }

  void _showSuccessDialog(String message) {
    Get.snackbar(
      'success'.tr, // العنوان
      message, // الرسالة
      snackPosition: SnackPosition.TOP, // موقع الإشعار
      backgroundColor: Colors.green.withOpacity(0.9), // خلفية نصف شفافة
      colorText: Colors.white, // لون النص
      borderRadius: 12, // الحواف المستديرة
      margin: const EdgeInsets.all(12), // الهامش حول الإشعار
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 28), // أيقونة جميلة
      duration: const Duration(seconds: 3), // مدة العرض
      animationDuration: const Duration(milliseconds: 300), // سرعة الحركة
      isDismissible: true, // السماح بإغلاق الإشعار بالسحب
      forwardAnimationCurve: Curves.easeOutBack, // حركة الدخول
      reverseAnimationCurve: Curves.easeIn, // حركة الخروج
      snackStyle: SnackStyle.FLOATING, // الإشعار العائم
    );
  }

  void _showErrorDialog(String message) {
    Get.snackbar(
      'error'.tr, // العنوان (يتم ترجمته)
      message, // الرسالة
      snackPosition: SnackPosition.BOTTOM, // موقع الإشعار
      backgroundColor: Colors.red.withOpacity(0.9), // لون الخلفية أحمر شفاف لإبراز الخطأ
      colorText: Colors.white, // النص باللون الأبيض لزيادة الوضوح
      borderRadius: 12, // الحواف مستديرة
      margin: const EdgeInsets.all(12), // الهامش حول الإشعار
      icon: const Icon(Icons.error, color: Colors.white, size: 28), // أيقونة خطأ واضحة
      duration: const Duration(seconds: 3), // مدة العرض 3 ثوانٍ
      animationDuration: const Duration(milliseconds: 300), // سرعة الحركة
      isDismissible: true, // السماح بالإغلاق بالسحب
      forwardAnimationCurve: Curves.easeOutBack, // حركة الدخول
      reverseAnimationCurve: Curves.easeIn, // حركة الخروج
      snackStyle: SnackStyle.FLOATING, // النمط العائم
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3), // ظل خفيف للإشعار
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ], // إضافة ظل خفيف
    );
  }

  // void _showErrorDialog(String message) {
  //   Get.snackbar(
  //     'error'.tr,
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: Duration(seconds: 3),
  //     backgroundColor: Get.theme.primaryColor,
  //     colorText: Get.theme.colorScheme.onError,
  //   );
  // }

  void addReminder(ReminderModel reminder) {
    reminders.add(reminder);
  }
  void removeReminder(ReminderModel reminder) {
    reminders.remove(reminder);
  }

}