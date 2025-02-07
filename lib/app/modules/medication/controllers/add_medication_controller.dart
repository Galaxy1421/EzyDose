import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import 'package:reminder/app/data/data_resources/remote_reminder_data_source.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/new_interaction_model.dart';
import 'package:reminder/app/data/models/reminder_frequency_model.dart';
import 'package:reminder/app/data/usecases/reminder/get_all_reminders_by_medcations_id_usecase.dart';
import 'package:reminder/app/modules/dashboard/controllers/custom_reminder_controller.dart';
import 'package:reminder/app/modules/medications/controllers/custom_medication_contoller.dart';
import 'package:reminder/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/interaction_model.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/reminder_state.dart';
import '../../../data/models/reminder_status.dart';
import '../../../data/models/time_unit.dart';
import '../../../data/sample/sample_data.dart';
import '../../../data/services/interaction_service.dart';
import '../../../data/services/medication_service.dart';
import '../../../data/services/routine_service.dart';
import '../../../data/services/settings_service.dart';
import '../../../services/custom_interaction_service.dart';
import '../../../services/custom_schulder_service.dart';

class AddMedicationController extends GetxController {
  final _logger = Logger();
  final _uuid = const Uuid();
  final _settingsService = Get.find<SettingsService>();
  final _scheduleService = Get.find<ScheduleService>();

  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final prescriptionController = TextEditingController();
  final optionalNameController = TextEditingController();
  final instructionsController = TextEditingController();
  final doseQuantityController = TextEditingController();
  final totalQuantityController = TextEditingController();
  final unitController = TextEditingController();
  final prescriptionDetailsController = TextEditingController();
  final customDaysController = TextEditingController();

  // Custom frequency controllers
  final selectedTimeUnit = TimeUnit.day.obs;
  TextEditingController repeatEveryController = TextEditingController(text: '0');
  TextEditingController repeatCountController = TextEditingController(text: '0');
  RxInt repeatedDays = RxInt(0);

  // Observable values
  final medicationId = RxString(Uuid().v4());
  final selectedReminderFrequency = ReminderFrequency.daily.obs;
  final selectedDays = RxList<bool>.filled(7, false); // Sunday to Saturday
  final hasPrescription = false.obs;
  final prescriptionImageRx = RxString('');
  final medicationImageRx = RxString('');
  final selectedExpiryDate = Rx<DateTime?>(null);
  final newReminders = <ReminderModel>[].obs;
  final interactions = <InteractionModel>[].obs;
  final newInteractions = <NewInteractionModel>[].obs;
  final selectedUnit = 'pills'.obs;
  final reminders = <ReminderModel>[].obs;
  final selectedReminderType = ReminderType.custom.obs;
  final searchResults = <MedicationModel>[].obs;
  final selectedMedication = Rx<MedicationModel?>(null);
  final selectedMedicationImage = Rx<String?>(null);
  final existingMedications = <MedicationModel>[].obs;
  final isLoading = false.obs;
  final expiryDate = Rx<DateTime?>(null);
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final notificationsEnabled = true.obs;
  final selectedTime = Rx<TimeOfDay>(TimeOfDay.now());
  final medication = Rx<MedicationModel>(MedicationModel(
    id: '',
    name: '',
    totalQuantity: 0,
    doseQuantity: 1,
    unit: 'pills',
    hasPrescription: false,
    prescriptionImage: '',
    instructions: '',
  ));
  final medicationToEdit = Rx<MedicationModel?>(null);
  RxBool isEditing = false.obs;

  // RxBool showHintDoseAmount = false.obs;
  // Observable values for expiry and quantity reminders
  final selectedExpiryReminderDays = 7.obs;
  final selectedQuantityReminderDays = 7.obs;

  // List of available days options
  final expiryReminderOptions = [3, 7, 14, 30];
  final quantityReminderOptions = [3, 7, 14, 30];

  final isGeneratingReminders = false.obs;

  final selectedCustomFrequency = Rx<MedicationFrequency>(MedicationFrequency.daily);
  final selectedCustomDays = RxSet<int>({1, 2, 3, 4, 5, 6, 7});

  String _generateId() => _uuid.v4();

  final CustomReminderController _customReminderController = Get.find();
  final CustomMedicationController _customMedicationController = Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    customDaysController.text = '1'; // Default value
    // _loadExistingMedications();

    // Set default unit
    if (medication.value.unit.isEmpty) {
      medication.value.unit = 'tablets';
    }

    if (Get.arguments != null) {
      final med = Get.arguments as MedicationModel;
      medicationToEdit.value = med;
      isEditing(true);
      loadMedication(med);
    } else {
      isEditing(false);
    }

    // Listen to medication name changes to set default reminders
    nameController.addListener(_updateDefaultReminders);
    fetchAllReminders();
  }

  void _initializeControllers() {
    nameController.addListener(_updateMedicationName);
    doseQuantityController.addListener(_updateDoseQuantity);
    instructionsController.addListener(_updateInstructions);
    prescriptionDetailsController.addListener(_updatePrescription);
  }

  void _updateMedicationName() {
    medication.update((val) {
      if (val != null) {
        val.name = nameController.text;
      }
    });
  }

  void _updateDoseQuantity() {
    medication.update((val) {
      if (val != null) {
        val.doseQuantity = int.tryParse(doseQuantityController.text) ?? 1;
      }
    });
  }

  void _updateInstructions() {
    medication.update((val) {
      if (val != null) {
        val.instructions = instructionsController.text;
      }
    });
  }

  void _updatePrescription() {
    medication.update((val) {
      if (val != null) {
        val.prescriptionText = prescriptionDetailsController.text;
        val.hasPrescription = prescriptionDetailsController.text.isNotEmpty || (prescriptionImageRx.value.isNotEmpty);
      }
    });
  }

  void _updateDefaultReminders() {
    final medicationName = nameController.text.toLowerCase();

    // Only set default reminders if there are no existing reminders
    if (reminders.isEmpty) {
      switch (medicationName) {
        case String name when name.contains('lisinopril'):
          instructionsController.text =
              'take_10mg_once_daily_on_an_empty_stomach_at_least_1_hour_before_meals_take_with_a_full_glass_of_water_avoid_salt_substitutes_containing_potassium'
                  .tr;
          selectedUnit.value = 'tablets'.tr;
          break;

        case String name when name.contains('metformin'):
          instructionsController.text =
              'take_500mg_twice_daily_with_meals_to_minimize_stomach_upset_take_with_food_to_reduce_gastrointestinal_side_effects_stay_well_hydrated_throughout_the_day'
                  .tr;
          selectedUnit.value = 'tablets'.tr;
          break;
      }
    }
  }

  void loadMedication(MedicationModel med) async {
    // Update text controllers (this will trigger their respective listeners)
    isLoading(true);
    nameController.text = med.name;
    optionalNameController.text = med.optionalName;
    instructionsController.text = med.instructions ?? '';
    doseQuantityController.text = med.doseQuantity.toString();
    interactions.assignAll(med.interactions);
    newInteractions.assignAll(med.newInteractions);
    totalQuantityController.text = med.totalQuantity.toString();
    prescriptionDetailsController.text = med.prescriptionText ?? '';

    medication(med);
    List<ReminderModel> oldReminders = await GetAllRemindersByMedicationsIdUseCase(repository: Get.find()).call(medication.value.id);
    selectedReminderFrequency.value = oldReminders.first.frequency!.type;
    repeatEveryController.text = oldReminders.first.frequency!.repeatEvery.toString();
    repeatCountController.text = oldReminders.first.frequency!.repeatEveryNumber.toString();
    repeatedDays();
    selectedTimeUnit.value = oldReminders.first.frequency!.repeatEveryUnit;

    reminders.addAll(oldReminders);

    update();
    isLoading(false);
  }

  void loadMedicationForEdit(MedicationModel med) {
    nameController.text = med.name;
    instructionsController.text = med.instructions;
    totalQuantityController.text = med.totalQuantity.toString();
    doseQuantityController.text = med.doseQuantity.toString();
    unitController.text = med.unit;
    expiryDate.value = med.expiryDate;
    // if (med.expiryDate != null) {
    //   expiryDateController.text = med.expiryDate.toString();
    // }
    medication.value.imageUrl = med.imageUrl;
    // selectedPrescriptionImage.value = med.prescriptionImage;
    interactions.assignAll(med.interactions);
    newInteractions.assignAll(med.newInteractions);
    medicationToEdit.value = med;
  }

  void resetMedication() {
    medication.value = MedicationModel(
      name: '',
      instructions: '',
      doseQuantity: 1,
      totalQuantity: 0,
      unit: 'pills',
      hasPrescription: false,
      id: '',
    );

    // Reset controllers
    nameController.clear();
    doseQuantityController.clear();
    instructionsController.clear();
    prescriptionDetailsController.clear();
    // quantityController.clear();

    // Reset other values
    // selectedFrequency.value = ReminderFrequency.daily;
    selectedReminderType.value = ReminderType.custom;
    selectedTime.value = TimeOfDay.now();
    selectedDays.value = List.filled(7, false);
    prescriptionImageRx.value = '';
    medicationImageRx.value = '';
  }

  @override
  void onClose() {
    nameController.removeListener(_updateDefaultReminders);
    nameController.removeListener(_updateMedicationName);
    doseQuantityController.removeListener(_updateDoseQuantity);
    instructionsController.removeListener(_updateInstructions);
    prescriptionDetailsController.removeListener(_updatePrescription);

    nameController.dispose();
    doseQuantityController.dispose();
    instructionsController.dispose();
    prescriptionDetailsController.dispose();
    customDaysController.dispose();

    // medication.reset();
    // selectedReminderTypes.clear();
    super.onClose();
  }

  Future<void> addReminder(TimeOfDay time, {ReminderType type = ReminderType.custom}) async {
    try {
      // Only check for duplicates on non-custom reminders
      if (type != ReminderType.custom && reminders.any((r) => r.type == type)) {
        // Get.snackbar(
        //   'Warning',
        //   'A reminder for ${_getReminderTypeText(type)} already exists',
        //   backgroundColor: Colors.orange.withOpacity(0.1),
        //   colorText: Colors.orange[800],
        // );
        SnackbarService().showWarning(
            AppHelper.isArabic
                ? "تذكير لـ ${_getReminderTypeText(type)} موجود بالفعل"
                : "A reminder for ${_getReminderTypeText(type)} already exists"
        );

        return;
      }

      // Get time from settings service for predefined types
      TimeOfDay reminderTime = time;
      if (type != ReminderType.custom) {
        String timeStr;
        switch (type) {
          case ReminderType.wakeUp:
            timeStr = _settingsService.wakeUpTime;
            break;
          case ReminderType.beforeBreakfast:
            timeStr = _settingsService.beforeBreakfastTime;
            break;
          case ReminderType.afterBreakfast:
            timeStr = _settingsService.afterBreakfastTime;
            break;
          case ReminderType.beforeLunch:
            timeStr = _settingsService.beforeLunchTime;
            break;
          case ReminderType.afterLunch:
            timeStr = _settingsService.afterLunchTime;
            break;
          case ReminderType.beforeDinner:
            timeStr = _settingsService.beforeDinnerTime;
            break;
          case ReminderType.afterDinner:
            timeStr = _settingsService.afterDinnerTime;
            break;
          case ReminderType.bedtime:
            timeStr = _settingsService.bedTime;
            break;
          default:
            timeStr = '';
        }

        if (timeStr.isNotEmpty) {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            reminderTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        }
      }

      // Create frequency model
      final frequencyModel = ReminderFrequencyModel(
          type: selectedReminderFrequency.value,
          customDays: Set<DateTime>.from(selectedCustomDays.map((day) {
            final now = DateTime.now();
            return DateTime(now.year, now.month, day);
          })),
          repeatEvery: repeatEveryController.text.isEmpty ? 0 : int.parse(repeatEveryController.text),
          repeatEveryNumber: repeatCountController.text.isEmpty ? 0 : int.parse(repeatCountController.text),
          repeatEveryUnit: selectedTimeUnit.value);

      final reminder = ReminderModel(
        id: _generateId(),
        medicationId: medicationId.value,
        dateTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          reminderTime.hour,
          reminderTime.minute,
        ),
        type: type,
        frequency: frequencyModel,
        statusHistory: [
          ReminderStatus(
            timestamp: DateTime.now(),
            state: ReminderState.pending,
          ),
        ],
      );

      reminders.add(reminder);
      update();
    } catch (e) {
      _logger.e('Error adding reminder', error: e);
      // Get.snackbar(
      //   'Error',
      //   'Failed to create reminder',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red[800],
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في إنشاء التذكير"
              : "Failed to create reminder"
      );

    }
  }

  String _getReminderTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.wakeUp:
        return 'Wake Up';
      case ReminderType.beforeBreakfast:
        return 'Before Breakfast';
      case ReminderType.afterBreakfast:
        return 'After Breakfast';
      case ReminderType.beforeLunch:
        return 'Before Lunch';
      case ReminderType.afterLunch:
        return 'After Lunch';
      case ReminderType.beforeDinner:
        return 'Before Dinner';
      case ReminderType.afterDinner:
        return 'After Dinner';
      case ReminderType.bedtime:
        return 'Bedtime';
      default:
        return type.toString().split('.').last;
    }
  }

  void removeReminder(int index) {
    if (isEditing.value) {
      _customReminderController.deleteReminder(reminders[index]);
    }
    if (index >= 0 && index < reminders.length) {
      reminders.removeAt(index);
      update();
    }
  }

  RxBool showErrorEnterMedicationName = false.obs;
  RxBool showErrorEnterMedicationQuantity = false.obs;

  RxBool showErrorEnterDoseQuantity = false.obs;

  RxBool showErrorEnterExpiryDate = false.obs;
  RxBool showErrorEnterRepeatTime = false.obs;

  final SingleSelectController<MedicineModelDataSet?> medicineCtrl = SingleSelectController<MedicineModelDataSet?>(null);

  final selectedMedicineModelDataSet = Rx<MedicineModelDataSet?>(null);

  List<ReminderModel>? listFetchAllReminders = [];
  Future<void> fetchAllReminders() async {
    try {
      // استدعاء دالة getAllReminders
      List<ReminderModel> reminders = await _remoteReminderDataSource.getAllReminders();

      listFetchAllReminders = reminders??[];
      // طباعة عدد التذكيرات التي تم جلبها
      print('Total reminders fetched: ${reminders.length}');

      // طباعة تفاصيل كل تذكير
      for (final reminder in reminders) {
        print('Reminder ID: ${reminder.id}, Medication ID: ${reminder.medicationId}, Time: ${reminder.dateTime}');
      }
    } catch (e) {
      print('Error fetching reminders: $e');
    }
  }


  Future<void> checkAndShowInteractions(BuildContext context, MedicationModel medication) async {
    if (listFetchAllReminders != null) {
      List<NewInteractionResult> listResult = await NewInteractionChecker.checkInteractions111(medication, reminders,listFetchAllReminders!);

      if (listResult.isNotEmpty) {

        await NewInteractionChecker.showInteractionDialog(context, listResult);
      } else {
        // إذا لم يكن هناك تفاعلات دوائية
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لا توجد تفاعلات دوائية محتملة.")),
        );
      }
    } else {
      // إذا كانت القائمة فارغة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("لا توجد تذكيرات مخزنة.")),
      );
    }
  }

   Map<String, List<DateTime>>? medicationsSchedule ;

  RxBool isInsufficientTimeGap = false.obs;

  // RxList<String>listInsufficientTimeGap = <String>[].obs;
  RxList<InsufficientTimeGap>? listInsufficientTimeGap = <InsufficientTimeGap>[].obs;

  // todo onSavePresse
  Future<void> onSavePressed() async {
    bool isValid = true;
    List<String> errorMessages = []; // قائمة لتخزين الأخطاء

    await fetchAllReminders();
    // تحقق من الحقل الأول (الاسم)
    if (nameController.text.isEmpty) {
      showErrorEnterMedicationName.value = true;
      errorMessages.add("please_enter_medication_name".tr);
      isValid = false;
    } else {
      showErrorEnterMedicationName.value = false;
    }

    // تحقق من الحقل الثاني (الكمية الإجمالية)
    if (totalQuantityController.text.isEmpty) {
      showErrorEnterMedicationQuantity.value = true;
      errorMessages.add("please_enter_medication_quantity".tr);
      isValid = false;
    } else {
      showErrorEnterMedicationQuantity.value = false;
    }

    // تحقق من الحقل الثالث (مقدار الجرعة)
    if (doseQuantityController.text.isEmpty) {
      showErrorEnterDoseQuantity.value = true;
      errorMessages.add("please_enter_dose_quantity".tr);
      isValid = false;
    } else if (int.tryParse(doseQuantityController.text) == null || int.parse(doseQuantityController.text) <= 0) {
      showErrorEnterDoseQuantity.value = true;
      errorMessages.add("invalid_dose_quantity".tr);
      isValid = false;
    } else {
      showErrorEnterDoseQuantity.value = false;
    }

    if (repeatCountController.text.isEmpty) {
      showErrorEnterRepeatTime.value = true;
      errorMessages.add("please_enter_repeat_time".tr);
      isValid = false;
    } else if (int.tryParse(repeatCountController.text) == null || int.parse(repeatCountController.text) <= 0) {
      showErrorEnterRepeatTime.value = true;
      errorMessages.add("please_enter_repeat_time".tr); //
      isValid = false;
    } else {
      showErrorEnterRepeatTime.value = false;
    }


    if (!isValid) {
      SnackbarService().showMultipleErrors(errorMessages); // عرض جميع الأخطاء
      return;
    }
    if (reminders.isEmpty) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // حواف دائرية
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // مسافة داخلية للحوار
            child: Column(
              mainAxisSize: MainAxisSize.min, // لتصغير الحجم بناءً على المحتوى
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.deepOrange, // لون أيقونة المعلومات
                  size: 50,
                ),
                const SizedBox(height: 16), // مسافة بين الأيقونة والنص
                Text(
                  Get.locale?.languageCode == 'ar'
                      ? "يرجى إدخال أوقات تذكيرات تناول الدواء"
                      : "Please enter medication reminder times",
                  style: const TextStyle(
                    fontSize: 16, // حجم النص
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // لون النص
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16), // مسافة بين النص والزر
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // إغلاق مربع الحوار
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent, // لون الزر
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // حواف دائرية
                    ),
                  ),
                  child: Text(
                    Get.locale?.languageCode == 'ar' ? "حسناً" : "OK",
                    style: const TextStyle(
                      color: Colors.white, // لون النص داخل الزر
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      return;
    }
    if (!_validateForm()) return;

    AppDialog.showLoadingDialog();
    try {
      String id = Uuid().v4();
      if (isEditing.value) {
        id = this.medication.value.id;
      }

      final medication = MedicationModel(
          id: id,
          name: selectedMedicineModelDataSet?.value?.tradeName??'medication no name',
          optionalName: optionalNameController.text,
          instructions: instructionsController.text,
          totalQuantity: int.tryParse(selectedMedicineModelDataSet?.value?.packageSize??totalQuantityController.text)?? 0,
          doseQuantity: int.tryParse(doseQuantityController.text) ?? 1,
          unit: selectedMedicineModelDataSet?.value?.unit??selectedUnit.value,
          expiryDate: expiryDate.value,
          customDays: selectedCustomDays,
          hasPrescription: hasPrescription.value,
          prescriptionText: prescriptionDetailsController.text,
          prescriptionImage: prescriptionImageRx.value,
          imageUrl: this.medication.value.imageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          medicineModelDataSet: selectedMedicineModelDataSet.value);

      medication.newInteractions = newInteractions;

     
      if(reminders.isNotEmpty){
        reminders.forEach((e){
          e.medicineModelDataSet = selectedMedicineModelDataSet.value;
        });
      }
      if(listFetchAllReminders!=null) {
        isInsufficientTimeGap.value = false;
        listInsufficientTimeGap?.clear();
      List<NewInteractionResult> interactions = await NewInteractionChecker.checkInteractions111(//
        medication,
        reminders,
        listFetchAllReminders!,
      );//
      print('Number of interactions found: ${interactions.length}');
      for (var interaction in interactions) {
        print('Interaction: ${interaction.medication1.name} و ${interaction.medication2.tradeName}');
        print('Type: ${interaction.interactionType}');
      }
      // إذا كانت هناك تفاعلات دوائية، عرض مربع الحوار
      if (interactions.isNotEmpty) {
        Get.back();
        final shouldContinue = await NewInteractionChecker.showInteractionDialog(Get.context!, interactions);
        if (!shouldContinue) return; // إذا اختار المستخدم عدم المتابعة، نخرج من الدالة
        else
          AppDialog.showLoadingDialog();

      }
    }

      bool shouldSaveMedication = true;

      if(interactions.isEmpty&&listInsufficientTimeGap!=null&&isInsufficientTimeGap.isTrue){
        if(Get.isDialogOpen!){
          Get.back();
        }
        listInsufficientTimeGap?.forEach((e){
          print("newMedicationData : ${e.newMedicationData}");
          print("newMedicationReminder ${e.newMedicationReminder}");
          print("existingMedication ${e.existingMedication}");
          print("existingMedicationReminder ${e.existingMedicationReminder}");
          print("recommendationMessage ${e.recommendationMessage}");
          print("interactionDescription ${e.interactionDescription}");

          print("=====================\n\n\n");

        });
        bool? userResponse = await Get.dialog<bool>(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // حواف دائرية للحوار
            ),
            elevation: 10, // إضافة ظل للحوار
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: MediaQuery.of(Get.context!).size.height * 0.5, // ارتفاع نسبي للحوار
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عنوان الحوار
                    Text(
                      AppHelper.isArabic
                          ? "تنبيه: تفاعلات دوائية أو فجوات زمنية"
                          : "Warning: Drug interactions or time gaps",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800], // لون العنوان
                      ),
                    )
,
                    const SizedBox(height: 16), // مسافة بين العنوان والمحتوى

                    // قائمة التفاعلات أو الفجوات الزمنية
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: listInsufficientTimeGap!.map((g) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12), // مسافة بين العناصر
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100], // لون خلفية العنصر
                                borderRadius: BorderRadius.circular(8), // حواف دائرية
                                border: Border.all(color: Colors.grey[300]!), // إطار خفيف
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // نص التفاعل
                                  Text(
                                    AppHelper.isArabic
                                        ? "تفاعل أو فجوة زمنية غير كافية بين:"
                                        : "Insufficient interaction or time gap between:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  )
,
                                  const SizedBox(height: 4),
                                  Text(
                                    "${g.newMedicationData} و ${g.existingMedication}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // نص التوصية
                                  Text(
                                    g.recommendationMessage ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // أوقات التذكير
                                  // Row(
                                  //   children: [
                                  //     Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                  //     const SizedBox(width: 4),
                                  //     Text(
                                  //       "${g.newMedicationData} reminder: ${g.newMedicationReminder}",
                                  //       style: TextStyle(
                                  //         fontSize: 12,
                                  //         color: Colors.grey[700],
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),

                                  Column(
                                    children: [



                                      Row(
                                        children: [
                                          Icon(Icons.medication, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${g.newMedicationData}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      )
                                      ,
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            "reminder: ${g.newMedicationReminder}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    children: [



                                      Row(
                                        children: [
                                          Icon(Icons.medication, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${g.existingMedication}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      )
,
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            "reminder: ${g.existingMedicationReminder}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // مسافة بين القائمة والأزرار

                    // أزرار الحوار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // لون زر المتابعة
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // لون زر الإلغاء
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ?? false;
        shouldSaveMedication = userResponse;
      }

      if(!shouldSaveMedication)
        return;
      AppDialog.showLoadingDialog();
      _customMedicationController.addMedication(medication);

      // Schedule reminders with notifications and torch
      for (final reminder in reminders) {
        reminder.medicationId = id;
        reminder.id == Uuid().v4();
        reminder.frequency!.repeatEvery = int.tryParse(repeatEveryController.text) ?? 1;
        reminder.frequency!.repeatEveryNumber = int.tryParse(repeatCountController.text) ?? 1;
        reminder.frequency!.repeatEveryUnit = selectedTimeUnit.value;
        reminder.frequency!.type = selectedReminderFrequency.value;
        reminder.frequency!.customDays = reminder.frequency!.generateDays();
        if (optionalNameController.text.isNotEmpty) {
          reminder.medicationName = optionalNameController.text;
        } else {
          reminder.medicationName = nameController.text;
        }
        reminder.medicineModelDataSet = selectedMedicineModelDataSet.value;
        _customReminderController.addReminder(reminder);


        String name  = '';
        if(medication.optionalName.isEmpty&&medication.name.isNotEmpty){
          name = medication.name;
        }
        else if(medication.optionalName.isNotEmpty){
          name = medication.optionalName;
        }
        else{
          name = medication.medicineModelDataSet?.tradeName??'Unknow';
        }
        await _scheduleService.scheduleReminder(
          reminder,
          'time_for_medication2'.trParams({
            'name': name,
          }),
          'take_medication_instructions'.trParams({
            'doseQuantity': medication.doseQuantity.toString(),
            'unit': medication.unit,
            'name': name,
            'instructions': medication.instructions,
          }),
          useTorch: true, // Enable torch for all reminders
        );


      }
      Get.back();
      Get.offAllNamed(Routes.INITIAL);
    } catch (e) {
      Get.back();
     
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في حفظ الدواء: ${e.toString()}"
              : "Failed to save medication: ${e.toString()}"
      );

    }
  }

  final RemoteReminderDataSource _remoteReminderDataSource = Get.put(RemoteReminderDatSourceImpl());



  // todo onUpdatePressed
  Future<void> onUpdatePressed() async {
    bool isValid = true;
    List<String> errorMessages = []; // قائمة لتخزين الأخطاء
await fetchAllReminders();
    // تحقق من الحقل الأول (الاسم)
    if (nameController.text.isEmpty) {
      showErrorEnterMedicationName.value = true;
      errorMessages.add("please_enter_medication_name".tr);
      isValid = false;
    } else {
      showErrorEnterMedicationName.value = false;
    }

    // تحقق من الحقل الثاني (الكمية الإجمالية)
    if (totalQuantityController.text.isEmpty) {
      showErrorEnterMedicationQuantity.value = true;
      errorMessages.add("please_enter_medication_quantity".tr);
      isValid = false;
    } else {
      showErrorEnterMedicationQuantity.value = false;
    }

    // تحقق من الحقل الثالث (مقدار الجرعة)
    if (doseQuantityController.text.isEmpty) {
      showErrorEnterDoseQuantity.value = true;
      errorMessages.add("please_enter_dose_quantity".tr);
      isValid = false;
    } else if (int.tryParse(doseQuantityController.text) == null || int.parse(doseQuantityController.text) <= 0) {
      showErrorEnterDoseQuantity.value = true;
      errorMessages.add("invalid_dose_quantity".tr);
      isValid = false;
    } else {
      showErrorEnterDoseQuantity.value = false;
    }

    // إذا كانت هناك أخطاء، سيتم عرضها دفعة واحدة
    if (!isValid) {
      SnackbarService().showMultipleErrors(errorMessages); // عرض جميع الأخطاء
      return;
    }
    if (!_validateForm()) return;

    try {
      // Generate new medication ID if not exists
      // if (medicationId.value.isEmpty) {
      String id = Uuid().v4();
      if (isEditing.value) {
        id = this.medication.value.id;
      }
      // }

      // Create medication model
      final medication = MedicationModel(
        id: id,
        name: nameController.text,
        optionalName: optionalNameController.text,
        instructions: instructionsController.text,
        totalQuantity: int.tryParse(totalQuantityController.text) ?? 0,
        doseQuantity: int.tryParse(doseQuantityController.text) ?? 1,
        unit: selectedUnit.value,
        expiryDate: expiryDate.value,
        customDays: selectedCustomDays,
        hasPrescription: hasPrescription.value,
        prescriptionText: prescriptionDetailsController.text,
        prescriptionImage: prescriptionImageRx.value,
        imageUrl: this.medication.value.imageUrl,
        medicineModelDataSet: this.selectedMedicineModelDataSet.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      medication.interactions = interactions;


      if (listFetchAllReminders != null){
        List<NewInteractionResult> interactions = await NewInteractionChecker.checkInteractions111(
          medication,
          reminders,
          listFetchAllReminders!,
        );
//
      // إذا كانت هناك تفاعلات دوائية، عرض مربع الحوار
      if (interactions.isNotEmpty) {
        final shouldContinue = await NewInteractionChecker.showInteractionDialog(Get.context!, interactions);
        if (!shouldContinue) return; // إذا اختار المستخدم عدم المتابعة، نخرج من الدالة
      }
    }
      _customMedicationController.updateMedication(medication);

      // Schedule reminders with notifications and torch
      for (final reminder in reminders) {
        reminder.medicationId = id;
        reminder.frequency!.repeatEvery = int.tryParse(repeatEveryController.text) ?? 1;
        reminder.frequency!.repeatEveryNumber = int.tryParse(repeatCountController.text) ?? 1;
        reminder.frequency!.repeatEveryUnit = selectedTimeUnit.value;
        reminder.frequency!.type = selectedReminderFrequency.value;
        reminder.frequency!.customDays = reminder.frequency!.generateDays();
        if (optionalNameController.text.isNotEmpty) {
          reminder.medicationName = optionalNameController.text;
        } else {
          reminder.medicationName = nameController.text;
        }
        //frequny

        _customReminderController.addReminder(reminder);

        // Schedule notification with torch for each reminder time
        await _scheduleService.scheduleReminder(
          reminder,
          'Time for ${medication.name}',
          'Take ${medication.doseQuantity} ${medication.unit} of ${medication.name}\n${medication.instructions}',
          useTorch: true, // Enable torch for all reminders
        );
      }

      Get.offAllNamed(Routes.INITIAL);
    } catch (e) {
     
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في حفظ الدواء: ${e.toString()}"
              : "Failed to save medication: ${e.toString()}"
      );

    }
  }

  

  Widget _buildTimeRow(String label, DateTime time, Color color) {
    final timeStr = Get.locale?.languageCode == 'ar'
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          timeStr,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ReminderFrequencyModel? getFrequencyModel() {
    // if (selectedMedicationFrequency.value == MedicationFrequency.daily) {
    //   return ReminderFrequencyModel.daily();
    // }

    return null;
    // return ReminderFrequencyModel.custom(
    //   // repeatNumber: int.tryParse(repeatNumberController.text) ?? 1,
    //   // repeatUnit: TimeUnit.day,  // Always days for repeat unit
    //   // durationNumber: int.tryParse(durationNumberController.text) ?? 1,
    //   // durationUnit: selectedTimeUnit.value,
    // );
  }

  void onTimeSelected(TimeOfDay time) {
    addReminder(time);
  }

  bool _validateForm() {
    // if (!formKey.currentState!.validate()) return false;

    if (selectedReminderFrequency.value == MedicationFrequency.custom) {
      // Validate custom days
      final days = int.tryParse(customDaysController.text);
      if (days == null || days <= 0) {
        
        SnackbarService().showError(
          'please_enter_valid_days'.tr,
        );

        return false;
      }
    }

    return true;
  }

  void resetForm() {
    nameController.clear();
    instructionsController.clear();
    doseQuantityController.clear();
    prescriptionDetailsController.clear();
  }

  MedicationModel toMedication() {
    final days = selectedDays
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => DateTime(
              DateTime.now().year,
              DateTime.now().month,
              e.key + 1,
            ))
        .toList();

    return MedicationModel(
      id: medication.value.id,
      name: nameController.text,
      optionalName: optionalNameController.text,
      totalQuantity: int.tryParse(totalQuantityController.text) ?? 0,
      doseQuantity: int.tryParse(doseQuantityController.text) ?? 1,
      unit: selectedUnit.value,
      instructions: instructionsController.text,
      interactions: medication.value.interactions,
      //

      newInteractions: newInteractions,
      medicineModelDataSet: selectedMedicineModelDataSet.value,
      //
      hasPrescription: hasPrescription.value,
      prescriptionText: prescriptionDetailsController.text,
      prescriptionImage: prescriptionImageRx.value,
      imageUrl: medicationImageRx.value,
      expiryDate: expiryDate.value,
      createdAt: medication.value.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> editMedication() async {
    if (formKey.currentState!.validate()) {
      try {
        // Cancel existing reminders first
        // for (final reminder in medicationToEdit.value!.reminders) {
        //   await _notificationService.cancelReminder(reminder.id);
        // }
        //
        // final medicationModel = toMedication();
        //
        // await _medicationService.updateMedication(medicationModel);
        //
        // // Schedule new reminders
        // for (final reminder in reminders) {
        //   await _notificationService.scheduleReminder(reminder);
        // }

        Get.back(result: true);
        // Get.snackbar(
        //   'success'.tr,
        //   'medication_updated'.tr,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        SnackbarService().showSuccess(
          'medication_updated'.tr,
        );

      } catch (e) {
        // Get.snackbar(
        //   'error'.tr,
        //   'error_updating_medication'.tr,
        // );
        SnackbarService().showError(
          'error_updating_medication'.tr,
        );

      }
    }
  }



  // Reminder status helpers
  Color getReminderStatusColor(ReminderState state) {
    switch (state) {
      case ReminderState.taken:
        return Colors.green;
      case ReminderState.missed:
        return Colors.red;
      case ReminderState.skipped:
        return Colors.orange;
      case ReminderState.pending:
        return Colors.blue;
    }
  }

  String getReminderStatusText(ReminderState state) {
    switch (state) {
      case ReminderState.taken:
        return 'Taken';
      case ReminderState.missed:
        return 'Missed';
      case ReminderState.skipped:
        return 'Skipped';
      case ReminderState.pending:
        return 'Pending';
    }
  }

  IconData getReminderStatusIcon(ReminderState state) {
    switch (state) {
      case ReminderState.taken:
        return Icons.check_circle;
      case ReminderState.missed:
        return Icons.cancel;
      case ReminderState.skipped:
        return Icons.skip_next;
      case ReminderState.pending:
        return Icons.schedule;
    }
  }

  String getFormattedReminderTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  void toggleDay(int index) {
    selectedDays.value[index] = !selectedDays.value[index];
    selectedDays.refresh();
  }

  List<int> getSelectedDayIndices() {
    return selectedDays.asMap().entries.where((e) => e.value).map((e) => e.key + 1).toList();
  }

  String get selectedDaysDescription {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedIndices = selectedDays.asMap().entries.where((e) => e.value).map((e) => days[e.key]).toList();

    if (selectedIndices.isEmpty) return 'No days selected';
    if (selectedIndices.length == 7) return 'Every day';
    return selectedIndices.join(', ');
  }

  // Prescription image handling
  Future<void> pickPrescriptionImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        prescriptionImageRx.value = base64Encode(bytes);
      }
    } catch (e) {
      Logger().e('Error picking prescription image: $e');
    }
  }

  // Medication search
  // todo:: onSearchChanged
  void onSearchChanged(String value) {
    if (value.isEmpty) {
      searchResults.clear();

      return;
    }
    showErrorEnterMedicationName.value = false;
    final results = SampleData.getSampleMedications().where((med) => med.name.toLowerCase().contains(value.toLowerCase())).toList();
    searchResults.value = results;
  }

  void onMedicationSelected(MedicationModel medication) {
    selectedMedication.value = medication;

    // Basic information
    medicationId.value = medication.id;
    nameController.text = medication.name;
    instructionsController.text = medication.instructions;
    doseQuantityController.text = medication.doseQuantity.toString();
    totalQuantityController.text = medication.totalQuantity.toString();
    selectedUnit.value = medication.unit;

    // Prescription information
    hasPrescription.value = medication.hasPrescription;
    if (medication.prescriptionText?.isNotEmpty ?? false) {
      prescriptionDetailsController.text = medication.prescriptionText!;
    }
    if (medication.prescriptionImage?.isNotEmpty ?? false) {
      prescriptionImageRx.value = medication.prescriptionImage!;
    }

    // Images
    // if (medication.imageUrl?.isNotEmpty ?? false) {
    this.medication.value.imageUrl = medication.imageUrl!;
    // }

    // Interactions
    interactions.value = medication.interactions;
    newInteractions.value = medication.newInteractions;


    // Clear search results
    searchResults.clear();

    // Show success message
    // Get.snackbar(
    //   'Medication Selected',
    //   'Loaded ${medication.name} data successfully',
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 1),
    // );
    SnackbarService().showSuccess(
      AppHelper.isArabic
          ? "تم تحميل بيانات ${medication.name} بنجاح"
          : "Loaded ${medication.name} data successfully",
    );

  }

  // Frequency management
  void updateReminderFrequency(ReminderFrequency frequency) {
    // selectedFrequency.value = frequency;
  }

  String getFrequencyLabel(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.custom:
        return 'Custom';
      default:
        return 'Unknown';
    }
  }

  void onReminderTypeSelected(ReminderType type) {
    final routineService = Get.find<RoutineService>();
    final routine = routineService.getRoutine();

    if (routine == null) {
      // Get.snackbar(
      //   'Error',
      //   'Please set up your daily routine first',
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "يرجى إعداد روتينك اليومي أولاً"
              : "Please set up your daily routine first"
      );

      return;
    }

    TimeOfDay? selectedTime;

    switch (type) {
      case ReminderType.wakeUp:
        selectedTime = _parseTimeString(routine.wakeUpTime);
        break;
      case ReminderType.beforeBreakfast:
        selectedTime = (_parseTimeString(routine.breakfastTime));
        break;
      case ReminderType.afterBreakfast:
        selectedTime = (_parseTimeString(routine.breakfastTime));
        break;
      case ReminderType.beforeLunch:
        selectedTime = (_parseTimeString(routine.lunchTime));
        break;
      case ReminderType.afterLunch:
        selectedTime = (_parseTimeString(routine.lunchTime));
        break;
      case ReminderType.beforeDinner:
        selectedTime = (_parseTimeString(routine.dinnerTime));
        break;
      case ReminderType.afterDinner:
        selectedTime = (_parseTimeString(routine.dinnerTime));
        break;
      case ReminderType.bedtime:
        selectedTime = _parseTimeString(routine.bedTime);
        break;
      default:
        break;
    }

    if (selectedTime != null) {
      addReminder(selectedTime, type: type);
    }
  }

  TimeOfDay? _parseTimeString(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  TimeOfDay? _adjustTime(TimeOfDay? time, Duration offset) {
    if (time == null) return null;
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final adjustedDateTime = dateTime.add(offset);
    return TimeOfDay(hour: adjustedDateTime.hour, minute: adjustedDateTime.minute);
  }

  void updateReminderType(ReminderType type) {
    selectedReminderType.value = type;
  }

  void onExpiryReminderDaysChanged(int days) {
    selectedExpiryReminderDays.value = days;
    medication.update((val) {
      if (val != null) {
        val.expiryReminderDays = days;
      }
    });
  }

  void onQuantityReminderDaysChanged(int days) {
    selectedQuantityReminderDays.value = days;
    medication.update((val) {
      if (val != null) {
        val.quantityReminderDays = days;
      }
    });
  }

  void setCustomFrequency(MedicationFrequency frequency) {
    selectedCustomFrequency.value = frequency;
    selectedCustomDays.clear();

    // Update the medication model with the custom frequency
    medication.update((val) {
      if (val != null) {
        val.customFrequency = frequency;
        val.customDays = {};
      }
    });
  }

  void toggleCustomDay(int day) {
    if (selectedCustomDays.contains(day)) {
      selectedCustomDays.remove(day);
    } else {
      selectedCustomDays.add(day);
    }

    // Update the medication model with the selected days
    medication.update((val) {
      if (val != null) {
        val.customDays = selectedCustomDays;
      }
    });
  }

  String getCustomFrequencyDescription() {
    // if (selectedFrequency.value != ReminderFrequency.custom) {
    //   return 'daily'.tr;
    // }

    return 'every'.tr + ' ${repeatEveryController.text} ${selectedTimeUnit.value.name.tr}' + ' repeat'.tr + ' ';
  }

  Future<void> loadReminders(MedicationModel med) async {
    try {
      final reminders = await _customReminderController.reminders.where((p0) => p0.medicationId == medicationId.value).toList();

      // Convert existing reminders to TimeOfDay for frequency handling
      final times = reminders.map((r) => TimeOfDay(hour: r.dateTime.hour, minute: r.dateTime.minute)).toList();

      // Clear existing reminders
      newReminders.clear();

      // Create new reminders based on frequency
      if (times.isNotEmpty) {
        for (final time in times) {
          final reminder = ReminderModel(
            id: _generateId(),
            medicationId: medicationId.value,
            medicationName: medication.value.name,
            dateTime: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              time.hour,
              time.minute,
            ),
            type: med.frequency == MedicationFrequency.daily ? ReminderType.custom : ReminderType.custom,
            statusHistory: [
              ReminderStatus(
                timestamp: DateTime.now(),
                state: ReminderState.pending,
              ),
            ],
            frequency: ReminderFrequencyModel(
                type: selectedReminderFrequency.value,
                customDays: {},
                repeatEvery: int.parse(repeatEveryController.text),
                repeatEveryUnit: selectedTimeUnit.value,
                repeatEveryNumber: int.parse(repeatCountController.text)),
          );

          newReminders.add(reminder);
        }
      }
    } catch (e) {
      _logger.e('Error loading reminders: $e');
    }
  }

  Future<List<ReminderModel>> _checkAndAdjustInteractions(List<ReminderModel> newReminders) async {
    try {
      final savedMedications = await _customMedicationController.medications;

      // Create a list with current medication and saved ones
      final allMedications = <MedicationModel>[medication.value];
      if (savedMedications != null) {
        allMedications.addAll(savedMedications!);
      }
      return newReminders;
    } catch (e) {
      _logger.e('Error checking interactions: $e');
      return newReminders;
    }
  }

  void onSave() async {
    try {
      // Check for interactions before saving
      final adjustedReminders = await _checkAndAdjustInteractions(reminders);

      if (adjustedReminders != reminders) {
        // If reminders were adjusted, update them
        reminders.value = adjustedReminders;

        // Show success message
        // Get.snackbar(
        //   'success'.tr,
        //   'reminders_adjusted'.tr,
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green[100],
        // );

        SnackbarService().showSuccess(
          'reminders_adjusted'.tr,
        );

      }

      // TODO: Save the reminders
      Get.back();
    } catch (e) {
      // Get.snackbar(
      //   'error'.tr,
      //   'error_saving_reminders'.tr,
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      SnackbarService().showError(
        'error_saving_reminders'.tr,
      );
    }
  }
}

class InsufficientTimeGap{
  String? newMedicationData;
  String? existingMedication;
  String? recommendationMessage;
  String? interactionDescription;
  String? newMedicationReminder;
  String? existingMedicationReminder;
  InsufficientTimeGap({this.newMedicationData,this.existingMedication,this.recommendationMessage,this.interactionDescription,this.newMedicationReminder,this.existingMedicationReminder});
}