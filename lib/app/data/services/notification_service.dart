// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:convert'; // Import the dart:convert library
// import 'dart:math' show max;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import '../models/reminder_model.dart';
// import '../models/medication_model.dart';
// import './medication_service.dart';
// import 'package:torch_light/torch_light.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';
//
// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) async {
//   // Handle notification tap in background
//   final logger = Logger();
//   logger.d('Notification tapped in background: ${notificationResponse.payload}');
//   await TorchLight.enableTorch();
//
//   if (notificationResponse.actionId != null && notificationResponse.payload != null) {
//     try {
//       // Parse the payload string to Map
//       final payloadStr = notificationResponse.payload!.replaceAll(RegExp(r'[{}]'), '');
//       final pairs = payloadStr.split(',').map((pair) {
//         final parts = pair.split(':');
//         if (parts.length < 2) return null;
//         return MapEntry(
//           parts[0].trim().replaceAll(RegExp(r"['\s]"), ''),
//           parts.sublist(1).join(':').trim().replaceAll(RegExp(r"['\s]"), '')
//         );
//       }).whereType<MapEntry<String, String>>();
//       final payloadData = Map.fromEntries(pairs);
//
//       logger.d('Parsed payload data: $payloadData');
//       final reminderId = payloadData['reminderId'];
//       final medicationId = payloadData['medicationId'];
//
//       if (reminderId != null && medicationId != null) {
//         // Get the MedicationService instance
//         final medicationService = Get.find<MedicationService>();
//
//         logger.d('Action: ${notificationResponse.actionId}');
//         logger.d('Medication ID: $medicationId');
//         logger.d('Reminder ID: $reminderId');
//
//         // Update the reminder status based on the action
//         switch (notificationResponse.actionId) {
//           case 'TAKE':
//             logger.d('Taking medication...');
//             await medicationService.updateReminderStatus(
//               medicationId,
//               reminderId,
//               ReminderStatus.taken,
//             );
//             break;
//           case 'SKIP':
//             logger.d('Skipping medication...');
//             await medicationService.updateReminderStatus(
//               medicationId,
//               reminderId,
//               ReminderStatus.skipped,
//             );
//             break;
//         }
//       }
//     } catch (e, stackTrace) {
//       logger.e('Error handling notification action', error: e, stackTrace: stackTrace);
//     }
//   }
// }
//
import 'package:get/get.dart';

class NotificationService extends GetxService {

  @override
  Future<NotificationService> init() async {
    // await initNotifications();
    return this;
  }

//   static NotificationService get to => Get.find();
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   final _selectedTime = TimeOfDay.now().obs;
//   final Map<String, List<DateTime>> _scheduledReminders = {};
//   final _storage = GetStorage();
//   final _flashKey = 'flash_enabled';
//
//   TimeOfDay get selectedTime => _selectedTime.value;
//   set selectedTime(TimeOfDay time) => _selectedTime.value = time;
//
//   bool get isFlashEnabled => _storage.read(_flashKey) ?? false;
//   set isFlashEnabled(bool value) => _storage.write(_flashKey, value);
//
//   Future<void> _handleTorchLight() async {
//     if (!isFlashEnabled) return;
//
//     try {
//       final isAvailable = await TorchLight.isTorchAvailable();
//       if (isAvailable) {
//         await TorchLight.enableTorch();
//         // Turn off torch after 3 seconds
//         await Future.delayed(const Duration(seconds: 3));
//         await TorchLight.disableTorch();
//       }
//     } catch (e) {
//       Logger().e('Error handling torch light: $e');
//     }
//   }
//
//   Future<void> initNotifications() async {
//     tz.initializeTimeZones();
//
//     // Initialize native platform specific implementation
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings initializationSettingsDarwin =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse notificationResponse)async {
//         // Handle notification tap in foreground
//         await _handleTorchLight();
//         developer.log('Notification tapped in foreground: ${notificationResponse.payload}');
//       },
//       onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
//     );
//
//     // Request permissions for iOS
//     if (Platform.isIOS) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//     }
//
//     developer.log('Notifications initialized');
//   }
//
//   AndroidNotificationDetails _createAndroidDetails(String channelId, String channelName) {
//     final isArabic = Get.locale?.languageCode == 'ar';
//
//     return AndroidNotificationDetails(
//       channelId,
//       channelName,
//       channelDescription: 'Channel for medication reminders'.tr,
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//       styleInformation: BigTextStyleInformation(
//         'It\'s time to take your medication. Please don\'t forget!'.tr,
//         htmlFormatBigText: true,
//         contentTitle: 'medication_reminder'.tr,
//         htmlFormatContentTitle: true,
//         summaryText: 'Tap to view details'.tr,
//         htmlFormatSummaryText: true,
//         htmlFormatContent: true,
//       ),
//       actions: <AndroidNotificationAction>[
//         AndroidNotificationAction(
//           'TAKE',
//           'take'.tr,
//           icon: const DrawableResourceAndroidBitmap('@drawable/ic_check'),
//           showsUserInterface: true,
//           contextual: true,
//         ),
//         AndroidNotificationAction(
//           'SKIP',
//           'skip'.tr,
//           icon: const DrawableResourceAndroidBitmap('@drawable/ic_skip'),
//           showsUserInterface: true,
//           contextual: true,
//         ),
//       ],
//       fullScreenIntent: true,
//       category: AndroidNotificationCategory.alarm,
//     );
//   }
//
//   NotificationDetails _createNotificationDetails(String channelId, String channelName) {
//     final androidDetails = _createAndroidDetails(channelId, channelName);
//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       interruptionLevel: InterruptionLevel.timeSensitive,
//       categoryIdentifier: 'medication_reminder',
//     );
//     return NotificationDetails(android: androidDetails, iOS: iosDetails);
//   }
//
//   String _getLocalizedNotificationTitle() {
//     return 'medication_reminder'.tr;
//   }
//
//   String _getLocalizedNotificationBody(String medicationName) {
//     final isArabic = Get.locale?.languageCode == 'ar';
//     if (isArabic) {
//       // For Arabic, we need to handle the text direction
//       return '${medicationName} ${'time_to_take'.tr}';
//     }
//     return '${'time_to_take'.tr} $medicationName';
//   }
//
//   Map<String, String> _createPayload(String reminderId, String medicationId, DateTime scheduledTime, String medicationName) {
//     return <String, String>{
//       'reminderId': reminderId,
//       'medicationName': medicationName,
//       'medicationId': medicationId,
//       'scheduledTime': scheduledTime.toIso8601String(),
//     };
//   }
//
//   Future<bool> scheduleReminder(ReminderModel reminder) async {
//     try {
//       final logger = Logger();
//       logger.d('Starting to schedule reminder:', error: {
//         'reminderId': reminder.id,
//         'medicationName': reminder.medicationName,
//         'reminderTime': '${reminder.time.hour}:${reminder.time.minute}',
//         'frequency': reminder.frequency.toString(),
//       });
//
//       // Cancel any existing notifications for this reminder
//       await cancelReminder(reminder.id);
//
//       // Convert reminder time to TimeOfDay
//       final timeOfDay = TimeOfDay(hour: reminder.time.hour, minute: reminder.time.minute);
//
//       // Get medication ID and image from MedicationService
//       final medicationService = Get.find<MedicationService>();
//       final medications = await medicationService.getMedications();
//       final medication = medications.firstWhere(
//         (med) => med.name == reminder.medicationName,
//         orElse: () => throw Exception('Medication not found'),
//       );
//
//       // Generate a unique notification ID
//       final notificationId = _generateNotificationId(reminder.id, DateTime.now());
//
//       // Create notification details
//       final notificationDetails = _createNotificationDetails(
//         'medication_reminders',
//         'Medication Reminders'
//       );
//
//       switch (reminder.frequency) {
//         case ReminderFrequency.once:
//           final scheduledDate = DateTime(
//             reminder.date.year,
//             reminder.date.month,
//             reminder.date.day,
//             reminder.time.hour,
//             reminder.time.minute,
//           );
//
//           if (scheduledDate.isBefore(DateTime.now())) {
//             logger.d('Scheduled date is in the past, skipping reminder');
//             return false;
//           }
//
//           final payload = _createPayload(reminder.id, medication.id, scheduledDate, reminder.medicationName);
//           await flutterLocalNotificationsPlugin.zonedSchedule(
//             notificationId,
//             _getLocalizedNotificationTitle(),
//             _getLocalizedNotificationBody(reminder.medicationName),
//             tz.TZDateTime.from(scheduledDate, tz.local),
//             notificationDetails,
//             androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//             uiLocalNotificationDateInterpretation:
//                 UILocalNotificationDateInterpretation.absoluteTime,
//             payload: jsonEncode(payload),
//           );
//           break;
//
//         case ReminderFrequency.daily:
//           final scheduledDate = _nextInstanceOfDailyTime(timeOfDay);
//           final payload = _createPayload(reminder.id, medication.id, scheduledDate, reminder.medicationName);
//           await flutterLocalNotificationsPlugin.zonedSchedule(
//             notificationId,
//             _getLocalizedNotificationTitle(),
//             _getLocalizedNotificationBody(reminder.medicationName),
//             scheduledDate,
//             notificationDetails,
//             androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//             matchDateTimeComponents: DateTimeComponents.time,
//             uiLocalNotificationDateInterpretation:
//                 UILocalNotificationDateInterpretation.absoluteTime,
//             payload: jsonEncode(payload),
//           );
//           break;
//
//         case ReminderFrequency.weekdays:
//           // Schedule for Monday through Friday
//           for (int day = DateTime.monday; day <= DateTime.friday; day++) {
//             final scheduledDate = _nextInstanceOfWeeklyTime(day, timeOfDay);
//             final payload = _createPayload(reminder.id, medication.id, scheduledDate, reminder.medicationName);
//             await flutterLocalNotificationsPlugin.zonedSchedule(
//               _generateNotificationId(reminder.id, DateTime.now().add(Duration(days: day))),
//               _getLocalizedNotificationTitle(),
//               _getLocalizedNotificationBody(reminder.medicationName),
//               scheduledDate,
//               notificationDetails,
//               androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//               matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//               uiLocalNotificationDateInterpretation:
//                   UILocalNotificationDateInterpretation.absoluteTime,
//               payload: jsonEncode(payload),
//             );
//           }
//           break;
//
//         case ReminderFrequency.weekends:
//           // Schedule for Saturday and Sunday
//           for (int day = DateTime.saturday; day <= DateTime.sunday; day++) {
//             final scheduledDate = _nextInstanceOfWeeklyTime(day, timeOfDay);
//             final payload = _createPayload(reminder.id, medication.id, scheduledDate, reminder.medicationName);
//             await flutterLocalNotificationsPlugin.zonedSchedule(
//               _generateNotificationId(reminder.id, DateTime.now().add(Duration(days: day))),
//               _getLocalizedNotificationTitle(),
//               _getLocalizedNotificationBody(reminder.medicationName),
//               scheduledDate,
//               notificationDetails,
//               androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//               matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//               uiLocalNotificationDateInterpretation:
//                   UILocalNotificationDateInterpretation.absoluteTime,
//               payload: jsonEncode(payload),
//             );
//           }
//           break;
//
//         case ReminderFrequency.custom:
//           // Schedule for each selected day
//           for (int day in reminder.selectedDays) {
//             final scheduledDate = _nextInstanceOfWeeklyTime(day, timeOfDay);
//             final payload = _createPayload(reminder.id, medication.id, scheduledDate, reminder.medicationName);
//             await flutterLocalNotificationsPlugin.zonedSchedule(
//               _generateNotificationId(reminder.id, DateTime.now().add(Duration(days: day))),
//               _getLocalizedNotificationTitle(),
//               _getLocalizedNotificationBody(reminder.medicationName),
//               scheduledDate,
//               notificationDetails,
//               androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//               matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//               uiLocalNotificationDateInterpretation:
//                   UILocalNotificationDateInterpretation.absoluteTime,
//               payload: jsonEncode(payload),
//             );
//           }
//           break;
//       }
//
//       logger.d('Successfully scheduled reminder:', error: {
//         'reminderId': reminder.id,
//         'medicationName': reminder.medicationName,
//         'frequency': reminder.frequency.toString(),
//       });
//
//       return true;
//     } catch (e, stackTrace) {
//       Logger().e('Error scheduling reminder:', error: e, stackTrace: stackTrace);
//       return false;
//     }
//   }
//
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     final tz.TZDateTime tzScheduledDate =
//         tz.TZDateTime.from(scheduledDate, tz.local);
//
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'scheduled_channel_id',
//       'Scheduled Channel',
//       channelDescription: 'Channel for scheduled notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tzScheduledDate,
//       platformDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   Future<void> scheduleDailyNotification({
//     required int id,
//     required String title,
//     required String body,
//     required TimeOfDay time,
//   }) async {
//     final tz.TZDateTime scheduledDate = _nextInstanceOfDailyTime(time);
//
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'daily_channel_id',
//       'Daily Notifications',
//       channelDescription: 'Channel for daily notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       platformDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   Future<void> scheduleWeeklyNotification({
//     required int id,
//     required String title,
//     required String body,
//     required TimeOfDay time,
//     required int dayOfWeek, // 1 = Monday, 7 = Sunday
//   }) async {
//     final tz.TZDateTime scheduledDate =
//         _nextInstanceOfWeeklyTime(dayOfWeek, time);
//
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'weekly_channel_id',
//       'Weekly Notifications',
//       channelDescription: 'Channel for weekly notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       platformDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   tz.TZDateTime _nextInstanceOfDailyTime(TimeOfDay time) {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }
//
//   tz.TZDateTime _nextInstanceOfWeeklyTime(int dayOfWeek, TimeOfDay time) {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     int daysUntilNext = (dayOfWeek - now.weekday) % 7;
//     if (daysUntilNext <= 0) daysUntilNext += 7;
//
//     final tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day + daysUntilNext,
//       time.hour,
//       time.minute,
//     );
//     return scheduledDate;
//   }
//
//   Future<void> cancelMedicationReminders(String medicationId) async {
//     try {
//       await flutterLocalNotificationsPlugin.cancelAll();
//       _scheduledReminders.clear();
//       developer.log('Cancelled reminders for medication $medicationId');
//     } catch (e) {
//       developer.log('Error cancelling reminders: $e');
//     }
//   }
//
//   Future<void> cancelReminder(String reminderId) async {
//     try {
//       if (_scheduledReminders.containsKey(reminderId)) {
//         final dates = _scheduledReminders[reminderId]!;
//         for (final date in dates) {
//           final notificationId = _generateNotificationId(reminderId, date);
//           await flutterLocalNotificationsPlugin.cancel(notificationId);
//         }
//         _scheduledReminders.remove(reminderId);
//         developer.log('Cancelled reminder $reminderId');
//       }
//     } catch (e) {
//       developer.log('Error cancelling reminder: $e');
//     }
//   }
//
//   Future<void> cancelAllNotifications() async {
//     try {
//       await flutterLocalNotificationsPlugin.cancelAll();
//       _scheduledReminders.clear();
//       developer.log('Cancelled all notifications');
//     } catch (e) {
//       developer.log('Error cancelling all notifications: $e');
//     }
//   }
//
//   List<DateTime> _calculateScheduleDates(ReminderModel reminder) {
//     final List<DateTime> dates = [];
//     final now = DateTime.now();
//
//     try {
//       final baseDate = DateTime(
//         reminder.date.year,
//         reminder.date.month,
//         reminder.date.day,
//         reminder.time.hour,
//         reminder.time.minute,
//       );
//
//       switch (reminder.frequency) {
//         case ReminderFrequency.once:
//           if (baseDate.isAfter(now)) {
//             dates.add(baseDate);
//           }
//           break;
//         case ReminderFrequency.daily:
//           var date = baseDate;
//           for (int i = 0; i < 30; i++) {
//             if (date.isAfter(now)) {
//               dates.add(date);
//             }
//             date = date.add(const Duration(days: 1));
//           }
//           break;
//         case ReminderFrequency.weekdays:
//           var date = baseDate;
//           for (int i = 0; i < 30; i++) {
//             if (date.isAfter(now) && date.weekday <= DateTime.friday) {
//               dates.add(date);
//             }
//             date = date.add(const Duration(days: 1));
//           }
//           break;
//         case ReminderFrequency.weekends:
//           var date = baseDate;
//           for (int i = 0; i < 30; i++) {
//             if (date.isAfter(now) && date.weekday > DateTime.friday) {
//               dates.add(date);
//             }
//             date = date.add(const Duration(days: 1));
//           }
//           break;
//         case ReminderFrequency.custom:
//           if (reminder.selectedDays.contains(baseDate.weekday)) {
//             var date = baseDate;
//             for (int i = 0; i < 30; i++) {
//               if (date.isAfter(now) && reminder.selectedDays.contains(date.weekday)) {
//                 dates.add(date);
//               }
//               date = date.add(const Duration(days: 1));
//             }
//           }
//           break;
//       }
//     } catch (e) {
//       developer.log('Error calculating schedule dates: $e');
//     }
//
//     return dates;
//   }
//
//   int _generateNotificationId(String reminderId, DateTime date) {
//     return '${reminderId}_${date.millisecondsSinceEpoch}'.hashCode;
//   }
//
//   Future<void> showMedicationReminder(MedicationModel medication, ReminderModel reminder) async {
//     try {
//       final id = int.parse(reminder.id);
//       final title = 'medication_reminder'.tr;
//       final body = 'time_to_take_medication'.trParams({
//         'quantity': medication.doseQuantity.toString(),
//         'unit': medication.unit.tr,
//         'name': medication.name,
//       });
//
//       final details = _createNotificationDetails(
//           'medication_reminders2',
//           'Medication Reminders2'
//       );
//
//       await flutterLocalNotificationsPlugin.show(
//         id,
//         title,
//         body,
//         details,
//         payload: jsonEncode({
//           'medicationId': medication.id,
//           'reminderId': reminder.id,
//         }),
//       );
//
//       // Trigger torch light when notification is shown
//       await _handleTorchLight();
//
//     } catch (e) {
//       Logger().e('Error showing medication reminder: $e');
//     }
//   }
//
//   /// Optimizes the scheduling of medication reminders using dynamic programming
//   /// Returns a Map of optimal reminder times mapped to their medications
//   Future<Map<DateTime, List<MedicationModel>>> _optimizeSchedule(List<MedicationModel> medications) async {
//     // Initialize our DP table to store optimal schedules
//     final Map<String, Map<DateTime, double>> dp = {};
//     // Initialize result map for final schedule
//     final Map<DateTime, List<MedicationModel>> schedule = {};
//
//     // Get 24-hour time slots in 15-minute intervals
//     final List<DateTime> timeSlots = _generateTimeSlots();
//
//     // Sort medications by priority (frequency and importance)
//     medications.sort((a, b) => _calculatePriority(b).compareTo(_calculatePriority(a)));
//
//     // For each medication, calculate optimal scheduling
//     for (final medication in medications) {
//       dp[medication.id] = {};
//
//       // For each possible time slot
//       for (final slot in timeSlots) {
//         double score = _evaluateTimeSlot(slot, medication, schedule);
//
//         // Check previous optimal solutions for overlapping medications
//         if (dp.length > 1) {
//           final prevMedId = medications[medications.indexOf(medication) - 1].id;
//           score += dp[prevMedId]?[slot] ?? 0;
//         }
//
//         dp[medication.id]![slot] = score;
//
//         // Update schedule if this is the optimal slot
//         if (score > (dp[medication.id]!.values.isEmpty ? 0 : dp[medication.id]!.values.reduce(max))) {
//           if (!schedule.containsKey(slot)) {
//             schedule[slot] = [];
//           }
//           schedule[slot]!.add(medication);
//         }
//       }
//     }
//
//     return schedule;
//   }
//
//   /// Generates time slots for the next 24 hours in 15-minute intervals
//   List<DateTime> _generateTimeSlots() {
//     final List<DateTime> slots = [];
//     final now = DateTime.now();
//     final startOfDay = DateTime(now.year, now.month, now.day);
//
//     for (int minutes = 0; minutes < 24 * 60; minutes += 15) {
//       slots.add(startOfDay.add(Duration(minutes: minutes)));
//     }
//     return slots;
//   }
//
//   /// Calculates priority score for a medication based on reminders and status
//   double _calculatePriority(MedicationModel medication) {
//     double score = 0;
//
//     // More frequent reminders get higher priority
//     score += medication.reminders.length * 2;
//
//     // Consider medication status
//     if (medication.isActive) score += 5;
//
//     // Consider prescription status
//     if (medication.hasPrescription) score += 3;
//
//     return score;
//   }
//
//   /// Evaluates how suitable a time slot is for a medication
//   double _evaluateTimeSlot(DateTime slot, MedicationModel medication, Map<DateTime, List<MedicationModel>> existingSchedule) {
//     double score = 10.0; // Base score
//
//     // Penalize slots that are too close to other medications
//     for (final scheduledTime in existingSchedule.keys) {
//       final difference = slot.difference(scheduledTime).inMinutes.abs();
//       if (difference < 30) { // If medications are less than 30 minutes apart
//         score -= (30 - difference) / 10; // Penalty increases as medications get closer
//       }
//     }
//
//     // Prefer slots during waking hours (8 AM to 10 PM)
//     if (slot.hour < 8 || slot.hour > 22) {
//       score -= 5;
//     }
//
//     // Check if the medication has any reminders at similar times
//     for (final reminder in medication.reminders) {
//       if ((reminder.time.hour - slot.hour).abs() <= 1) {
//         score += 2; // Prefer times similar to existing reminders
//       }
//     }
//
//     return score;
//   }
//
//   /// Schedule reminders using the optimized schedule
//   Future<void> scheduleOptimizedReminders(List<MedicationModel> medications) async {
//     try {
//  todo     // Get optimized schedule using dynamic programming
//       final schedule = await _optimizeSchedule(medications);
//
//       // Schedule notifications for each optimal time slot
//       for (final entry in schedule.entries) {
//         final timeSlot = entry.key;
//         final medsForSlot = entry.value;
//
//         for (final medication in medsForSlot) {
//           final reminder = ReminderModel(
//             id: _generateNotificationId(medication.id, timeSlot).toString(),
//             time: TimeOfDay.fromDateTime(timeSlot),
//             date: timeSlot,
//             frequency: ReminderFrequency.once,
//             type: ReminderType.custom,
//             status: ReminderStatus.pending,
//             selectedDays: [timeSlot.weekday],
//             medicationName: medication.name,
//             medicationImage: medication.image,
//           );
//
//           await showMedicationReminder(medication, reminder);
//         }
//       }
//     } catch (e) {
//       Logger().e('Error scheduling optimized reminders: $e');
//     }
//   }
// }
}