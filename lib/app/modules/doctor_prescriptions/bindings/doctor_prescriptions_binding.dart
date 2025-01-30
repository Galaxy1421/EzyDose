import 'package:get/get.dart';
import '../controllers/doctor_prescriptions_controller.dart';

class DoctorPrescriptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorPrescriptionsController>(
      () => DoctorPrescriptionsController(),
    );
  }
}
