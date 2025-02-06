import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/data/models/medication_model.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import 'package:reminder/app/modules/medication/controllers/add_medication_controller.dart';
import 'package:uuid/uuid.dart';

class NewInteractionModel {
  final String id;
  final String medicationId; // ID الدواء الأساسي
  final String interactingMedicationId; // ID الدواء المتفاعل
  final String medicationName; // اسم الدواء الأساسي
  final String interactingMedicationName; // اسم الدواء المتفاعل
  final String interactionType; // نوع التفاعل (Major, Moderate, Minor)
  final String? timingGap; // الفجوة الزمنية الموصى بها
  final String? description; // وصف التفاعل
  final String? recommendation; // التوصيات

  NewInteractionModel({
    required this.id,
    required this.medicationId,
    required this.interactingMedicationId,
    required this.medicationName,
    required this.interactingMedicationName,
    required this.interactionType,
    this.timingGap,
    this.description,
    this.recommendation,
  });

  // تحويل JSON إلى NewInteractionModel
  factory NewInteractionModel.fromJson(Map<String, dynamic> json) {
    return NewInteractionModel(
      id: json['id'],
      medicationId: json['medicationId'],
      interactingMedicationId: json['interactingMedicationId'],
      medicationName: json['medicationName'] ?? '',
      interactingMedicationName: json['interactingMedicationName'] ?? '',
      interactionType: json['interactionType'] ?? 'No Interaction',
      timingGap: json['timingGap'],
      description: json['description'],
      recommendation: json['recommendation'],
    );
  }

  // تحويل NewInteractionModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'interactingMedicationId': interactingMedicationId,
      'medicationName': medicationName,
      'interactingMedicationName': interactingMedicationName,
      'interactionType': interactionType,
      'timingGap': timingGap,
      'description': description,
      'recommendation': recommendation,
    };
  }

  // إنشاء نسخة جديدة من النموذج مع تحديث بعض الحقول
  NewInteractionModel copyWith({
    String? id,
    String? medicationId,
    String? interactingMedicationId,
    String? medicationName,
    String? interactingMedicationName,
    String? interactionType,
    String? timingGap,
    String? description,
    String? recommendation,
  }) {
    return NewInteractionModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      interactingMedicationId: interactingMedicationId ?? this.interactingMedicationId,
      medicationName: medicationName ?? this.medicationName,
      interactingMedicationName: interactingMedicationName ?? this.interactingMedicationName,
      interactionType: interactionType ?? this.interactionType,
      timingGap: timingGap ?? this.timingGap,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}

class NewInteractionChecker {
  static Future<List<NewInteractionResult>> checkInteractions(
      MedicationModel newMedication, List<ReminderModel> newReminders, List<ReminderModel> existingReminders) async {
    List<NewInteractionResult> interactions = [];

    // لكل تذكير جديد
    for (var newReminder in newReminders) {
      var newMedicationData = newReminder.medicineModelDataSet;

      // لكل تذكير سابق
      for (var existingReminder in existingReminders) {
        var existingMedication = existingReminder.medicineModelDataSet;

        if (newMedicationData == null || existingMedication == null) {
          continue; // تخطي إذا لم تكن البيانات متوفرة
        }

        // طباعة البيانات للتصحيح
        print('New Medication: ${newMedicationData.tradeName}');
        print('Existing Medication: ${existingMedication.tradeName}');

        // التحقق من التفاعل بناءً على الحقول (minor, moderate, major)
        String interactionType = _determineInteractionType(newMedicationData, existingMedication);

        if (interactionType == "No Interaction") {
          continue; // تخطي إذا لم يكن هناك تفاعل
        }

        // تحليل النطاق الزمني
        final timingGap1 = _parseTimingGap(newMedicationData.timingGap1);
        final timingGap2 = _parseTimingGap(newMedicationData.timingGap2);

        // حساب الفرق الزمني بين التذكير الجديد والتذكير السابق
        // final timeDifference = newReminder.dateTime.difference(existingReminder.dateTime).inMinutes.abs();
// ضبط التاريخ إلى نفس اليوم لتجنب أخطاء الفارق الزمني
        DateTime newTime = DateTime(0, 0, 0, newReminder.dateTime.hour, newReminder.dateTime.minute);
        DateTime existingTime = DateTime(0, 0, 0, existingReminder.dateTime.hour, existingReminder.dateTime.minute);

        final timeDifference = newTime.difference(existingTime).inMinutes.abs();

        // طباعة الفرق الزمني للتصحيح
        print('Time Difference: $timeDifference minutes');

        // **إضافة الشرط الجديد**
        bool isSameTimeOrWithinAnHour = timeDifference <= 60; // أقل من ساعة
        bool isValidTimingGap = (timingGap1 != null && timeDifference < timingGap1) || (timingGap2 != null && timeDifference < timingGap2);

        if (isSameTimeOrWithinAnHour || isValidTimingGap) {
          // إضافة التفاعل إلى القائمة
          final addMedController = Get.find<AddMedicationController>();
          addMedController.newInteractions.clear();

          NewInteractionModel interaction = NewInteractionModel(
            id: Uuid().v4(),
            medicationId: newMedication.id,
            interactingMedicationId: existingReminder.id,
            medicationName: newMedication.name,
            interactingMedicationName: existingMedication.tradeName ?? 'Unknown',
            interactionType: interactionType,
            timingGap: isValidTimingGap ? (timingGap1 != null ? timingGap1.toString() : timingGap2.toString()) : 'غير محدد',
            description: 'تفاعل دوائي بين ${newMedication.name} و ${existingMedication.tradeName}.',
            recommendation: isValidTimingGap
                ? 'يوصى بترك فجوة زمنية قدرها ${isValidTimingGap ? timingGap1 ?? timingGap2 : 'غير محدد'} دقيقة بين الجرعات.'
                : 'التفاعل بسبب تقارب الأوقات، يرجى مراجعة الطبيب لتحديد التوصيات المناسبة.',
          );

          addMedController.newInteractions.add(interaction);

          final bool isArabic = Get.locale?.languageCode == 'ar';

          interactions.add(NewInteractionResult(
            medication1: newMedication,
            medication2: existingMedication,
            newReminder: newReminder,
            existingReminder: existingReminder,
            timingGap1: timingGap1?.toString(),
            timingGap2: timingGap2?.toString(),
            interactionType: interactionType,
            description: interactionType == "Major"
                ? (isArabic
                    ? 'تحذير خطير: هذا التفاعل الدوائي بين ${newMedication.name} و ${existingMedication.tradeName} قد يكون مهددًا للحياة!'
                    : 'Critical Warning: This drug interaction between ${newMedication.name} and ${existingMedication.tradeName} may be life-threatening!')
                : interactionType == "Moderate"
                    ? (isArabic
                        ? 'تنبيه: قد يسبب هذا التفاعل الدوائي بين ${newMedication.name} و ${existingMedication.tradeName} مخاطر صحية متوسطة تتطلب الحذر.'
                        : 'Caution: This drug interaction between ${newMedication.name} and ${existingMedication.tradeName} may pose moderate health risks and requires caution.')
                    : interactionType == "Minor"
                        ? (isArabic
                            ? 'إشعار: هذا التفاعل الدوائي بين ${newMedication.name} و ${existingMedication.tradeName} يعتبر بسيطًا، ولكنه قد يؤثر على فعاليتك اليومية.'
                            : 'Notice: This drug interaction between ${newMedication.name} and ${existingMedication.tradeName} is minor, but it may affect your daily activities.')
                        : (isArabic
                            ? 'تفاعل دوائي بين ${newMedication.name} و ${existingMedication.tradeName}.'
                            : 'Drug interaction detected between ${newMedication.name} and ${existingMedication.tradeName}.'),
            recommendation: interactionType == "Major"
                ? (isArabic
                    ? 'يرجى التوقف عن تناول هذه الأدوية فورًا والتواصل مع طبيبك أو الطوارئ، لأن هذا التفاعل قد يؤدي إلى مخاطر صحية كبيرة!'
                    : 'Please stop taking these medications immediately and contact your doctor or emergency services, as this interaction may lead to serious health risks!')
                : interactionType == "Moderate"
                    ? (isArabic
                        ? 'يرجى استشارة طبيبك لتجنب أي آثار جانبية محتملة نتيجة هذا التفاعل.'
                        : 'Please consult your doctor to avoid any potential side effects caused by this interaction.')
                    : interactionType == "Minor"
                        ? (isArabic
                            ? 'قد لا يكون لهذا التفاعل تأثير كبير، ولكن يُفضل مراقبة حالتك واستشارة طبيبك إذا شعرت بأي أعراض.'
                            : 'This interaction may not have a significant effect, but it is recommended to monitor your condition and consult your doctor if you experience any symptoms.')
                        : isValidTimingGap
                            ? (isArabic
                                ? 'يوصى بترك فجوة زمنية قدرها ${isValidTimingGap ? timingGap1 ?? timingGap2 : 'غير محدد'} دقيقة بين الجرعات.'
                                : 'It is recommended to leave a time gap of ${isValidTimingGap ? timingGap1 ?? timingGap2 : 'undefined'} minutes between doses.')
                            : (isArabic
                                ? 'التفاعل بسبب تقارب الأوقات، يرجى مراجعة الطبيب لتحديد التوصيات المناسبة.'
                                : 'Interaction due to close timing, please consult your doctor for appropriate recommendations.'),
          ));
        }
      }
    }

    return interactions;
  }

//=====================================
//=====================================

  static Future<List<NewInteractionResult>> checkInteractions111(
      MedicationModel newMedication, List<ReminderModel> newReminders, List<ReminderModel> existingReminders) async {
    List<NewInteractionResult> interactions = [];

    final myController = Get.find<AddMedicationController>();
    // لكل تذكير جديد
    for (var newReminder in newReminders) {
      var newMedicationData = newReminder.medicineModelDataSet;

      // لكل تذكير سابق
      for (var existingReminder in existingReminders) {
        var existingMedication = existingReminder.medicineModelDataSet;
// تحليل الفجوات الزمنية

        if (newMedicationData == null || existingMedication == null) {
          continue; // تخطي إذا لم تكن البيانات متوفرة
        }

        // طباعة البيانات للتصحيح
        print('New Medication: ${newMedicationData.tradeName}');
        print('Existing Medication: ${existingMedication.tradeName}');

        // التحقق من التفاعل بناءً على الحقول (minor, moderate, major)
        String interactionType = _determineInteractionType(newMedicationData, existingMedication);

        final timingGap1 = _parseTimingGap(newMedicationData.timingGap1);
        final timingGap2 = _parseTimingGap(newMedicationData.timingGap2);

        // حساب الفرق الزمني بين التذكير الجديد والتذكير السابق
        // final timeDifference = newReminder.dateTime.difference(existingReminder.dateTime).inMinutes.abs();
       // ضبط التاريخ إلى نفس اليوم لتجنب أخطاء الفارق الزمني
        DateTime newTime = DateTime(0, 0, 0, newReminder.dateTime.hour, newReminder.dateTime.minute);
        DateTime existingTime = DateTime(0, 0, 0, existingReminder.dateTime.hour, existingReminder.dateTime.minute);

        final timeDifference = newTime.difference(existingTime).inMinutes.abs();

        print('Time Difference: $timeDifference minutes');

        // التحقق من الفجوة الزمنية حتى في حال "No Interaction"
        bool hasTimingGapIssue = (timingGap1 != null && timeDifference < timingGap1) || (timingGap2 != null && timeDifference < timingGap2);
        bool hasTimingGapIssue2 = timeDifference < 60; // الفجوة الزمنية أقل من ساعة

        if (hasTimingGapIssue&&hasTimingGapIssue2) {
          String recommendationMessage = hasTimingGapIssue
              ? AppHelper.isArabic
              ? 'يرجى ترك فجوة زمنية قدرها ${hasTimingGapIssue && timingGap1 != null ? timingGap1 : timingGap2} دقيقة بين الجرعات لتجنب التأثير على امتصاص الدواء.'
              : 'Please leave a time gap of ${hasTimingGapIssue && timingGap1 != null ? timingGap1 : timingGap2} minutes between doses to avoid affecting drug absorption.'
              : '';

          String interactionDescription = interactionType != "No Interaction"
              ? AppHelper.isArabic
              ? 'تفاعل دوائي بين ${newMedicationData.tradeName} و ${existingMedication.tradeName}.'
              : 'Drug interaction between ${newMedicationData.tradeName} and ${existingMedication.tradeName}.'
              : AppHelper.isArabic
              ? 'لا يوجد تفاعل دوائي مباشر، لكن الفجوة الزمنية غير كافية بين ${newMedicationData.tradeName} و ${existingMedication.tradeName}.'
              : 'No direct drug interaction, but the time gap is insufficient between ${newMedicationData.tradeName} and ${existingMedication.tradeName}.';
//
          // التحقق من وجود البيانات مسبقًا في القائمة
          bool isAlreadyAdded = myController.listInsufficientTimeGap?.any((e) =>
          e.newMedicationData == newMedicationData.tradeName &&
              e.existingMedication == existingMedication.tradeName &&
              e.newMedicationReminder == AppHelper.formatTimeBasedOnLanguage(newReminder.dateTime) &&
              e.existingMedicationReminder == AppHelper.formatTimeBasedOnLanguage(existingReminder.dateTime)) ?? false;

          if (!isAlreadyAdded) {
            myController.isInsufficientTimeGap.value = true;
            myController.listInsufficientTimeGap?.add(new InsufficientTimeGap(
              newMedicationData: newMedicationData.tradeName,
              existingMedication: existingMedication.tradeName,
              recommendationMessage: recommendationMessage,
              interactionDescription: interactionDescription,
              newMedicationReminder: AppHelper.formatTimeBasedOnLanguage(newReminder.dateTime),
              existingMedicationReminder: AppHelper.formatTimeBasedOnLanguage(existingReminder.dateTime),
            ));
          }
        }
        // if (hasTimingGapIssue) {
        //   String recommendationMessage = hasTimingGapIssue
        //       ? 'يرجى ترك فجوة زمنية قدرها ${hasTimingGapIssue && timingGap1 != null ? timingGap1 : timingGap2} دقيقة بين الجرعات لتجنب التأثير على امتصاص الدواء.'
        //       : '';
        //
        //   String interactionDescription = interactionType != "No Interaction"
        //       ? 'تفاعل دوائي بين ${newMedication.name} و ${existingMedication.tradeName}.'
        //       : 'لا يوجد تفاعل دوائي مباشر، لكن الفجوة الزمنية غير كافية بين ${newMedication.name} و ${existingMedication.tradeName}.';
        //
        //   print('Interaction or timing gap detected between ${newMedicationData.tradeName} and ${existingMedication.tradeName}.');
        //
        //   // عرض مربع حوار تحذيري للمستخدم وانتظار استجابته
        //   myController.isInsufficientTimeGap.value = true;
        //   myController.listInsufficientTimeGap?.add(new InsufficientTimeGap(
        //     newMedicationData: newMedicationData.tradeName,
        //     existingMedication: existingMedication.tradeName,
        //     recommendationMessage: recommendationMessage,
        //     interactionDescription: interactionDescription,
        //     newMedicationReminder: AppHelper.formatTimeBasedOnLanguage(newReminder.dateTime),
        //     existingMedicationReminder: AppHelper.formatTimeBasedOnLanguage(existingReminder.dateTime),
        //   ));
        // } // إذا كانت القيمة null نعتبرها false
        if (interactionType == "No Interaction") {
          continue; // تخطي إذا لم يكن هناك تفاعل
        }

        // تحليل النطاق الزمني
        // final timingGap1 = _parseTimingGap(newMedicationData.timingGap1);
        // final timingGap2 = _parseTimingGap(newMedicationData.timingGap2);
        //
        // // حساب الفرق الزمني بين التذكير الجديد والتذكير السابق
        // final timeDifference = newReminder.dateTime.difference(existingReminder.dateTime).inMinutes.abs();

        // طباعة الفرق الزمني للتصحيح
        print('Time Difference: $timeDifference minutes');

        // **إضافة الشرط الجديد**
        bool isSameTimeOrWithinAnHour = timeDifference <= 60; // أقل من ساعة
        bool isValidTimingGap = (timingGap1 != null && timeDifference < timingGap1) || (timingGap2 != null && timeDifference < timingGap2);

        if (isSameTimeOrWithinAnHour || isValidTimingGap) {
          // إضافة التفاعل إلى القائمة
          final addMedController = Get.find<AddMedicationController>();
          addMedController.newInteractions.clear();

          NewInteractionModel interaction = NewInteractionModel(
            id: Uuid().v4(),
            medicationId: newMedication.id,
            interactingMedicationId: existingReminder.id,
            medicationName: newMedication.name,
            interactingMedicationName: existingMedication.tradeName ?? 'Unknown',
            interactionType: interactionType,
            timingGap: isValidTimingGap ? (timingGap1 != null ? timingGap1.toString() : timingGap2.toString()) : 'غير محدد',
            description: 'تفاعل دوائي بين ${newMedication.name} و ${existingMedication.tradeName}.',
            recommendation: isValidTimingGap
                ? 'يوصى بترك فجوة زمنية قدرها ${isValidTimingGap ? timingGap1 ?? timingGap2 : 'غير محدد'} دقيقة بين الجرعات.'
                : 'التفاعل بسبب تقارب الأوقات، يرجى مراجعة الطبيب لتحديد التوصيات المناسبة.',
          );

          addMedController.newInteractions.add(interaction);

          final bool isArabic = Get.locale?.languageCode == 'ar';

          interactions.add(NewInteractionResult(
            medication1: newMedication,
            medication2: existingMedication,
            newReminder: newReminder,
            existingReminder: existingReminder,
            timingGap1: timingGap1?.toString(),
            timingGap2: timingGap2?.toString(),
            interactionType: interactionType,
            description: interactionType == "Major"
                ? (isArabic
                    ? 'تحذير خطير: هذا التفاعل الدوائي بين ${newMedication.name} و ${existingMedication.tradeName} قد يكون مهددًا للحياة!'
                    : 'Critical Warning: This drug interaction between ${newMedication.name} and ${existingMedication.tradeName} may be life-threatening!')
                : interactionType == "Moderate"
                    ? (isArabic
                        ? 'تنبيه: قد يسبب هذا التفاعل الدوائي بين ${newMedication.name} و ${existingMedication.tradeName} مخاطر صحية متوسطة تتطلب الحذر.'
                        : 'Caution: This drug interaction between ${newMedication.name} and ${existingMedication.tradeName} may pose moderate health risks and requires caution.')
                    : interactionType == "Minor"
                        ? (isArabic
                            ? 'إشعار: هذا التفاعل الدوائي بين ${newMedication.name} و ${existingMedication.tradeName} يعتبر بسيطًا، ولكنه قد يؤثر على فعاليتك اليومية.'
                            : 'Notice: This drug interaction between ${newMedication.name} and ${existingMedication.tradeName} is minor, but it may affect your daily activities.')
                        : (isArabic
                            ? 'تفاعل دوائي بين ${newMedication.name} و ${existingMedication.tradeName}.'
                            : 'Drug interaction detected between ${newMedication.name} and ${existingMedication.tradeName}.'),
          /*recommendation: interactionType == "Major"
                ? (isArabic
                    ? 'يرجى التوقف عن تناول هذه الأدوية فورًا والتواصل مع طبيبك أو الطوارئ، لأن هذا التفاعل قد يؤدي إلى مخاطر صحية كبيرة!'
                    : 'Please stop taking these medications immediately and contact your doctor or emergency services, as this interaction may lead to serious health risks!')
                : interactionType == "Moderate"
                    ? (isArabic
                        ? 'يرجى استشارة طبيبك لتجنب أي آثار جانبية محتملة نتيجة هذا التفاعل.'
                        : 'Please consult your doctor to avoid any potential side effects caused by this interaction.')
                    : interactionType == "Minor"
                        ? (isArabic
                            ? 'قد لا يكون لهذا التفاعل تأثير كبير، ولكن يُفضل مراقبة حالتك واستشارة طبيبك إذا شعرت بأي أعراض.'
                            : 'This interaction may not have a significant effect, but it is recommended to monitor your condition and consult your doctor if you experience any symptoms.')
                        : isValidTimingGap
                            ? (isArabic
                                ? 'يوصى بترك فجوة زمنية قدرها ${isValidTimingGap ? timingGap1 ?? timingGap2 : 'غير محدد'} دقيقة بين الجرعات.'
                                : 'It is recommended to leave a time gap of ${isValidTimingGap ? timingGap1 ?? timingGap2 : 'undefined'} minutes between doses.')
                            : (isArabic
                                ? 'التفاعل بسبب تقارب الأوقات، يرجى مراجعة الطبيب لتحديد التوصيات المناسبة.'
                                : 'Interaction due to close timing, please consult your doctor for appropriate recommendations.'),*/
          ));
        }
      }
    }

    return interactions;
  }

//=====================================



 

  static String _determineInteractionType(MedicineModelDataSet? newMedication, MedicineModelDataSet existingMedication) {
    final newAtcCode1 = newMedication?.atcCode1;

    // التحقق من وجود كود ATC للدواء الجديد في أعمدة Major, Moderate, Minor
    if (newAtcCode1 != null) {
      if (existingMedication.major != null && existingMedication.major!.contains(newAtcCode1)) {
        return "Major"; // تفاعل رئيسي
      } else if (existingMedication.moderate != null && existingMedication.moderate!.contains(newAtcCode1)) {
        return "Moderate"; // تفاعل متوسط
      } else if (existingMedication.minor != null && existingMedication.minor!.contains(newAtcCode1)) {
        return "Minor"; // تفاعل ثانوي
      }
    }

    return "No Interaction"; // لا يوجد تفاعل
  }



  static int? _parseTimingGap(String? timingGap) {
    if (timingGap == null || timingGap.isEmpty) {
      return null; // إذا كانت الخلية فارغة
    }

    // تحليل النطاق الزمني (مثل "30-60" أو "120-240")
    final parts = timingGap.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]);
      final max = int.tryParse(parts[1]);
      return max; // نستخدم الحد الأقصى للفجوة الزمنية
    }

    return int.tryParse(timingGap); // إذا كان النطاق الزمني بتنسيق آخر
  }

  static Future<bool> showInteractionDialog(BuildContext context, List<NewInteractionResult> interactions) async {
    final RxList<NewInteractionResult> rxInteractions = interactions.obs;
    final bool isArabic = Get.locale?.languageCode == 'ar';
    return await Get.dialog<bool>(
          WillPopScope(
            onWillPop: () async {
              // يمنع إغلاق الحوار عند النقر على زر الرجوع
              Get.back(result: false);
              return true;
            },
            child: AlertDialog(
              // backgroundColor: Colors.redAccent.withOpacity(.2),
              title: Text(
                isArabic ? 'تحذير: تفاعل دوائي' : 'Warning: Drug Interaction',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              content: Obx(() => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'تم اكتشاف تفاعلات دوائية محتملة. يرجى مراجعة التفاصيل أدناه.'
                              : 'Potential drug interactions have been detected. Please review the details below.',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ...rxInteractions.map((interaction) {
                          final medication1 = interaction.medication1;
                          final medication2 = interaction.medication2;
                          final timingGap = interaction.timingGap1 ?? interaction.timingGap2 ?? 'غير محدد';
                          final interactionType = interaction.interactionType;

                          // تحديد لون التصنيف بناءً على نوع التفاعل
                          Color interactionColor;
                          String? interactionLevel;
                          String? interactionComment;

                          switch (interactionType) {
                            case "Major":
                              interactionColor = Colors.red;
                              interactionLevel = isArabic ? 'عالي الخطورة' : 'High Risk';
                              interactionComment = isArabic
                                  ? 'عالي الخطورة، يهدد الحياة .. قم بوضع فترة زمنية لا تقل عن ساعة او استشر طبيبًا'
                                  : 'High risk, life-threatening .. Leave a time gap of at least 1 hour or consult a doctor';
                              break;
                            case "Moderate":
                              interactionColor = Colors.orange;
                              interactionLevel = isArabic ? 'مخاطر محتملة' : 'Moderate Risk';
                              interactionComment = isArabic
                                  ? 'مخاطر محتملة استشر طبيبًا قبل تناولها معًا'
                                  : 'Potential risks, consult a doctor before taking them together';
                              break;
                            case "Minor":
                              interactionColor = Colors.yellow;
                              interactionLevel = isArabic ? 'مخاطر محتملة' : 'Low Risk';
                              interactionComment = isArabic
                                  ? 'مخاطر محتملة استشر طبيبًا قبل تناولها معًا'
                                  : 'Potential risks, consult a doctor before taking them together';
                              break;
                            default:
                              interactionColor = Colors.grey;
                              interactionLevel = isArabic ? 'غير معروف' : 'Unknown';
                              interactionComment = isArabic ? 'نوع التفاعل غير معروف' : 'Interaction type is unknown';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.warning_rounded,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            margin: EdgeInsets.symmetric(vertical: 4),
                                            // color: Colors.red.withOpacity(.2),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(.2),
                                              borderRadius: BorderRadius.circular(7),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${medication1.name}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                // Text(_formatTimeBasedOnLanguage(interaction.newReminder.dateTime)),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_filled,
                                                      size: 12,
                                                      color: Colors.blueGrey,
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(
                                                      AppHelper.formatTimeBasedOnLanguage(interaction.newReminder.dateTime),
                                                      style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                    Spacer(),
                                                    InkWell(
                                                      onTap: () async {
                                                        final addMedController = Get.find<AddMedicationController>();

                                                        final TimeOfDay initialTime = TimeOfDay.fromDateTime(interaction.newReminder.dateTime);

                                                        // فتح مربع حوار الوقت
                                                        final TimeOfDay? time = await showTimePicker(
                                                          context: Get.context!,
                                                          initialTime: initialTime, // استخدام الوقت الحالي كقيمة ابتدائية
                                                        );
                                                        if (time != null) {
                                                          // تحديث interaction.newReminder.dateTime
                                                          final newDateTime = DateTime(
                                                            interaction.newReminder.dateTime.year,
                                                            interaction.newReminder.dateTime.month,
                                                            interaction.newReminder.dateTime.day,
                                                            time.hour,
                                                            time.minute,
                                                          );

                                                          // تحديث القيمة
                                                          interaction.newReminder.dateTime = newDateTime;

                                                          addMedController.reminders.forEach((reminder) {
                                                            if (reminder.id == interaction.newReminder.id) {
                                                              reminder.dateTime = newDateTime; // تحديث وقت التذكير
                                                            }
                                                          });
                                                          addMedController.update();
                                                          Get.back();
                                                          addMedController.onSavePressed();
                                                          // إعادة بناء الواجهة (إذا كنت تستخدم StatefulWidget أو GetX)
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(.3), borderRadius: BorderRadius.circular(8)),
                                                        child: Text(
                                                          isArabic ? 'تعديل التذكير' : 'Edit reminder',
                                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            margin: EdgeInsets.symmetric(vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.withOpacity(.2),
                                              borderRadius: BorderRadius.circular(7),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${medication2.tradeName}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_filled,
                                                      size: 12,
                                                      color: Colors.blueGrey,
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(AppHelper.formatTimeBasedOnLanguage(interaction.existingReminder.dateTime),
                                                        style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 16)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Text(
                                          //   ' ${medication2.tradeName}',
                                          //   style: const TextStyle(
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: 16,
                                          //   ),
                                          // )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isArabic ? 'نوع التفاعل: $interactionLevel' : 'Interaction Type: $interactionLevel',
                                  style: TextStyle(
                                    color: interactionColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                            
                                Divider(),
                                Text("${interaction.description ?? 'null'}",
                                    style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),

                                if (interaction.recommendation != null)
                                  Container(
                                    padding: const EdgeInsets.all(7), // إضافة padding
                                    margin: const EdgeInsets.symmetric(vertical: 5), // إضافة margin
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100], // لون الخلفية
                                      borderRadius: BorderRadius.circular(12), // زوايا مدورة
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3), // لون الحدود
                                        width: 1, // سمك الحدود
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // محاذاة النصوص لليسار
                                      children: [
                                        Text(
                                          isArabic ? 'نصيحة' : 'Advice', // ترجمة النص
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, // نص عريض
                                            fontSize: 16, // حجم النص
                                            color: Colors.orange[700], // لون النص
                                          ),
                                        ),
                                        const SizedBox(height: 8), // مسافة بين النصين
                                        Text(
                                          interaction.recommendation.toString(), // نص التفاعل (تمت ترجمته مسبقًا في interactionComment)
                                          style: TextStyle(
                                            fontSize: 14, // حجم النص
                                            color: Colors.grey[800], // لون النص
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  )),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text(
                    isArabic ? 'تعديل التذكيرات' : 'Edit Reminders',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'حفظ على أي حال' : 'Save Anyway',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          barrierDismissible: false,
        ) ??
        false;
  }
}

class NewInteractionResult {
  final MedicationModel medication1;
  final MedicineModelDataSet medication2;
  final ReminderModel newReminder;
  final ReminderModel existingReminder;

  final String? timingGap1;
  final String? timingGap2;
  final String? interactionType; // Major, Moderate, Minor
  final String? description; // وصف التفاعل
  final String? recommendation; // التوصيات
  final String? gapMessage; // التوصيات
  NewInteractionResult({
    required this.medication1,
    required this.medication2,
    required this.newReminder,
    required this.existingReminder,
    this.timingGap1,
    this.timingGap2,
    this.interactionType,
    this.description,
    this.recommendation,
    this.gapMessage,
  });
}
