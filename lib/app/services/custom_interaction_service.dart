import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../data/usecases/medication/get_all_medications_usecase.dart';
import '../data/models/medication_model.dart';
import '../data/models/reminder_model.dart';
import '../data/usecases/reminder/get_all_reminders_by_medcations_id_usecase.dart';
import '../modules/dashboard/controllers/custom_reminder_controller.dart';

class ConflictDetail {
  final MedicationModel existingMedication;
  final ReminderModel newReminder;
  final ReminderModel existingReminder;
  final bool canEdit;

  ConflictDetail({
    required this.existingMedication,
    required this.newReminder,
    required this.existingReminder,
    required this.canEdit,
  });

  ConflictDetail copyWith({
    MedicationModel? existingMedication,
    ReminderModel? existingReminder,
    ReminderModel? newReminder,
    bool? canEdit,
  }) {
    return ConflictDetail(
      existingMedication: existingMedication ?? this.existingMedication,
      existingReminder: existingReminder ?? this.existingReminder,
      newReminder: newReminder ?? this.newReminder,
      canEdit: canEdit ?? this.canEdit,
    );
  }
}

class InteractionResult {
  final bool hasInteraction;
  final List<ConflictDetail> conflicts;
  final String message;

  InteractionResult({
    required this.hasInteraction,
    required this.conflicts,
    required this.message,
  });

  factory InteractionResult.noConflicts() {
    return InteractionResult(
      hasInteraction: false,
      conflicts: [],
      message: 'No medication interactions found.',
    );
  }

  factory InteractionResult.withConflicts(List<ConflictDetail> conflicts) {
    final medicationNames = conflicts.map((c) => c.existingMedication.name).toSet().join(', ');
    return InteractionResult(
      hasInteraction: true,
      conflicts: conflicts,
      message: 'Found interactions with: $medicationNames',
    );
  }

  factory InteractionResult.error(String errorMessage) {
    return InteractionResult(
      hasInteraction: false,
      conflicts: [],
      message: 'Error: $errorMessage',
    );
  }
}

class CustomInteractionService extends GetxService {
  final CustomReminderController _reminderController = Get.find();
  final GetAllRemindersByMedicationsIdUseCase _remindersByMedIdUseCase = Get.find();
  final GetAllMedicationsUseCase _allMedicationsUseCase = Get.find();
  final Logger _logger = Logger();

  /// Checks for potential medication interactions and returns details about conflicts
  Future<InteractionResult> checkInteraction(
    MedicationModel newMedication,
    List<ReminderModel> newReminders
  ) async {
    try {
      if (newMedication.interactions.isEmpty || newReminders.isEmpty) {
        return InteractionResult.noConflicts();
      }

      final existingMedications = await _allMedicationsUseCase.call();
      final conflicts = <ConflictDetail>[];

      for (var interaction in newMedication.interactions) {
        final interactingMed = existingMedications
            .firstWhereOrNull((med) => med.name.toLowerCase() == interaction.medicationName.toLowerCase());
        
        _logger.d('Checking interaction: ${interaction.medicationName}');
        _logger.d('Found medication: ${interactingMed?.name}');

        if (interactingMed != null) {
          // Get reminders for the interacting medication
          final existingReminders = await _remindersByMedIdUseCase.call(interactingMed.id);
          _logger.d('Found ${existingReminders.length} existing reminders');
          
          // Find time conflicts between existing reminders and new reminders
          final timeConflicts = await _findTimeConflicts(
            newReminders,
            existingReminders,
            interactingMed,
          );
          _logger.d('Found ${timeConflicts.length} time conflicts');
          
          conflicts.addAll(timeConflicts);
        }
      }

      _logger.d('Total conflicts found: ${conflicts.length}');
      return conflicts.isEmpty 
          ? InteractionResult.noConflicts()
          : InteractionResult.withConflicts(conflicts);

    } catch (e, stackTrace) {
      _logger.e('Error checking medication interactions', error: e, stackTrace: stackTrace);
      return InteractionResult.error(e.toString());
    }
  }

  /// Finds time conflicts between new reminders and existing reminders
  Future<List<ConflictDetail>> _findTimeConflicts(
    List<ReminderModel> newReminders,
    List<ReminderModel> existingReminders,
    MedicationModel existingMedication,
  ) async {
    final conflicts = <ConflictDetail>[];
    final now = DateTime.now();
    
    Logger().d('Checking time conflicts between:');
    Logger().d('- ${newReminders.length} new reminders');
    Logger().d('- ${existingReminders.length} existing reminders');

    for (var newReminder in newReminders) {
      for (var existingReminder in existingReminders) {
        if (_isTimeConflict(newReminder.dateTime, existingReminder.dateTime)) {
          // Check if reminders are from the same day
          bool isSameDay = _isSameDay(newReminder.dateTime, existingReminder.dateTime);
          
          // Check if the existing reminder is within 30 minutes from now
          bool canEdit = _isWithin30Minutes(existingReminder.dateTime, now);
          
          Logger().d('Found conflict:');
          Logger().d('- New reminder time: ${newReminder.dateTime}');
          Logger().d('- Existing reminder time: ${existingReminder.dateTime}');
          Logger().d('- Same day: $isSameDay');
          Logger().d('- Can edit: $canEdit');
          
          if (isSameDay) {
            conflicts.add(ConflictDetail(
              existingMedication: existingMedication,
              existingReminder: existingReminder,
              newReminder: newReminder,
              canEdit: canEdit,
            ));
          }
        }
      }
    }

    Logger().d('Found ${conflicts.length} conflicts');
    return conflicts;
  }

  /// Checks if two times are in conflict (same hour)
  bool _isTimeConflict(DateTime time1, DateTime time2) {
    // Consider times within 30 minutes of each other as conflicting
    final difference = time1.difference(time2).inMinutes.abs();
    final isConflict = difference < 30;
    Logger().i(time1.toIso8601String());
    Logger().i(time2.toIso8601String());
    Logger().d('Time difference: $difference minutes, Is conflict: $isConflict');
    return isConflict;
  }

  /// Checks if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Checks if a given time is within 30 minutes from now
  bool _isWithin30Minutes(DateTime time, DateTime now) {
    final difference = now.difference(time).inMinutes.abs();
    return difference <= 30;
  }

  /// Gets a formatted summary of conflicts
  String getConflictSummary(InteractionResult result) {
    if (!result.hasInteraction) {
      return result.message;
    }

    final buffer = StringBuffer();
    buffer.writeln('Found medication interactions:');
    buffer.writeln();

    // Group conflicts by medication
    final groupedConflicts = <String, List<ConflictDetail>>{};
    for (var conflict in result.conflicts) {
      final medName = conflict.existingMedication.name;
      groupedConflicts.putIfAbsent(medName, () => []).add(conflict);
    }

    // Generate summary for each medication
    for (var entry in groupedConflicts.entries) {
      buffer.writeln('${entry.key}:');
      for (var conflict in entry.value) {
        buffer.writeln('  - New reminder at: ${_formatDateTime(conflict.newReminder.dateTime)}');
        buffer.writeln('    conflicts with existing reminder at: ${_formatDateTime(conflict.existingReminder.dateTime)}');
        if (conflict.canEdit) {
          buffer.writeln('    (This reminder can be edited - within 30 minutes of current time)');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Formats DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
