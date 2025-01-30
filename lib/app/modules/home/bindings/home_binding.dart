import 'package:get/get.dart';
import 'package:reminder/app/data/services/medication_service.dart';
import 'package:reminder/app/data/services/routine_service.dart';
import 'package:reminder/app/modules/medication/controllers/medication_controller.dart';
import 'package:reminder/app/modules/routine/controllers/routine_controller.dart';
import '../../../data/services/notification_service.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../medications/controllers/medications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<RoutineService>(() => RoutineService());
    Get.lazyPut<RoutineController>(() => RoutineController());
    Get.lazyPut<MedicationService>(() => MedicationService());
    Get.lazyPut<MedicationController>(() => MedicationController());
    Get.lazyPut<NotificationService>(() => NotificationService());
    Get.lazyPut<MedicationsController>(() => MedicationsController());
  }
}
