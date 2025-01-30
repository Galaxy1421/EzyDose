import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:reminder/app/data/usecases/medication/get_all_medications_by_uid_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/update_reminder_usecase.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:reminder/app/modules/dashboard/controllers/custom_reminder_controller.dart';
import 'package:torch_light/torch_light.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../data/models/reminder_frequency_model.dart';
import '../data/models/reminder_model.dart';
import 'package:workmanager/workmanager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../data/models/reminder_state.dart';
import '../data/models/reminder_status.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  if (Get.isRegistered<ScheduleService>()) {
    final scheduleService = Get.find<ScheduleService>();
    await scheduleService.handleNotificationAction(receivedAction);
  }
}

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
  debugPrint('Notification created: ${receivedNotification.toMap()}');
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
  debugPrint('Notification displayed: ${receivedNotification.toMap()}');
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint('Notification dismissed: ${receivedAction.toMap()}');
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'toggleTorch':
          final bool turnOn = inputData?['turnOn'] ?? false;
          if (turnOn) {
            await TorchLight.enableTorch();
            await Future.delayed(const Duration(seconds: 3));
            await TorchLight.disableTorch();
          }
          break;
      }
      return true;
    } catch (e) {
      print('Error in background task: $e');
      return false;
    }
  });
}

class ScheduleService extends GetxService {
  final _isScheduled = false.obs;
  final _selectedTime = Rxn<DateTime>();
  final _hasIgnoreBatteryOptimization = false.obs;
  final _isNotificationsEnabled = false.obs;
  final _isTorchEnabled = false.obs;
  final GetMedicationByIdUseCase _medicationByIdUseCase;
  final GetReminderUseCase _getReminderUseCase;
  final UpdateReminderUseCase _updateReminderUseCase = Get.find();
  final Logger _logger = Logger();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  int? _androidVersion;

  ScheduleService(this._medicationByIdUseCase, this._getReminderUseCase);

  bool get isScheduled => _isScheduled.value;
  DateTime? get selectedTime => _selectedTime.value;
  bool get hasIgnoreBatteryOptimization => _hasIgnoreBatteryOptimization.value;
  bool get isNotificationsEnabled => _isNotificationsEnabled.value;
  bool get isTorchEnabled => _isTorchEnabled.value;

  Future<ScheduleService> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Get Android version
    final androidInfo = await _deviceInfo.androidInfo;
    _androidVersion = androidInfo.version.sdkInt;
    
    // Initialize Workmanager for background tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    await _initializeNotifications();
    await _checkPermissions();
    await _checkNotificationSettings();
    return this;
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize Awesome Notifications with better configuration
      await AwesomeNotifications().initialize(
        null, // Set to null to use the default app icon
        [
          NotificationChannel(
            channelKey: 'medication_reminders',
            channelName: 'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            importance: NotificationImportance.High,
            enableVibration: true,
            playSound: true,
            criticalAlerts: true,
            defaultRingtoneType: DefaultRingtoneType.Alarm,

          ),
        ],
        debug: true
      );

      // Set up notification listeners with proper static methods
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      );

      // Ensure notifications are allowed
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
            NotificationPermission.Light,
            NotificationPermission.PreciseAlarms,
            NotificationPermission.FullScreenIntent,
            NotificationPermission.CriticalAlert,
          ]
        );
      }

      _logger.d('Notifications initialized successfully');
    } catch (e) {
      _logger.e('Error initializing notifications: $e');
      FirebaseFirestore.instance.collection('error').add({
        'error_type': 'notification_init_error',
        'error_message': e.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Check battery optimization status
      _hasIgnoreBatteryOptimization.value = await Permission.ignoreBatteryOptimizations.isGranted;

      // Request camera permission for torch if device supports it
      if (await TorchLight.isTorchAvailable()) {
        var cameraStatus = await Permission.camera.status;
        if (!cameraStatus.isGranted) {
          cameraStatus = await Permission.camera.request();
        }
      }

      // Request notification permission
      var notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        notificationStatus = await Permission.notification.request();
      }

      // Request exact alarm permission for Android 12 and above
      if (_androidVersion != null && _androidVersion! >= 31) {
        if (await Permission.scheduleExactAlarm.isRestricted) {
          await Permission.scheduleExactAlarm.request();
        }
      }
    } catch (e) {
      _logger.e('Error checking permissions: $e');
    }
  }

  Future<void> _checkNotificationSettings() async {
    _isNotificationsEnabled.value = true ?? false;
    _isTorchEnabled.value = await Permission.camera.isGranted;
  }

  Future<void> requestBatteryOptimizationPermission() async {
    if (!_hasIgnoreBatteryOptimization.value) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      _hasIgnoreBatteryOptimization.value = status.isGranted;

      if (status.isGranted) {
        Get.snackbar(
          'success'.tr,
          'battery_optimization_disabled'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'warning'.tr,
          'battery_optimization_warning'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  Future<bool> requestPermissions() async {
    // First request battery optimization
    await requestBatteryOptimizationPermission();

    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    if (!allGranted) {
      Get.snackbar(
        'permission_required'.tr,
        'grant_permissions_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }

    return allGranted;
  }

  Future<void> scheduleTorchTask(DateTime scheduledTime) async {
    if (!await requestPermissions()) {
      return;
    }

    // Additional check for battery optimization
    if (!_hasIgnoreBatteryOptimization.value) {
      Get.dialog(
        AlertDialog(
          title: Text('battery_optimization'.tr),
          content: Text('battery_optimization_recommendation'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _scheduleTask(scheduledTime);
              },
              child: Text('skip'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await requestBatteryOptimizationPermission();
                _scheduleTask(scheduledTime);
              },
              child: Text('disable_battery_optimization'.tr),
            ),
          ],
        ),
      );
    } else {
      await _scheduleTask(scheduledTime);
    }
  }

  Future<void> _scheduleTask(DateTime scheduledTime) async {
    final now = DateTime.now();
    var targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final Duration initialDelay = targetTime.difference(now);

    try {
      await Workmanager().registerOneOffTask(
        'flashTorch${targetTime.millisecondsSinceEpoch}',
        'toggleTorch',
        initialDelay: initialDelay,
        inputData: {'turnOn': true},
      );

      _selectedTime.value = targetTime;
      _isScheduled.value = true;

    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'schedule_torch_error'.tr.trParams({'error': e.toString()}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> cancelScheduledTask() async {
    try {
      await Workmanager().cancelAll();
      _isScheduled.value = false;
      _selectedTime.value = null;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'cancel_tasks_error'.tr.trParams({'error': e.toString()}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> scheduleReminder(ReminderModel reminder, String title, String body, {bool useTorch = false}) async {
    try {
      // Ensure notifications are enabled
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        final userResponse = await Get.dialog<bool>(
          AlertDialog(
            title: Text('notifications_permission'.tr),
            content: Text('notifications_permission_message'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: Text('enable'.tr),
              ),
            ],
          ),
        );

        if (userResponse == true) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          Get.snackbar(
            'warning'.tr,
            'notifications_required'.tr,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Handle torch availability
      if (useTorch) {
        final isTorchAvailable = await TorchLight.isTorchAvailable();
        if (!isTorchAvailable || !_isTorchEnabled.value) {
          Get.snackbar(
            'warning'.tr,
            'torch_not_available'.tr,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          useTorch = false;
        }
      }

      // Calculate next reminder time
      DateTime nextReminderTime = reminder.dateTime;
      
      // Ensure the reminder time is in the future
      final now = DateTime.now();
      if (nextReminderTime.isBefore(now)) {
        if (reminder.frequency!.type == ReminderFrequency.custom) {
          nextReminderTime = reminder.frequency!.generateNextDate();
        } else {
          nextReminderTime = nextReminderTime.add(const Duration(days: 1));
        }
      }

      // Prepare notification payload
      final payload = {
        'reminderId': reminder.id,
        'medicationId': reminder.medicationId,
        'time': nextReminderTime.toIso8601String(),
      };

      // Schedule the notification with proper configuration
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminder.hashCode,
          channelKey: 'medication_reminders',
          title: title,
          body: body,
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.Default,
          criticalAlert: true,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          displayOnForeground: true,
          displayOnBackground: true,
          payload: payload,
        ),
        schedule: NotificationCalendar(
          hour: nextReminderTime.hour,
          minute: nextReminderTime.minute,
          second: 0,
          millisecond: 0,
          repeats:reminder.frequency!.type == ReminderFrequency.daily ? true :false,
          allowWhileIdle: true,
          preciseAlarm: true,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier()
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'take',
            label: 'take'.tr,
            actionType: ActionType.Default,
            isDangerousOption: false,
          ),
          NotificationActionButton(
            key: 'skip',
            label: 'skip'.tr,
            actionType: ActionType.Default,
            isDangerousOption: false,
          ),
        ],
      );

      // Update the reminder with the new time
      final updatedReminder = reminder.copyWith(dateTime: nextReminderTime);
      await _updateReminderUseCase(updatedReminder);

      // Schedule torch if enabled
      if (useTorch) {
        await scheduleTorchTask(nextReminderTime);
      }

      _logger.d('Reminder scheduled successfully for ${nextReminderTime.toIso8601String()}');
    } catch (e) {
      _logger.e('Error scheduling reminder: $e');
      FirebaseFirestore.instance.collection('error').add({
        'error_type': 'schedule_reminder_error',
        'error_message': e.toString(),
        'reminder_id': reminder.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      Get.snackbar(
        'error'.tr,
        'schedule_reminder_error'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> handleNotificationAction(ReceivedAction action) async {
    try {
      if (action.payload == null) return;

      final reminderId = action.payload!['reminderId'];
      final reminder = await _getReminderUseCase.call(reminderId!);
      if (reminder == null) return;

      final currentDate = DateTime.now();
      final statusDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        reminder.dateTime.hour,
        reminder.dateTime.minute,
      );

      // Remove any existing status for the same day
      reminder.statusHistory.removeWhere((status) =>
        status.timestamp.year == currentDate.year &&
        status.timestamp.month == currentDate.month &&
        status.timestamp.day == currentDate.day
      );

      // Add new status based on action
      reminder.statusHistory.add(ReminderStatus(
        timestamp: statusDateTime,
        state: action.buttonKeyPressed == 'take' ? ReminderState.taken : ReminderState.skipped,
      ));

      // Sort status history
      reminder.statusHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update reminder
      await _updateReminderUseCase(reminder);

      // Schedule next reminder
      DateTime nextReminderTime;
      if (reminder.frequency!.type == ReminderFrequency.custom) {
        nextReminderTime = reminder.frequency!.generateNextDate();
      } else {
        nextReminderTime = reminder.dateTime.add(const Duration(days: 1));
      }

      // if( Get.currentRoute == '/dashboard'){
      //   if (!Get.isRegistered<CustomReminderController>()) {
      //     // إذا لم يكن مسجلًا، قم بتسجيله باستخدام `put` أو `lazyPut`
      //     Get.lazyPut(() => CustomReminderController(
      //       addReminderUseCase: Get.find(),
      //       getAllByDate: Get.find(),
      //       deleteMedicationRemindersUseCase: Get.find(),
      //       updateReminderUseCase: Get.find(),
      //       deleteReminderUseCase: Get.find(),
      //       allRemindersUseCase: Get.find(),
      //       allRemindersByMedicationsIdUseCase: Get.find(), getReminderUseCase: Get.find(),
      //     ));
      //   }
      //
      // final  _customReminderController = Get.find<CustomReminderController>();
      //   _customReminderController.getAllReminders()
      // }
      await scheduleReminder(
        reminder.copyWith(dateTime: nextReminderTime),
        '${'reminder_time'.tr} ${reminder.medicationName}',
        'it_is_time_to_take_your_medicine',
        useTorch: true
      );
    } catch (e) {
      _logger.e('Error handling notification action: $e');
      FirebaseFirestore.instance.collection('error').add({
        'error_type': 'notification_action_error',
        'error_message': e.toString(),
        'action': action.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }



}