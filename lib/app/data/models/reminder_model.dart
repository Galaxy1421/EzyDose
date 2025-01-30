import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/reminder_frequency_model.dart';
import 'reminder_status.dart';
import 'reminder_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderType {
  wakeUp,
  breakfast,
  beforeBreakfast,
  afterBreakfast,
  beforeLunch,
  afterLunch,
  beforeDinner,
  afterDinner,
  bedtime,
  custom
}





class ReminderModel {
   String id;
   String? medicationId;
  late  String? medicationName;
  DateTime dateTime;
  ReminderFrequencyModel? frequency;
  final ReminderType type;
  List<ReminderStatus> statusHistory;
bool? isExpiredMedication = false;
   MedicineModelDataSet? medicineModelDataSet;

  ReminderModel({
    required this.id,
    this.medicationId,
    this.medicationName,
    this.frequency,
    required this.dateTime,
    required this.type,
    List<ReminderStatus>? statusHistory,
    this.medicineModelDataSet,
  }) : statusHistory = statusHistory ?? [ReminderStatus(
    timestamp: DateTime.now(),
    state: ReminderState.pending,
  )];


  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'dateTime': dateTime.toIso8601String(),
        'frequency': frequency!.toJson(),
        'type': type.toString(),
        'statusHistory': statusHistory.map((status) => status.toJson()).toList(),
        'medicineModelDataSet': medicineModelDataSet?.toJson(),
      };
    } catch (e) {
      print('Error converting ReminderModel to JSON: $e');
      rethrow;
    }
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    try {
      final frequencyJson = json['frequency'] as Map<String, dynamic>? ?? {
        'id': 'id',
        'type': 'daily',
        'customDays': [],
        'repeatEvery': 1,
        'repeatEveryNumber': 1,
        'repeatEveryUnit': 'day'
      };

      // Handle both Timestamp and String for dateTime
      DateTime parsedDateTime;
      final dateTimeValue = json['dateTime'];
      if (dateTimeValue is Timestamp) {
        parsedDateTime = dateTimeValue.toDate();
      } else if (dateTimeValue is String) {
        parsedDateTime = DateTime.parse(dateTimeValue);
      } else {
        parsedDateTime = DateTime.now();
        print('Warning: Invalid dateTime format in JSON: $dateTimeValue');
      }

      return ReminderModel(
        id: json['id'] as String? ?? '',
        medicationId: json['medicationId'] as String?,
        medicationName: json['medicationName'] as String?,
        dateTime: parsedDateTime,
        frequency: ReminderFrequencyModel.fromJson(frequencyJson),
        type: ReminderType.values.firstWhere(
          (e) => e.toString() == (json['type'] as String?),
          orElse: () => ReminderType.custom,
        ),
        statusHistory: (json['statusHistory'] as List<dynamic>?)
            ?.map((status) {
              if (status is! Map<String, dynamic>) {
                throw FormatException('status is not a Map: $status');
              }
              return ReminderStatus.fromJson(status);
            })
            .toList() ?? [],

        medicineModelDataSet: json['medicineModelDataSet'] != null
            ? MedicineModelDataSet.fromJson(json['medicineModelDataSet'])
            : null,
      );
    } catch (e) {
      print('Error parsing ReminderModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }


  ReminderModel copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    DateTime? dateTime,
    ReminderType? type,
    List<ReminderStatus>? statusHistory,
    MedicineModelDataSet? medicineModelDataSet,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      statusHistory: statusHistory ?? List.from(this.statusHistory), frequency: frequency,
      medicineModelDataSet: medicineModelDataSet??this.medicineModelDataSet
    );
  }


   ReminderState getCurrentState() {
     if (statusHistory.isEmpty) return ReminderState.pending;
     return statusHistory.last.state;
   }

   String getCustomFrequencyDescription() {
     return frequency?.getCustomFrequencyDescription() ?? 'Not set';
   }

   ReminderState getStateForDate(DateTime date) {
    final statusForDate = statusHistory
        .where((status) => _isSameDay(status.timestamp, date))
        .toList();

    if (statusForDate.isEmpty) {
      if (date.isBefore(DateTime.now())) {
        return ReminderState.missed;
      }
      return ReminderState.pending;
    }

    return statusForDate.last.state;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
