import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/routine_service.dart';
import '../../../data/models/routine_model.dart';

class RoutineController extends GetxController {
  final _routineService = Get.find<RoutineService>();
  
  Rx<RoutineModel?> get currentRoutine => _routineService.currentRoutine;
  RxBool get isLoading => _routineService.isLoading;

  Future<void> updateWakeUpTime() async {
    final TimeOfDay? time = await _selectTime();
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final current = currentRoutine.value;
      if (current != null) {
        await _routineService.updateRoutine(
          current.copyWith(wakeUpTime: timeString),
        );
      } else {
        await _routineService.updateRoutine(
          RoutineModel(wakeUpTime: timeString),
        );
      }
    }
  }

  Future<void> updateBreakfastTime() async {
    final TimeOfDay? time = await _selectTime();
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final current = currentRoutine.value;
      if (current != null) {
        await _routineService.updateRoutine(
          current.copyWith(breakfastTime: timeString),
        );
      } else {
        await _routineService.updateRoutine(
          RoutineModel(breakfastTime: timeString),
        );
      }
    }
  }

  Future<void> updateLunchTime() async {
    final TimeOfDay? time = await _selectTime();
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final current = currentRoutine.value;
      if (current != null) {
        await _routineService.updateRoutine(
          current.copyWith(lunchTime: timeString),
        );
      } else {
        await _routineService.updateRoutine(
          RoutineModel(lunchTime: timeString),
        );
      }
    }
  }

  Future<void> updateDinnerTime() async {
    final TimeOfDay? time = await _selectTime();
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final current = currentRoutine.value;
      if (current != null) {
        await _routineService.updateRoutine(
          current.copyWith(dinnerTime: timeString),
        );
      } else {
        await _routineService.updateRoutine(
          RoutineModel(dinnerTime: timeString),
        );
      }
    }
  }

  Future<void> updateBedTime() async {
    final TimeOfDay? time = await _selectTime();
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final current = currentRoutine.value;
      if (current != null) {
        await _routineService.updateRoutine(
          current.copyWith(bedTime: timeString),
        );
      } else {
        await _routineService.updateRoutine(
          RoutineModel(bedTime: timeString),
        );
      }
    }
  }

  Future<TimeOfDay?> _selectTime() async {
    return await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Get.theme.colorScheme.surface,
              hourMinuteTextColor: Get.theme.colorScheme.onSurface,
              dayPeriodTextColor: Get.theme.colorScheme.onSurface,
              dialHandColor: Get.theme.colorScheme.primary,
              dialBackgroundColor: Get.theme.colorScheme.surfaceVariant,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // Force sync with Firebase
  Future<void> syncWithFirebase() async {
    // await _routineService.syncWithFirebase();
  }

  // Create initial routine if none exists
  Future<void> createInitialRoutine(String userId) async {
    if (currentRoutine.value != null) return;

    final now = DateTime.now();
    // final routine = RoutineModel(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   userId: userId,
    //   wakeUpTime: DateTime(now.year, now.month, now.day, 7, 0), // 7:00 AM
    //   bedTime: DateTime(now.year, now.month, now.day, 22, 0), // 10:00 PM
    //   breakfastTime: DateTime(now.year, now.month, now.day, 8, 0), // 8:00 AM
    //   lunchTime: DateTime(now.year, now.month, now.day, 13, 0), // 1:00 PM
    //   dinnerTime: DateTime(now.year, now.month, now.day, 19, 0), // 7:00 PM
    //   updatedAt: now,
    // );
    //
    // await _routineService.saveRoutine(routine);
  }
}
