import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import '../models/routine_model.dart';
import 'auth_service.dart';

class RoutineService extends GetxService {
  static RoutineService get to => Get.find();
  final _storage = GetStorage();
  final _logger = Logger();
  final _authService = Get.find<AuthService>();
  
  final Rx<RoutineModel?> currentRoutine = Rx<RoutineModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoutine();
  }

  @override
  Future<RoutineService> init() async {
    return this;
  }

  String? _getCurrentUserId() {
    final user = _authService.getLocalUser();
    return user?.id;
  }

  RoutineModel? getRoutine() {
    return currentRoutine.value;
  }

  Future<void> loadRoutine() async {
    try {
      isLoading.value = true;
      final userId = _getCurrentUserId();
      if (userId == null) {
        _logger.w('No user logged in, cannot load routine');
        return;
      }

      final routineData = _storage.read('routine_$userId');
      if (routineData != null) {
        currentRoutine.value = RoutineModel.fromJson(routineData);
      } else {
        // Create default routine if none exists
        currentRoutine.value = RoutineModel(
          breakfastTime: '08:00',
          lunchTime: '13:00',
          dinnerTime: '19:00',
        );
        await saveRoutine(currentRoutine.value!);
        _logger.i('Created default routine for user: $userId');
      }
    } catch (e) {
      _logger.e('Error loading routine', error: e, stackTrace: StackTrace.current);
      // Get.snackbar(
      //   'Error',
      //   'Failed to load routine',
      //   backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.error,
      // );
      SnackbarService().showError(
        AppHelper.isArabic
            ? "فشل في تحميل الروتين"
            : "Failed to load routine",

      );

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveRoutine(RoutineModel newRoutine) async {
    try {
      isLoading.value = true;
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await _storage.write('routine_$userId', newRoutine.toJson());
      currentRoutine.value = newRoutine;
      
      _logger.i('Routine saved successfully');
      // Get.snackbar(
      //   'Success',
      //   'Routine saved successfully',
      //   backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.primary,
      // );
      SnackbarService().showSuccess(
        AppHelper.isArabic
            ? "تم حفظ الروتين بنجاح"
            : "Routine saved successfully",

      );

    } catch (e) {
      _logger.e('Error saving routine', error: e, stackTrace: StackTrace.current);
      // Get.snackbar(
      //   'Error',
      //   'Failed to save routine',
      //   backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.error,
      // );
      SnackbarService().showError(
        AppHelper.isArabic
            ? "فشل في حفظ الروتين"
            : "Failed to save routine",

      );

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRoutine(RoutineModel routine) async {
    try {
      isLoading.value = true;
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Ensure routine has an ID
      final updatedRoutine = routine.copyWith(
        id: routine.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        updatedAt: DateTime.now(),
      );
      
      // Save to local storage with user-specific key
      await _storage.write('routine_$userId', updatedRoutine.toJson());
      currentRoutine.value = updatedRoutine;
      
      _logger.i('Routine updated successfully');
      // Get.snackbar(
      //   'Success',
      //   'Routine updated successfully',
      //   backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.primary,
      // );
      SnackbarService().showSuccess(
        AppHelper.isArabic
            ? "تم تحديث الروتين بنجاح"
            : "Routine updated successfully",

      );

    } catch (e) {
      _logger.e('Error updating routine', error: e, stackTrace: StackTrace.current);
      // Get.snackbar(
      //   'Error',
      //   'Failed to update routine',
      //   backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.error,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في تحديث الروتين"
              : "Failed to update routine"
      );

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRoutine() async {
    try {
      isLoading.value = true;
      final userId = _getCurrentUserId();
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await _storage.remove('routine_$userId');
      currentRoutine.value = null;
      
      _logger.i('Routine deleted successfully');
      // Get.snackbar(
      //   'Success',
      //   'Routine deleted successfully',
      //   backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.primary,
      // );
      SnackbarService().showSuccess(
          AppHelper.isArabic
              ? "تم حذف الروتين بنجاح"
              : "Routine deleted successfully"
      );

    } catch (e) {
      _logger.e('Error deleting routine', error: e, stackTrace: StackTrace.current);
      // Get.snackbar(
      //   'Error',
      //   'Failed to delete routine',
      //   backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      //   colorText: Get.theme.colorScheme.error,
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في حذف الروتين"
              : "Failed to delete routine"
      );

      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
