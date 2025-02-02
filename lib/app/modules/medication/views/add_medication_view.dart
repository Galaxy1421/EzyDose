import 'dart:convert';
import 'dart:math' as math;
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import 'package:reminder/app/data/data_resources/remote_reminder_data_source.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/new_interaction_model.dart';
import 'package:reminder/app/data/models/time_unit.dart';
import 'package:reminder/app/data/services/new_interaction_service.dart';
import 'package:reminder/app/modules/medications_schedule/views/medications_schedule_view.dart';
import 'package:reminder/excel_search.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/models/reminder_frequency_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/services/routine_service.dart';
import '../../../data/services/interaction_service.dart';
import '../../../data/models/interaction_model.dart';
import '../controllers/add_medication_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:excel/excel.dart' as ex;
class AddMedicationView extends GetView<AddMedicationController> {
  const AddMedicationView({Key? key}) : super(key: key);

  // todo AddMedicationView
  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              RawScrollbar(
                controller: controller,
                thumbColor: Colors.grey.shade600,
                thickness: 4,
                thumbVisibility: true,
                crossAxisMargin: 3,
                radius: Radius.circular(10),
                padding: EdgeInsets.only(top: 50,),
                child: ListView(
                  controller: controller,
                  children: [
                    _buildBody(),
                    _buildRemindersTab(),
                    const SizedBox(height: 20,),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MediaQuery.of(context).viewInsets.bottom > 0
                    ? SizedBox.shrink()  // إخفاء الزر عندما يكون الكيبورد مفتوحًا
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                  ),
                  padding: const EdgeInsets.all(10),
                  child: _buildSaveButton(),
                ),
              )
,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildErrorMessage({required RxBool showErrorFlag, required String errorMessage, double top = 0}) {
    return Obx(() => showErrorFlag.value
        ? Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: top),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      // fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }


  Future<List<MedicineModelDataSet>> readExcelData() async {
    final ByteData data = await rootBundle.load('assets/dataSet/Medicines Dataset2.xlsx');
    final Uint8List bytes = data.buffer.asUint8List();
    final ex.Excel excel = ex.Excel.decodeBytes(bytes);

    List<MedicineModelDataSet> medicines = [];

    var sheet = excel.tables['sheet1 (2)'];

    if (sheet != null) {
      for (var row in sheet.rows) {
        if (row.length >= 13) { // التأكد من أن الصف يحتوي على بيانات كافية
          medicines.add(MedicineModelDataSet(
            atcCode1: row[0]?.value.toString(), // العمود 1: AtcCode1
            tradeName: row[1]?.value.toString(), // العمود 2: Trade Name
            constraint: row[2]?.value.toString(), // العمود 3: constraint
            atcCode1Interact: row[3]?.value.toString(), // العمود 4: AtcCode1 Interact
            timingGap1: row[4]?.value.toString(), // العمود 5: timing gap1 (in minutes)
            atcCode2Interact: row[5]?.value.toString(), // العمود 6: AtcCode2 Interact
            timingGap2: row[6]?.value.toString(), // العمود 7: timing gap2 (in minutes)
            major: row[7]?.value.toString(), // العمود 8: Major
            moderate: row[8]?.value.toString(), // العمود 9: Moderate
            minor: row[9]?.value.toString(), // العمود 10: Minor
            packageSize: row[10]?.value.toString(), // العمود 11: PackageSize
            unit: row[11]?.value.toString(), // العمود 12: Unit
            photoLink: row[12]?.value.toString(), // العمود 13: Photo Link
          ));
        }
      }
    } else {
      print("Sheet 'sheet1 (2)' not found!");
    }

    print("Medicines: $medicines"); // طباعة القائمة للتأكد من البيانات
    return medicines;
  }

  Future<List<MedicineModelDataSet>> getFakeRequestData(String query) async {
    List<MedicineModelDataSet> data = await readExcelData();

    return await Future.delayed(const Duration(seconds: 1), () {
      return data.where((medicine) {
        String? tradeName = medicine.tradeName?.toLowerCase();
        return tradeName != null &&
            tradeName != "trade name" && // استبعاد اسم العمود
            tradeName.contains(query.toLowerCase());
      }).toList();
    });
  }

  // TODO :: Widget _buildBody
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomDropdownExample(),
                  if(false)
                  ElevatedButton(onPressed: (){
                    print(controller.medicationsSchedule?.length);

                    Get.to(()=>MedicationScheduleView(schedule: controller.medicationsSchedule!));
                  }, child: Text('MedicationScheduleView')),
                  if(false)
                  ElevatedButton(onPressed: ()async{
                    Get.lazyPut(() => RemoteReminderDatSourceImpl());

                    // await controller.fetchAllReminders();//
                    //  print(controller.listFetchAllReminders!.length.toString());
                    //
                    //  if(controller.listFetchAllReminders!=null){
                    //    controller.listFetchAllReminders!.forEach((e){
                    //      print("\n\n============================================\n\n");
                    //
                    //      print("tradeName : ${e.medicineModelDataSet?.tradeName.toString()}");
                    //      print("atcCode1 : ${e.medicineModelDataSet?.atcCode1.toString()}");
                    //      print("atcCode1Interact : ${e.medicineModelDataSet?.atcCode1Interact.toString()}");
                    //      print("atcCode2Interact : ${e.medicineModelDataSet?.atcCode2Interact.toString()}");
                    //      print("timingGap1 : ${e.medicineModelDataSet?.timingGap1.toString()}");
                    //      print("timingGap2 : ${e.medicineModelDataSet?.timingGap2.toString()}");
                    //      print("unit : ${e.medicineModelDataSet?.unit.toString()}");
                    //      print("packageSize : ${e.medicineModelDataSet?.packageSize.toString()}");
                    //      print("minor : ${e.medicineModelDataSet?.minor.toString()}");
                    //      print("moderate : ${e.medicineModelDataSet?.moderate.toString()}");
                    //      print("major : ${e.medicineModelDataSet?.major.toString()}");
                    //      print("constraint : ${e.medicineModelDataSet?.constraint.toString()}");
                    //
                    //      print("\n\n============================================\n\n");
                    //    });
                    //  }

                    //=================


                    // إنشاء دواء جديد
                    MedicationModel newMedication = MedicationModel(
                      id: "1",
                      name: "GLUCOPHAGE 1 g tablet",
                      medicineModelDataSet: MedicineModelDataSet(
                        atcCode1: "A10BA02",
                        atcCode1Interact: "A10AE04",
                        atcCode2Interact: "A10AD06",
                        timingGap1: "30",
                        timingGap2: "60",
                        tradeName: "GLUCOPHAGE",//
                      ), totalQuantity: 30,
                      doseQuantity: 30,
                      unit: 'Pills'
                    );

                    // جلب التذكيرات من Firebase (هذا مثال بسيط)
                    controller.listFetchAllReminders = [
                      ReminderModel(
                        id: "1",
                        medicineModelDataSet: MedicineModelDataSet(
                          atcCode1: "A10AE04",
                          tradeName: "LANTUS SOLOSTAR",
                        ), dateTime: DateTime.now(),type: ReminderType.afterBreakfast,
                      ),
                      ReminderModel(
                        id: "2",
                        medicineModelDataSet: MedicineModelDataSet(
                          atcCode1: "A10AD06",
                          tradeName: "RYZODEG FlexTouch",
                        ),
                          dateTime: DateTime.now(),type: ReminderType.afterBreakfast
                      ),
                    ];

                    // التحقق من التفاعلات وعرض الرسائل التنبيهية
                    await controller.checkAndShowInteractions(Get.context!, newMedication);
                  }, child: Text("get all reminders from firestore")),

                  // ElevatedButton(onPressed: (){
                  //   NewInteractionChecker.showN(Get.context!);
                  // }, child: Text("show Dialog")),
                  // Text(
                  //   'medication_name'.tr,
                  //   style: GoogleFonts.poppins(
                  //     color: Colors.black87,
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  _buildSectionTitle('medication_name'.tr, Icons.medication),
                  const SizedBox(height: 8),
                  CustomDropdown.searchRequest(
                    futureRequest: getFakeRequestData,
                    hintBuilder: (context, hint, enabled) {
                      return Text(
                        hint,
                        style: const TextStyle(color: Colors.black),
                      );
                    },
                    hintText: 'please_enter_medication_name'.tr,

                    decoration: CustomDropdownDecoration(
                      overlayScrollbarDecoration: ScrollbarThemeData(thumbVisibility: WidgetStatePropertyAll(true), thickness: WidgetStatePropertyAll(2),
                      thumbColor: WidgetStatePropertyAll(Colors.lightBlue),
                        crossAxisMargin: 2,
                      ),
                        searchFieldDecoration: SearchFieldDecoration(hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal,fontSize: 14,height: 1.5)),
                        headerStyle: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,),
                        hintStyle: TextStyle(color: Colors.grey)),
                    onChanged: (value) {
                      if (value != null) {

                        controller.selectedMedicineModelDataSet.value = value;
                        controller.nameController.text = value.tradeName??'';
                        controller.medication.value.atcCode1 = value.atcCode1??'';
                        controller.medication.value.name = value.tradeName??'';
                        controller.medication.value.unit = value.unit??'';

                        controller.medication.value.atcCode1Interact = value.atcCode1Interact??'';
                        controller.medication.value.atcCode2Interact = value.atcCode2Interact??'';
                        controller.medication.value.timingGap1 = value.timingGap1??'';
                        controller.medication.value.timingGap2 = value.timingGap2??'';
                        controller.medication.value.major = value.major??'';
                        controller.medication.value.moderate = value.moderate??'';
                        controller.medication.value.minor = value.minor??'';



                        controller.medication.value.unit = value.unit??'';


                        controller.nameController.text = value.tradeName!;
                        controller.totalQuantityController.text = value.packageSize.toString();
                        String packageSize = value.packageSize!;
                        String numericValue = packageSize.replaceAll(RegExp(r'[^0-9]'), '');

                        controller.totalQuantityController.text = numericValue;
                        // controller.prescriptionController.text = value.constraint??'';
                        controller.unitController.text = value.unit??'';

                        controller.medication.value.imageUrl = value.photoLink??'';
                        print("Selected Medicine: ${value.tradeName}");
                        print("ATC Code 1: ${value.atcCode1}");
                        print("Constraint: ${value.constraint}");
                        print("Photo Link: ${value.photoLink}");
                        // controller.update();
                        if(controller.nameController.text.isNotEmpty&&controller.showErrorEnterMedicationName.isTrue){
                          controller.showErrorEnterMedicationName.value = false;
                        }
                         if(controller.totalQuantityController.text.isNotEmpty&&controller.showErrorEnterMedicationQuantity.isTrue){
                          controller.showErrorEnterMedicationQuantity.value = false;
                        }

                      }
                    },
                    controller: controller.medicineCtrl,

                    searchHintText: 'Medicine name',
                    futureRequestDelay: const Duration(seconds: 3),

                    // itemToString: (item) {
                    //   return item.tradeName ?? 'No Trade Name';
                    // },
                    listItemBuilder: (context, item, isSelected, isHovered) {
                      return ListTile(
                        // leading:

                        leading: item.photoLink != null
                            ? CachedNetworkImage(
                          imageUrl: item.photoLink!,
                          width: 50, // عرض الصورة
                          height: 50, // ارتفاع الصورة
                          fit: BoxFit.cover, // تغطية المساحة المحددة
                          placeholder: (context, url) => const CircularProgressIndicator(), // مؤشر تحميل أثناء جلب الصورة
                          errorWidget: (context, url, error) => const Icon(
                            Icons.medication,
                            size: 50,
                            color: Colors.grey, // إذا فشل تحميل الصورة، نعرض أيقونة بديلة
                          ),
                        )
                            : const Icon(
                          Icons.medication,
                          size: 50,
                          color: Colors.grey, // أيقونة افتراضية عند عدم وجود رابط صورة
                        ),
                        // إذا لم يكن هناك رابط صورة
                        title: Text(item.tradeName ?? 'No Trade Name'),
                        subtitle: Container(
                          // color: Colors.red,
                            child: Text("ATC Code: ${item.atcCode1 ?? 'No ATC Code'}",
                              style: TextStyle(fontSize: 12,color: Colors.blueGrey),textAlign: TextAlign.start,)),
                      );
                    },
                  ),
                  // const SizedBox(height: 12),
                  // _buildMedicationNameField(),
                  const SizedBox(height: 12),

                  // if(controller.showErrorEnterMedicationName.value)
                  // Container(
                  //   height: 30,
                  //   margin: EdgeInsets.symmetric(horizontal: 10),
                  //   decoration: BoxDecoration(
                  //     color: Colors.red,
                  //     borderRadius: BorderRadius.circular(10)
                  //   ),
                  // ),

                  // Obx(()=>      (controller.showErrorEnterMedicationName.value)?            Container(
                  //   height: 30,
                  //   margin: EdgeInsets.symmetric(horizontal: 10),
                  //   decoration: BoxDecoration(
                  //       color: Colors.red,
                  //       borderRadius: BorderRadius.circular(10)
                  //   ),
                  // ):SizedBox.shrink()),

                  buildErrorMessage(showErrorFlag: controller.showErrorEnterMedicationName, errorMessage: 'please_enter_medication_name'.tr),

                  _buildOptionalMedicationNameField(),
                  const SizedBox(height: 24),
                  _buildMedicationImage(),
                  const SizedBox(height: 10),

                  _buildQuantityFields(),

                  const SizedBox(height: 24),
                  _buildExpiryDateField(),
                  buildErrorMessage(showErrorFlag: controller.showErrorEnterExpiryDate, errorMessage: 'please_enter_expiry_date'.tr,top: 12),

                  if(controller.selectedMedicineModelDataSet.value!=null)...[

                    const SizedBox(height: 12),
                  _buildSectionTitle(Get.locale?.languageCode == 'ar'?'تعليمات':'Constraint', Icons.info_outline),
                  const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white, // لون الخلفية
                        borderRadius: BorderRadius.circular(15), // زوايا مدورة
                        border: Border.all(
                          color: Colors.transparent, // بدون حدود
                          width: 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1), // ظل خفيف
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // اتجاه الظل
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ), //
                      child: Text(
                        controller.selectedMedicineModelDataSet.value!.constraint?.toString() ??
                            (AppHelper.isArabic ? 'لا توجد تعليمات' : 'No instructions available'),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      )
                      ,
                    ),

                    const SizedBox(height: 12),
                    _buildSectionTitle(Get.locale?.languageCode == 'ar'?'وحدة الدواء':'Medication Unit', CupertinoIcons.capsule),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white, // لون الخلفية
                        borderRadius: BorderRadius.circular(15), // زوايا مدورة
                        border: Border.all(
                          color: Colors.transparent, // بدون حدود
                          width: 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1), // ظل خفيف
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // اتجاه الظل
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ), //
                      child: Text(
                        controller.selectedMedicineModelDataSet.value!.unit?.toString() ??
                            (AppHelper.isArabic ? 'غير محدد' : 'Not specified'),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,//
                          fontSize: 16,
                        ),
                      )
                      ,
                    ),

                  ],
                  const SizedBox(height: 24),

                  _buildPrescriptionSection(),
                  const SizedBox(height: 24),
                  _buildInteractionsSection(),
                  const SizedBox(height: 24),
                  _buildFrequencySelector(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // todo :: _buildRemindersTab
  Widget _buildRemindersTab() {
    return Column(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('reminders'.tr, Icons.alarm),
                const SizedBox(height: 32),
                _buildUserShouldDoSection(),
                const SizedBox(height: 16),
                _buildReminderTypeGrid(),
                const SizedBox(height: 16),
                _buildCustomTimeButton(),
                const SizedBox(height: 16),
                _buildNewRemindersList(),
                const SizedBox(height: 32),
                // _buildSaveButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserShouldDoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Obx(() {
        return Text(
          AppHelper.isArabic
              ? ' يجب عليك تحديد ${controller.repeatedDays.value}  لتذكيرات تناول الدواء'
              : 'You need to set ${controller.repeatedDays.value} reminders for medication intake.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal,height: 2,fontSize: 15 ),
        );

        // return Text(
        //   'من المفترض عليك ان  ${controller.repeatedDays.value} ${'reminders'.tr}',
        //   style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
        // );
      })),
    );
  }

  Widget _buildReminderTypeGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildReminderTypeCard(ReminderType.wakeUp, 'wake_up'.tr, Icons.wb_sunny),
        _buildReminderTypeCard(ReminderType.beforeBreakfast, 'before_breakfast'.tr, Icons.arrow_upward),
        _buildReminderTypeCard(ReminderType.afterBreakfast, 'after_breakfast'.tr, Icons.arrow_downward),
        _buildReminderTypeCard(ReminderType.beforeLunch, 'before_lunch'.tr, Icons.arrow_upward),
        _buildReminderTypeCard(ReminderType.afterLunch, 'after_lunch'.tr, Icons.arrow_downward),
        _buildReminderTypeCard(ReminderType.beforeDinner, 'before_dinner'.tr, Icons.arrow_upward),
        _buildReminderTypeCard(ReminderType.afterDinner, 'after_dinner'.tr, Icons.arrow_downward),
        _buildReminderTypeCard(ReminderType.bedtime, 'bedtime'.tr, Icons.nightlight),
      ],
    );
  }

  Widget _buildReminderTypeCard(ReminderType type, String label, IconData icon) {
    return Obx(() {
      final bool isSelected = controller.reminders.any((r) => r.type == type);
      return InkWell(
        onTap: () {
          // تحقق من طول القائمة مقارنة بقيمة repeatCountController
          final int maxReminders = int.tryParse(controller.repeatCountController.text) ?? 0;

          if (!isSelected && controller.reminders.length >= maxReminders) {

            SnackbarService().showWarning("alert_message_repeat_limit".tr);
            return;
          }

          // todo :: controller.newInteractions.clear();
          controller.newInteractions.clear();
          if (isSelected) {
            controller.removeReminder(controller.reminders.indexWhere((r) => r.type == type));
          } else {
            controller.addReminder(TimeOfDay.now(), type: type);
          }
          // if (isSelected) {
          //   controller.removeReminder(controller.reminders.indexWhere((r) => r.type == type));
          // } else
          //   controller.addReminder(TimeOfDay.now(), type: type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primary : AppColors.textLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.removeReminder(controller.reminders.indexWhere((r) => r.type == type));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCustomTimeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final TimeOfDay? time = await showTimePicker(
            context: Get.context!,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {


          
            final int maxReminders = int.tryParse(controller.repeatCountController.text) ?? 0;

            if ( controller.reminders.length >= maxReminders) {

              SnackbarService().showWarning("alert_message_repeat_limit".tr);
              return;
            }


            //==================
            controller.onTimeSelected(time);
          }
        },
        icon: const Icon(
          Icons.access_time,
          color: Colors.white,
        ),
        label: Text(
          'custom_time'.tr,
          style: TextStyle(color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          // side: BorderSide(color: Get.theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildNewRemindersList() {
    return Obx(() {
      if (controller.reminders.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'no_reminders_added_yet'.tr,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.reminders.length,
        itemBuilder: (context, index) {
          final reminder = controller.reminders[index];
          return _buildReminderItem(reminder);
        },
      );
    });
  }

  Widget _buildReminderItem(ReminderModel reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.alarm,
          color: AppColors.primary,
        ),
        title: Text(
          controller.getReminderStatusText(reminder.getCurrentState()),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          controller.getFormattedReminderTime(reminder.dateTime),
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => controller.removeReminder(
            controller.reminders.indexOf(reminder),
          ),
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  // TODO :: _buildSaveButton
  Widget _buildSaveButton() {
    return InkWell(
      onTap: controller.isEditing.value ? controller.onUpdatePressed : controller.onSavePressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            controller.isEditing.value ? 'update'.tr : 'save'.tr,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Obx(() {
          return Text(
            (controller.isEditing.value ? 'edit_medication'.tr : 'add_medication'.tr),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          );
        }));
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            controller.isEditing.value ? 'update_medication_details'.tr : 'add_new_medication'.tr,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // todo Widget _buildMedicationNameField
  Widget _buildMedicationNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'medication_name'.tr,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final suggestions = controller.searchResults;
          return Column(
            children: [
              _buildInputContainer(
                child: TextFormField(
                  controller: controller.nameController,
                  onChanged: controller.onSearchChanged,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                  // validator: (value){
                  //   if (value == null || value.isEmpty) {
                  //     return 'please_enter_medication_name'.tr; // الرسالة عند وجود خطأ
                  //   }
                  //   return null;
                  // },
                  decoration: _buildInputDecoration(
                    'enter_medication_name'.tr,
                    Icons.search_rounded,
                  ),
                ),
              ),
              if (suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: suggestions.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final medication = suggestions[index];

                        return Column(
                          children: [
                            if (index > 0)
                              Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                              ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              onTap: () {
                                controller.onMedicationSelected(medication);
                              },
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: medication.imageUrl == null
                                    ? Icon(
                                        Icons.medication,
                                        color: AppColors.primary,
                                        size: 24,
                                      )
                                    : Image.asset(medication.imageUrl!),
                              ),
                              title: Text(
                                medication.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                medication.instructions,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget buildRepeatTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Column(
          children: [
            _buildInputContainer(
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')), // السماح بالأرقام فقط (غير سالبة)
                ],
                // onChanged: (value) => controller.repeatedDays(int.parse(value)??1),
                onChanged: (value) {
                  // تحقق أن القيمة ليست فارغة
                  if (value.isNotEmpty) {
                    controller.repeatedDays(int.parse(value));
                  } else {
                    controller.repeatedDays(1); // يمكنك تحديد القيمة الافتراضية هنا
                  }
                  controller.showErrorEnterRepeatTime.value = false;
                },
                controller: controller.repeatCountController,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                ),
                decoration: _buildInputDecoration(
                  'enter_repeat_times'.tr,
                  Icons.numbers,
                ),
              ),
            ),

            buildErrorMessage(showErrorFlag: controller.showErrorEnterRepeatTime, errorMessage: 'please_enter_repeat_time'.tr),

          ],
        )
      ],
    );
  }

  Widget _buildOptionalMedicationNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'medication_optional_name'.tr,
        //   style: GoogleFonts.poppins(
        //     color: Colors.black87,
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        _buildSectionTitle('medication_optional_name'.tr, Icons.medication),

        const SizedBox(height: 8),
        Obx(() {
          final suggestions = controller.searchResults;
          return Column(
            children: [
              _buildInputContainer(
                child: TextField(
                  controller: controller.optionalNameController,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                  decoration: _buildInputDecoration(
                    'enter_medication_optional_name'.tr,
                    Icons.medication,
                  ),
                ),
              ),
              if (suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: suggestions.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final medication = suggestions[index];

                        return Column(
                          children: [
                            if (index > 0)
                              Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                              ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              onTap: () {
                                controller.onMedicationSelected(medication);
                              },
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: medication.imageUrl == null
                                    ? Icon(
                                        Icons.medication,
                                        color: AppColors.primary,
                                        size: 24,
                                      )
                                    : Image.asset(medication.imageUrl!),
                              ),
                              title: Text(
                                medication.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                medication.instructions,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMedicationImage() {
    return Obx(() {
      final imageUrl = controller.medication.value.imageUrl;
      if (imageUrl == null || imageUrl.isEmpty) return SizedBox.shrink();

      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Center(
              child: Icon(
                Icons.medication,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMedicationImage2() {
    return Obx(() {
      final imageUrl = controller.medication.value.imageUrl;
      if (imageUrl == null) return SizedBox.shrink();

      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.medication,
                  size: 64,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildQuantityFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('quantity'.tr, Icons.format_list_numbered),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildInputContainer(
              child: TextFormField(
                controller: controller.totalQuantityController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.showErrorEnterMedicationQuantity.value = false;
                },
                decoration: _buildInputDecoration('total_quantity'.tr, Icons.medication_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'quantity_required'.tr;
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'please_enter_valid_number'.tr;
                  }
                  return null;
                },
              ),
            ),
            // const SizedBox(height: 8),
            buildErrorMessage(
                showErrorFlag: controller.showErrorEnterMedicationQuantity, errorMessage: 'please_enter_medication_quantity'.tr, top: 12),

            const SizedBox(height: 12),
            _buildSectionTitle('dose_amount'.tr, Icons.ac_unit_rounded),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     _buildSectionTitle('dose_amount'.tr, Icons.ac_unit_rounded),
            //     // InkResponse(child: Icon(Icons.question_mark,color: Colors.grey,))
            //
            //     InkResponse(
            //       onTap: (){
            //         controller.showHintDoseAmount.value = !controller.showHintDoseAmount.value;
            //
            //         Future.delayed(const Duration(seconds: 10),(){
            //           controller.showHintDoseAmount.value = false;
            //         });
            //
            //         },
            //       child: CircleAvatar(
            //         radius: 9,
            //         child: Transform(
            //           alignment: Alignment.center,
            //           transform: Directionality.of(Get.context!) == TextDirection.rtl
            //               ? Matrix4.rotationY(math.pi) // يعكس الأيقونة للغة العربية
            //               : Matrix4.identity(),        // يحتفظ بالشكل الأصلي للغة الإنجليزية
            //           child: Icon(
            //             Icons.question_mark,
            //             color: Colors.grey,
            //             size: 15,
            //           ),
            //         ),
            //       ),
            //     ),
            //     Obx(()=>AnimatedOpacity(
            //       duration: new Duration(milliseconds: 500),
            //       opacity: controller.showHintDoseAmount.value?1:0,
            //       child: Container(
            //         margin: EdgeInsets.symmetric(horizontal: 4),
            //         child: Text('كم مرة تتناول هذا الدواء',style: TextStyle(
            //             fontSize: 11,
            //             color: Colors.grey.shade700
            //         ),),
            //       ),
            //     )
            //     )
            //     // Container(
            //     //   margin: EdgeInsets.symmetric(horizontal: 4),
            //     //   child: Text('كم مرة تتناول هذا الدواء',style: TextStyle(
            //     //     fontSize: 11,
            //     //     color: Colors.grey.shade400
            //     //   ),),
            //     // )
            //
            //   ],
            // ),
            const SizedBox(height: 12),
            _buildInputContainer(
              child: TextFormField(
                controller: controller.doseQuantityController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.showErrorEnterDoseQuantity.value = false;
                },
                decoration: _buildInputDecoration('dose_amount'.tr, Icons.local_hospital_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required'.tr;
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'invalid'.tr;
                  }
                  return null;
                },
              ),
            ),

            buildErrorMessage(showErrorFlag: controller.showErrorEnterDoseQuantity, errorMessage: "please_enter_dose_quantity".tr, top: 12),
          ],
        ),
      ],
    );
  }

  // TODO :: Widget _buildExpiryDateField()
  Widget _buildExpiryDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('expiry_date'.tr, Icons.event),
        const SizedBox(height: 12),
        _buildInputContainer(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now().add(const Duration(days: 1)), // يبدأ من الغد
                firstDate: DateTime.now().add(const Duration(days: 1)), // يمنع اختيار أي تاريخ قبل اليوم
                lastDate: DateTime.now().add(const Duration(days: 3650)), // الحد الأقصى للتاريخ بعد 10 سنوات
              );
              // final _storage = GetStorage();
              //
              // int? selectedExpiryReminderDays = _storage.read('expiry_reminder_days') ?? 3;
              // print("controller.selectedExpiryReminderDays.value ${selectedExpiryReminderDays}");
              // final firstDate = DateTime.now().add(Duration(days: selectedExpiryReminderDays));
              //
              // final date = await showDatePicker(
              //   context: Get.context!,
              //   initialDate: firstDate, // يبدأ من التاريخ بناءً على الإعداد
              //   firstDate: firstDate, // يمنع اختيار أي تاريخ قبل القيمة المحددة
              //   lastDate: DateTime.now().add(const Duration(days: 3650)), // الحد الأقصى بعد 10 سنوات
              // );

              if (date != null) {
                controller.expiryDate.value = date;
                controller.showErrorEnterExpiryDate.value = false;
              }
            },
            child: Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        controller.expiryDate.value != null
                            ? '${controller.expiryDate.value!.day}/${controller.expiryDate.value!.month}/${controller.expiryDate.value!.year}'
                            : 'select_expiry_date'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: controller.expiryDate.value != null ? AppColors.text : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }


  Widget _buildPrescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('prescription'.tr, Icons.description),
        const SizedBox(height: 12),
        _buildInputContainer(
          child: TextFormField(
            controller: controller.prescriptionController,
            minLines: 5,
            maxLines: 10,
            decoration: _buildInputDecoration('prescription'.tr, Icons.description),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrescriptionImagePicker(),
      ],
    );
  }

  Widget _buildPrescriptionImagePicker() {
    return Obx(() {
      final hasImage = controller.prescriptionImageRx.value.isNotEmpty;
      return Column(
        children: [
          if (hasImage)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(controller.prescriptionImageRx.value),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: () => controller.prescriptionImageRx.value = '',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  final base64Image = base64Encode(bytes);
                  controller.prescriptionImageRx.value = base64Image;
                  controller.hasPrescription.value = true;
                }
              },
              icon: Icon(
                hasImage ? Icons.edit : Icons.add_photo_alternate,
                color: Colors.white,
              ),
              label: Text(
                hasImage ? 'change_prescription_image'.tr : 'add_prescription_image'.tr,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInteractionsSection() {
    Get.put(NewInteractionService());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('interactions'.tr, Icons.warning_amber_rounded),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            // final interactions = controller.newInteractions;
            final newInteractions = controller.newInteractions;
            if (newInteractions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'no_interactions'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final newInteractionService = Get.find<NewInteractionService>();
          
  controller.medicationsSchedule= newInteractionService.findOptimalSchedule(controller.reminders,controller.listFetchAllReminders??[]);
  final schedule = controller.medicationsSchedule??{};
// final schedule = newInteractionService.findOptimalSchedule(controller.reminders,controller.listFetchAllReminders!);

            print("Generated schedule: $schedule");
            print("controller.existingMedications ${controller.existingMedications}");
            print("controller.toMedication() ${controller.toMedication()}");
            // todo :: call _buildInteractionItem
            return Column(
              children: newInteractions.map((interaction) => _buildInteractionItem(interaction, schedule)).toList(),
            );
          }),
        ),
      ],
    );
  }
  Widget _buildInteractionItem(NewInteractionModel interaction, Map<String, List<DateTime>> schedule) {
    final recommendedTimes = schedule[interaction.medicationName] ?? [];

    // تحديد اللون بناءً على نوع التفاعل
    Color interactionColor;
    String interactionDisplayName;
    switch (interaction.interactionType) {
      case 'Major':
        interactionColor = Colors.red;
        interactionDisplayName = 'High Risk';
        break;
      case 'Moderate':
        interactionColor = Colors.orange;
        interactionDisplayName = 'Moderate Risk';
        break;
      case 'Minor':
        interactionColor = Colors.yellow;
        interactionDisplayName = 'Low Risk';
        break;
      default:
        interactionColor = Colors.green;
        interactionDisplayName = 'No Risk';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: interactionColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interaction.medicationName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: interactionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interactionDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: interactionColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              interaction.description ?? 'No description available.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            if (recommendedTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'recommended_times'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Wrap(
                spacing: 8,
                children: recommendedTimes
                    .map(
                      (time) => Chip(
                    label: Text(
                      intl.DateFormat('hh:mm a').format(time),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildInteractionItem2(InteractionModel interaction, Map<String, List<DateTime>> schedule) {
    final recommendedTimes = schedule[interaction.medicationName] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: interaction.riskLevel.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interaction.medicationName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: interaction.riskLevel.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interaction.riskLevel.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: interaction.riskLevel.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              interaction.description,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            if (recommendedTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'recommended_times'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Wrap(
                spacing: 8,
                children: recommendedTimes
                    .map(
                      (time) => Chip(
                        label: Text(
                          intl.DateFormat('hh:mm a').format(time),
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildInputContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  // todo :: Create a function to customize the design of text input fields (TextFormField) using a hint and an icon.
// This function is used to standardize the styling of text input fields across the app.
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade400,
        fontSize: 16,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }

  // todo _buildFrequencySelector
  Widget _buildFrequencySelector() {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Obx(() => Column(
          crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.start,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 24,
                    color: AppColors.primary,),
                  const SizedBox(width: 10,),
                  Text(
                    'frequency'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            buildRepeatTime(),
            const SizedBox(height: 12),
            Obx(() {
              return Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.selectedReminderFrequency.value = ReminderFrequency.daily;
                        print("ReminderFrequency.daily");//
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: controller.selectedReminderFrequency.value == ReminderFrequency.daily ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controller.selectedReminderFrequency.value == ReminderFrequency.daily ? AppColors.primary : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: controller.selectedReminderFrequency.value == ReminderFrequency.daily
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: controller.selectedReminderFrequency.value == ReminderFrequency.daily ? Colors.white : Colors.grey.shade800,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'daily'.tr,
                              style: GoogleFonts.poppins(
                                color: controller.selectedReminderFrequency.value == ReminderFrequency.daily ? Colors.white : Colors.grey.shade800,
                                fontWeight:
                                    controller.selectedReminderFrequency.value == ReminderFrequency.daily ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.selectedReminderFrequency.value = ReminderFrequency.custom;

                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: controller.selectedReminderFrequency.value == ReminderFrequency.custom ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controller.selectedReminderFrequency.value == ReminderFrequency.custom ? AppColors.primary : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: controller.selectedReminderFrequency.value == ReminderFrequency.custom
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: controller.selectedReminderFrequency.value == ReminderFrequency.custom ? Colors.white : Colors.grey.shade800,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'custom'.tr,
                              style: GoogleFonts.poppins(
                                color: controller.selectedReminderFrequency.value == ReminderFrequency.custom ? Colors.white : Colors.grey.shade800,
                                fontWeight:
                                    controller.selectedReminderFrequency.value == ReminderFrequency.custom ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (controller.selectedReminderFrequency.value == ReminderFrequency.custom) ...[
              const SizedBox(height: 24),
              Text(
                'repeat_ech'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controller.repeatEveryController,
                      keyboardType: TextInputType.number,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: 'number'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<TimeUnit>(
                        value: controller.selectedTimeUnit.value,
                        isExpanded: true,
                        alignment: isArabic ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                        underline: const SizedBox(),
                        items: TimeUnit.values
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  alignment: isArabic ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                                  child: Text(
                                    unit.name.tr,
                                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedTimeUnit.value = value;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 24),
              // Obx(() {
              //   return Text(
              //     '${controller.getCustomFrequencyDescription()}'.tr,
              //     style: GoogleFonts.poppins(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.grey.shade800,
              //     ),
              //     textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              //   );
              // }),
              // const SizedBox(height: 12),
              // Row(
              //   textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              //   children: [
              //     Expanded(
              //       flex: 2,
              //       child: TextField(
              //         onChanged: (value) => controller.repeatedDays(int.parse(value)),
              //         keyboardType: TextInputType.number,
              //         textAlign: isArabic ? TextAlign.right : TextAlign.left,
              //         textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              //         decoration: InputDecoration(
              //           hintText: 'number'.tr,
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12),
              //             borderSide: BorderSide(color: Colors.grey.shade300),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       flex: 3,
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              //         decoration: BoxDecoration(
              //           border: Border.all(color: Colors.grey.shade300),
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         child: Text(
              //           'days'.tr,
              //           textAlign: isArabic ? TextAlign.right : TextAlign.left,
              //           style: GoogleFonts.poppins(
              //             fontSize: 16,
              //             color: Colors.grey.shade800,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ],
        ));
  }
}
