import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/new_interaction_model.dart';
import '../services/settings_service.dart';
import 'package:reminder/app/data/models/interaction_model.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import 'package:get/get.dart';
import 'dart:convert'; // Import dart:convert for jsonEncode and jsonDecode

enum MedicationFrequency {
  daily,
  weekly,
  monthly,
  custom
}

class MedicationModel {
  static const int defaultLowQuantityThreshold = 5;

  String id;
  String name;
  String optionalName;
  String instructions;
  int totalQuantity;
  int remainingQuantity;
  int doseQuantity;
  String unit;
  late List<InteractionModel> interactions;
  late List<NewInteractionModel> newInteractions;
  String? imageUrl;
  bool hasPrescription;
  String? prescriptionText;
  String? prescriptionImage;
  DateTime? expiryDate;
  DateTime createdAt;
  DateTime updatedAt;
  MedicationFrequency frequency;
  MedicationFrequency? customFrequency;
  Set<int> customDays;
  int expiryReminderDays;
  int quantityReminderDays;
   String? atcCode1;
   String? tradeName;
   String? constraint;
   String? atcCode1Interact;
   String? timingGap1;
   String? atcCode2Interact;
   String? timingGap2;
   String? major;
   String? moderate;
   String? minor;
   String? packageSize;
   String? photoLink;
  MedicineModelDataSet? medicineModelDataSet;

  MedicationModel({
    required this.id,
    required this.name,
    this.instructions = '',
    this.optionalName = '',
    required this.totalQuantity,
    required this.doseQuantity,
    required this.unit,
    this.interactions = const [],
    this.newInteractions = const [],
    //=====================

    this.medicineModelDataSet,
    this.atcCode1,
    this.tradeName,
    this.constraint,
    this.atcCode1Interact,
    this.timingGap1,
    this.atcCode2Interact,
    this.timingGap2,
    this.major,
    this.moderate,
    this.minor,
    this.packageSize,
    this.photoLink,
    //=====================

    this.imageUrl,
    this.hasPrescription = false,
    this.prescriptionText,
    this.prescriptionImage,
    this.expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.frequency = MedicationFrequency.daily,
    this.customFrequency,
    this.customDays = const {},
    this.expiryReminderDays = 7,
    this.quantityReminderDays = 7,
    int? remainingQuantity, Map<String, String>? customFrequencyData,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now(),
    this.remainingQuantity = remainingQuantity ?? totalQuantity;


  MedicationModel copyWith({
    String? id,
    String? name,
    String? instructions,
    int? totalQuantity,
    int? remainingQuantity,
    int? doseQuantity,
    String? unit,
    String? optionalName,
    List<InteractionModel>? interactions,
    List<NewInteractionModel>? newInteractions,
    String? imageUrl,
    bool? hasPrescription,
    String? prescriptionText,
    String? prescriptionImage,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    MedicationFrequency? frequency,
    MedicationFrequency? customFrequency,
    Set<int>? customDays,
    int? expiryReminderDays,
    int? quantityReminderDays,
//========
  MedicineModelDataSet? medicineModelDataSet,
     String? atcCode1,
     String? tradeName,
     String? constraint,
     String? atcCode1Interact,
     String? timingGap1,
     String? atcCode2Interact,
     String? timingGap2,
     String? major,
     String? moderate,
     String? minor,
     String? packageSize,
     String? photoLink,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      unit: unit ?? this.unit,
      interactions: interactions ?? this.interactions,
      newInteractions: newInteractions ?? this.newInteractions,
      imageUrl: imageUrl ?? this.imageUrl,
      hasPrescription: hasPrescription ?? this.hasPrescription,
      prescriptionText: prescriptionText ?? this.prescriptionText,
      prescriptionImage: prescriptionImage ?? this.prescriptionImage,
      expiryDate: expiryDate ?? this.expiryDate,
      frequency: frequency ?? this.frequency,
      customFrequency: customFrequency ?? this.customFrequency,
      customDays: customDays ?? this.customDays,
      expiryReminderDays: expiryReminderDays ?? this.expiryReminderDays,
      quantityReminderDays: quantityReminderDays ?? this.quantityReminderDays,
      optionalName: optionalName ?? this.optionalName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
//=============
      medicineModelDataSet:medicineModelDataSet??this.medicineModelDataSet,
      atcCode1:atcCode1??this.atcCode1,
       tradeName:tradeName??this.tradeName,
       constraint:constraint??this.constraint,
       atcCode1Interact:atcCode1Interact??this.atcCode1Interact,
       timingGap1:timingGap1??this.timingGap1,
       atcCode2Interact:atcCode2Interact??this.atcCode2Interact,
       timingGap2:timingGap2??this.timingGap2,
       major:major??this.major,
       moderate:moderate??this.moderate,
       minor:minor??this.minor,
       packageSize:packageSize??this.packageSize,
       photoLink:photoLink??this.photoLink,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    try {
      return MedicationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        optionalName: json['optionalName'] as String? ?? '',
        instructions: json['instructions'] as String? ?? '',
        totalQuantity: json['totalQuantity'] as int,
        remainingQuantity: json['remainingQuantity'] as int,
        doseQuantity: json['doseQuantity'] as int,
        unit: json['unit'] as String,
        interactions: (json['interactions'] as List<dynamic>)
            .map((x) => InteractionModel.fromJson(x as Map<String, dynamic>))
            .toList(),

        newInteractions: (json['interactions'] as List<dynamic>?)
            ?.map((e) => NewInteractionModel.fromJson(e))
            .toList() ??
            [],
        imageUrl: json['imageUrl'] as String?,
        hasPrescription: json['hasPrescription'] as bool? ?? false,
        prescriptionText: json['prescriptionText'] as String?,
        prescriptionImage: json['prescriptionImage'] as String?,
        expiryDate: json['expiryDate'] == null
            ? null
            : DateTime.parse(json['expiryDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        frequency: MedicationFrequency.values.firstWhere(
          (e) => e.toString() == json['frequency'],
          orElse: () => MedicationFrequency.daily,
        ),
        customFrequency: json['customFrequency'] == null
            ? null
            : MedicationFrequency.values.firstWhere(
                (e) => e.toString() == json['customFrequency'],
                orElse: () => MedicationFrequency.daily,
              ),
        customDays: (json['customDays'] as List<dynamic>?)?.map((e) => e as int).toSet() ?? {},
        expiryReminderDays: json['expiryReminderDays'] as int? ?? 7,
        quantityReminderDays: json['quantityReminderDays'] as int? ?? 7,

        // الحقول الجديدة
        medicineModelDataSet: json['medicineModelDataSet'] != null
            ? MedicineModelDataSet.fromJson(json['medicineModelDataSet'])
            : null,
        atcCode1: json['atcCode1'] as String?,
        tradeName: json['tradeName'] as String?,
        constraint: json['constraint'] as String?,
        atcCode1Interact: json['atcCode1Interact'] as String?,
        timingGap1: json['timingGap1'] as String?,
        atcCode2Interact: json['atcCode2Interact'] as String?,
        timingGap2: json['timingGap2'] as String?,
        major: json['major'] as String?,
        moderate: json['moderate'] as String?,
        minor: json['minor'] as String?,
        packageSize: json['packageSize'] as String?,
        photoLink: json['photoLink'] as String?,
      );
    } catch (e, stack) {
      Logger().e('Error creating MedicationModel from JSON: $e\n$stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      final json = {
        'id': id,
        'name': name,
        'optionalName': optionalName,
        'instructions': instructions,
        'totalQuantity': totalQuantity,
        'remainingQuantity': remainingQuantity,
        'doseQuantity': doseQuantity,
        'unit': unit,
        'interactions': interactions.map((x) => x.toJson()).toList(),
        'newInteractions': newInteractions.map((x) => x.toJson()).toList(),
        'imageUrl': imageUrl,
        'hasPrescription': hasPrescription,
        'prescriptionText': prescriptionText,
        'prescriptionImage': prescriptionImage,
        'expiryDate': expiryDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'frequency': frequency.toString(),
        'customFrequency': customFrequency?.toString(),
        'customDays': customDays.toList(),
        'expiryReminderDays': expiryReminderDays,
        'quantityReminderDays': quantityReminderDays,

        // الحقول الجديدة
        'medicineModelDataSet': medicineModelDataSet?.toJson(),
        'atcCode1': atcCode1,
        'tradeName': tradeName,
        'constraint': constraint,
        'atcCode1Interact': atcCode1Interact,
        'timingGap1': timingGap1,
        'atcCode2Interact': atcCode2Interact,
        'timingGap2': timingGap2,
        'major': major,
        'moderate': moderate,
        'minor': minor,
        'packageSize': packageSize,
        'photoLink': photoLink,
      };
      return json;
    } catch (e, stack) {
      Logger().e('Error converting MedicationModel to JSON: $e\n$stack');
      rethrow;
    }
  }

  

  bool? isQuantitySufficient;
  bool? isExpiryDateNear;
  // Get the quantity display string (e.g., "58/60 pills")
  String get quantityDisplay => '$remainingQuantity/$totalQuantity $unit';

  // Get the next refill date based on remaining quantity and dose quantity
  DateTime? get nextRefillDate {
    if (remainingQuantity <= 0 || doseQuantity <= 0) return null;

    final daysRemaining = remainingQuantity ~/ doseQuantity;
    return DateTime.now().add(Duration(days: daysRemaining));
  }

  // Check if medication is running low based on threshold
  bool get isRunningLow {
    if (remainingQuantity <= 0 || doseQuantity <= 0) return true;

    final daysRemaining = remainingQuantity ~/ doseQuantity;
    return daysRemaining <= defaultLowQuantityThreshold;
  }

// Create a copy of this medication with updated values
}
