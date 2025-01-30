import 'package:get/get.dart';
import 'package:reminder/app/modules/routine/controllers/routine_controller.dart';

class RoutineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoutineController>(() => RoutineController());
  }
}
