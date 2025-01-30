import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/data_resources/local_reminder_data_source.dart';
import 'package:reminder/app/data/repository/reminder_repository.dart';
import '../data_resources/remote_reminder_data_source.dart';
import '../models/reminder_frequency_model.dart';
import '../models/reminder_model.dart';
import '../models/reminder_state.dart';
import '../models/reminder_status.dart';

class ReminderRepositoryImpl extends ReminderRepository {
  final LocalReminderDatSourceImpl _localReminderDatSource;
  final RemoteReminderDatSourceImpl _remoteReminderDatSource;
  final Connectivity _connectivity = Connectivity();

  ReminderRepositoryImpl({required LocalReminderDatSourceImpl localReminderDatSource, required RemoteReminderDatSourceImpl remoteReminderDatSource}) : _localReminderDatSource = localReminderDatSource, _remoteReminderDatSource = remoteReminderDatSource;


  Future<bool> _isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      if (await _isConnected()) {
        // If connected, fetch from remote and update local
        final reminders = await _remoteReminderDatSource.getAllReminders();
        // await Future.wait(reminders.map((reminder) => _localReminderDatSource.addReminder(reminder)));
        return reminders;
      } else {
        // If not connected, fetch from local
        return await _localReminderDatSource.getAllReminders();
      }
    } catch (e) {
      print('Error getting all reminders: $e');
      return [];
    }
  }

  @override
  Future<List<ReminderModel>> getAllRemindersByMedcationId(String medicationId) async {
    try {
      if (await _isConnected()) {
        return await _remoteReminderDatSource.getReminderByMedcationId(medicationId);
      } else {
        return await _localReminderDatSource.getReminderByMedcationId(medicationId);
      }
    } catch (e) {
      print('Error getting reminders by medication ID: $e');
      return [];
    }
  }

  @override
  Future<void> addReminder(ReminderModel reminder) async {
    try {
      await _localReminderDatSource.addReminder(reminder);
      if (await _isConnected()) {
        await _remoteReminderDatSource.addReminder(reminder);
      }
    } catch (e) {
      print('Error adding reminder: $e');
      throw e;
    }
  }

  @override
  Future<void> deleteReminder(ReminderModel reminder) async {
    try {
      await _localReminderDatSource.removeReminder(reminder);
      if (await _isConnected()) {
        await _remoteReminderDatSource.removeReminder(reminder);
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      throw e;
    }
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    try {
      await _localReminderDatSource.updateReminder(reminder);
      if (await _isConnected()) {
        await _remoteReminderDatSource.updateReminder(reminder);
      }
    } catch (e) {
      print('Error updating reminder: $e');
      throw e;
    }
  }

  @override
  Future<void> deleteMedicationReminders(String medicationId) async{
    try {
      await _localReminderDatSource.removeMedicationReminders(medicationId);
      if (await _isConnected()) {
        await _remoteReminderDatSource.removeMedicationReminders(medicationId);
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      throw e;
    }
  }

  @override
  Future<ReminderModel> getReminder(String reminderId) async {
    try {
      ReminderModel? reminder;
      
      if (await _isConnected()) {
        reminder = await _remoteReminderDatSource.getReminder(reminderId);
      } else {
        reminder = await _localReminderDatSource.getReminder(reminderId);
      }
      
      if (reminder == null) {
        throw Exception('Reminder not found');
      }
      return reminder;
    } catch (e) {
      print('Error getting reminder: $e');
      throw e;
    }
  }

  @override
  Future<List<ReminderModel>> getAllRemindersByTime(DateTime date) async {
    try {
      List<ReminderModel> reminders;

      if (await _isConnected()) {
        // If connected, fetch from remote
        reminders = await _remoteReminderDatSource.getAllReminders();
      } else {
        // If not connected, fetch from local
        reminders = await _localReminderDatSource.getAllReminders();
      }

      // for(ReminderModel reminderModel in reminders){
      //   for(ReminderStatus status in reminderModel.statusHistory){
      //     if(status.state == ReminderState.pending && status.timestamp.isBefore(DateTime.now())){
      //       status.state = ReminderState.missed;
      //       updateReminder(reminderModel);
      //     }else{
      //     }
      //   }
      // }

      // Filter reminders based on frequency type
      final filteredReminders = reminders.where((reminder) {
        final frequency = reminder.frequency;

        if (frequency!.type == ReminderFrequency.daily) {
          // Include daily reminders
          return true;
        } else if (frequency.type == ReminderFrequency.custom) {
          // For custom reminders, check if the provided `day` is in `customDays`
          for (DateTime customDay in frequency.customDays) {
           if(customDay.year == date.year && customDay.month == date.month && customDay.day == date.day){
            return true;
           }
          }
        }

        // Exclude reminders with unsupported frequency types
        return false;
      }).toList();

      return filteredReminders;
    } catch (e) {
      print('Error getting reminders by time: $e');
      return [];
    }
  }
}