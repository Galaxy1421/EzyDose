import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';
import 'package:reminder/app/data/usecases/reminder/add_reminder_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/delete_reminder_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/get_all_reminders_by_medcations_id_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/get_all_reminders_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/update_reminder_usecase.dart';
import 'package:reminder/app/data/models/reminder_model.dart';

import '../../../data/models/reminder_state.dart';
import '../../../data/models/reminder_status.dart';

class CustomReminderController extends GetxController {
  final AddReminderUseCase _addReminderUseCase;
  final UpdateReminderUseCase _updateReminderUseCase;
  final DeleteReminderUsecase _deleteReminderUseCase;
  final DeleteMedicationRemindersUseCase _deleteMedicationRemindersUseCase;
  final GetAllRemindersUsecase _allRemindersUseCase;
  final GetAllRemindersByDateUsecase _getAllRemindersByDateUsecase;
  final GetReminderUseCase _getReminderUseCase;
  final GetAllRemindersByMedicationsIdUseCase _allRemindersByMedicationsIdUseCase;

  CustomReminderController({
    required AddReminderUseCase addReminderUseCase,
    required GetAllRemindersByDateUsecase getAllByDate,
    required UpdateReminderUseCase updateReminderUseCase,
    required DeleteReminderUsecase deleteReminderUseCase,
    required GetReminderUseCase getReminderUseCase,
    required GetAllRemindersUsecase allRemindersUseCase,
    required DeleteMedicationRemindersUseCase deleteMedicationRemindersUseCase,
    required GetAllRemindersByMedicationsIdUseCase allRemindersByMedicationsIdUseCase,
  })  : _addReminderUseCase = addReminderUseCase,
        _updateReminderUseCase = updateReminderUseCase,
        _getReminderUseCase = getReminderUseCase,
        _getAllRemindersByDateUsecase = getAllByDate,
        _deleteReminderUseCase = deleteReminderUseCase,
        _allRemindersUseCase = allRemindersUseCase,
        _deleteMedicationRemindersUseCase = deleteMedicationRemindersUseCase,

        _allRemindersByMedicationsIdUseCase = allRemindersByMedicationsIdUseCase;

  final RxBool isLoading = false.obs;
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxList<ReminderModel> remindersList = <ReminderModel>[].obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  final RefreshController refreshController = RefreshController();

  final selectedDate = DateTime.now().obs;
  Timer? _missedReminderTimer;

  @override
  void onInit() {
    super.onInit();
    getAllReminders();
    
    // Set up periodic check for missed reminders every minute
    // _missedReminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
    //   getAllRemindersByDate(selectedDate.value);
    // });
  }

  @override
  void onClose() {
    _missedReminderTimer?.cancel();
    super.onClose();
  }

  Future<void> selectDate(DateTime date) async {
    selectedDate.value = date;
    await getAllRemindersByDate(date);
  }
  Future<void> getAllReminders() async {
    getAllRemindersByDate(selectedDate.value);
    // _loadingWrapper(() async {
    //   final result = await _allRemindersUseCase();
    //   reminders.assignAll(result);
    // }, 'Failed to get reminders');
  }
  Future<List<ReminderModel>> getAllRemindersByDate(DateTime date) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await _getAllRemindersByDateUsecase(date);
      
      // Update status for passed reminders that are pending
      final now = DateTime.now();
      final updatedReminders = await Future.wait(
        result.map((reminder) async {
          // Check if the reminder time has passed by more than 10 minutes and its status is pending
          final timeDifference = now.difference(reminder.dateTime);
          final isPending = reminder.statusHistory.isEmpty || 
              reminder.statusHistory.last.state == ReminderState.pending;
          
          // Check if there's already a status for today
          final hasStatusForToday = reminder.statusHistory.any((status) =>
            status.timestamp.year == now.year &&
            status.timestamp.month == now.month &&
            status.timestamp.day == now.day
          );

          Logger().d(timeDifference.inMinutes > 10 && isPending && hasStatusForToday);

          if (timeDifference.inMinutes > 10 && isPending && hasStatusForToday) {
            // Create a new reminder with missed status
            final missedReminder = reminder.copyWith(
              statusHistory: [
                ...reminder.statusHistory,
                ReminderStatus(
                  timestamp: reminder.dateTime,
                  state: ReminderState.missed,
                ),
              ],
            );
            
            // Update the reminder in the database
            await _updateReminderUseCase(missedReminder);
            Logger().d('Marked reminder ${reminder.id} as missed');
            return missedReminder;
          }
          return reminder;
        }),
      );

      remindersList.assignAll(updatedReminders);
      return updatedReminders;
    } catch (e) {
      Logger().e('Error checking missed reminders: $e');
      errorMessage.value = 'Failed to get reminders for date: $e';
      _showErrorDialog(errorMessage.value!);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ReminderModel>> getRemindersByMedicationId(String medicationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await _allRemindersByMedicationsIdUseCase(medicationId);
      reminders.assignAll(result);
      return result;
    } catch (e) {
      errorMessage.value = 'Failed to get reminders for medication: $e';
      _showErrorDialog(errorMessage.value!);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _loadingWrapper(() async {
      await _addReminderUseCase(reminder);
      await getAllReminders();
      _showSuccessDialog('Reminder added successfully');
    }, 'Failed to add reminder');
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _loadingWrapper(() async {
      await _updateReminderUseCase(reminder);
      await getAllReminders();
      _showSuccessDialog('Reminder updated successfully');
    }, 'Failed to update reminder');
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    await _loadingWrapper(() async {
      await _deleteReminderUseCase(reminder);
      await getAllReminders();
      _showSuccessDialog('Reminder deleted successfully');
    }, 'Failed to delete reminder');
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

  void _showSuccessDialog(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  void _showErrorDialog(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onError,
    );
  }
}