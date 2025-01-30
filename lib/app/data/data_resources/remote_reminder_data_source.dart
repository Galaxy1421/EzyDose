import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/medication_model.dart';
import 'package:reminder/app/data/models/reminder_model.dart';

import 'local_medication_data_source.dart';

abstract class RemoteReminderDataSource {
  Future<List<ReminderModel>> getAllReminders();
  Future<List<ReminderModel>> getReminderByMedcationId(String id);
  Future<void> addReminder(ReminderModel model);
  Future<void> removeReminder(ReminderModel model);
  Future<ReminderModel?> getReminder(String id);
  Future<void> updateReminder(ReminderModel model);
}

class RemoteReminderDatSourceImpl extends RemoteReminderDataSource {
  final String keyName = "reminders";
  final String uid = Get.find<FirebaseAuth>().currentUser!.uid;
  final FirebaseFirestore _firestore = Get.find<FirebaseFirestore>();

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('userId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all reminders: $e');
      return [];
    }
  }

  @override
  Future<void> addReminder(ReminderModel model) async {
    try {
      await _firestore.collection(keyName).doc(model.id).set({
        ...model.toJson(),
        'userId': uid,
      });
      print('Reminder added successfully');
    } catch (e) {
      print('Error adding reminder: $e');
      throw e;
    }
  }

  @override
  Future<void> removeReminder(ReminderModel model) async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('id', isEqualTo: model.id)
          .where('userId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        print('Reminder removed successfully');
      } else {
        print('Reminder not found');
      }
    } catch (e) {
      print('Error removing reminder: $e');
      throw e;
    }
  }  @override
  Future<void> removeMedicationReminders(String medicationId) async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('medicationId', isEqualTo: medicationId)
          .where('userId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();

        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit(); // Commit the batch deletion
        print('All reminders removed successfully');
      } else {
        print('No reminders found for the given medication ID');
      }
    } catch (e) {
      print('Error removing reminders: $e');
      throw e;
    }
  }


  @override
  Future<void> updateReminder(ReminderModel model) async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('id', isEqualTo: model.id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = {
          ...model.toJson(),
          'userId': uid,
        };
        await snapshot.docs.first.reference.update(data);
        print('Reminder updated successfully');
      } else {
        print('Reminder not found');
        throw Exception('Reminder not found');
      }
    } catch (e) {
      print('Error updating reminder: $e');
      throw e;
    }
  }

  @override
  Future<List<ReminderModel>> getReminderByMedcationId(String id) async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('medicationId', isEqualTo: id)
          .where('userId', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting reminders by medication ID: $e');
      return [];
    }
  }

  @override
  Future<ReminderModel?> getReminder(String id) async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('id', isEqualTo: id)
          .where('userId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ReminderModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting reminder: $e');
      return null;
    }
  }

  @override
  Future<List<ReminderModel>> getAllRemindersByDate(DateTime day) async {
    try {
      final snapshot = await _firestore
          .collection(keyName)
          .where('userId', isEqualTo: uid)
          .get();

      List<ReminderModel> allReminders = snapshot.docs
          .map((doc) => ReminderModel.fromJson(doc.data()))
          .toList();

      List<ReminderModel> remindersByDate = [];
      final medicationDataSource = Get.find<LocalMedicationDataSource>();

      for (ReminderModel reminder in allReminders) {
        try {
          // Skip reminders without medication ID
          if (reminder.medicationId == null) {
            Logger().w('Reminder ${reminder.id} has no medication ID');
            continue;
          }

          // Get medication for the reminder
          MedicationModel? medication = await medicationDataSource
              .getMedicationById(reminder.medicationId!);

          // Skip if medication not found
          if (medication == null) {
            Logger().w('Medication not found for reminder ${reminder.id}');
            continue;
          }

          // Check frequency and add to list based on rules
          switch (medication.frequency) {
            case MedicationFrequency.monthly:
              if (reminder.dateTime.day == day) {
                remindersByDate.add(reminder);
                Logger().d('Added monthly reminder for day $day');
              }
              break;

            case MedicationFrequency.daily:
              remindersByDate.add(reminder);
              Logger().d('Added daily reminder');
              break;

            case MedicationFrequency.weekly:
              if (reminder.dateTime.weekday == day) {
                remindersByDate.add(reminder);
                Logger().d('Added weekly reminder for weekday $day');
              }
              break;

            default:
              Logger().w('Unknown frequency for medication ${medication.id}');
              break;
          }
        } catch (e) {
          // Log error but continue processing other reminders
          Logger().e('Error processing reminder ${reminder.id}: $e');
          continue;
        }
      }

      Logger().i('Found ${remindersByDate.length} reminders for day $day');
      return remindersByDate;

    } catch (e) {
      Logger().e('Error getting reminders by date: $e');
      return [];
    }
  }
}