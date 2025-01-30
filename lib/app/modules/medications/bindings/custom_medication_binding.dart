import 'package:get/get.dart';
import '../controllers/custom_medication_controller.dart';
import '../../../data/services/medication_service.dart';
import '../../../data/services/reminder_service.dart';
import '../../../data/services/routine_service.dart';
import '../../../data/services/notification_service.dart';

class CustomMedicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicationService>(() => MedicationService());
    Get.lazyPut<ReminderService>(() => ReminderService());
    Get.lazyPut<RoutineService>(() => RoutineService());
    Get.lazyPut<NotificationService>(() => NotificationService());
    Get.lazyPut<CustomMedicationController>(() => CustomMedicationController());
  }
}
