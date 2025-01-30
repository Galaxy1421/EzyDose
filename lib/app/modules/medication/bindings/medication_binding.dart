import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/data_resources/local_medication_data_source.dart';
import 'package:reminder/app/data/data_resources/local_reminder_data_source.dart';
import 'package:reminder/app/data/data_resources/remote_medication_data_source.dart';
import 'package:reminder/app/modules/medication/controllers/add_medication_controller.dart';
import 'package:reminder/app/modules/dashboard/controllers/custom_reminder_controller.dart';
import 'package:reminder/app/modules/medications/controllers/custom_medication_contoller.dart';
import '../../../data/repository/medication_repository.dart';
import '../../../data/repository/medication_repository_impl.dart';
import '../../../data/usecases/medication/add_medication_usecase.dart';
import '../../../data/usecases/medication/delete_medication_usecase.dart';
import '../../../data/usecases/medication/get_all_medications_by_uid_usecase.dart';
import '../../../data/usecases/medication/get_all_medications_usecase.dart';
import '../../../data/usecases/medication/update_medication_usecase.dart';
import '../../../services/custom_schulder_service.dart';
import '../controllers/medication_controller.dart';
import '../controllers/medication_reminder_controller.dart';
import '../../../data/services/medication_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/routine_service.dart';
import '../../../data/services/settings_service.dart';

class MedicationBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => Logger());
    Get.lazyPut<NotificationService>(() => NotificationService());
    Get.lazyPut<MedicationService>(() => MedicationService());
    Get.lazyPut(() => SettingsService());
    Get.lazyPut(() => RoutineService());
    Get.lazyPut(() => MedicationService());
    Get.lazyPut(() => MedicationController());



    Get.lazyPut<LocalMedicationDataSource>(() => LocalMedicationDataSourceImpl(),);
    Get.lazyPut<RemoteMedicationDataSource>(() => RemoteMedicationDataSourceImpl(),);
    Get.lazyPut(() => LocalReminderDatSourceImpl(),);
    Get.lazyPut<MedicationRepository>(() => MedicationRepositoryImpl(
    localMedicationDataSource: Get.find(),
    remoteMedicationDataSource: Get.find(),
    ));

    Get.lazyPut(() => GetAllMedicationsUseCase(Get.find()));
    Get.lazyPut(() => GetMedicationByIdUseCase(Get.find()));
    Get.lazyPut(() => AddMedicationUseCase(Get.find()));
    Get.lazyPut(() => UpdateMedicationUseCase(Get.find()));
    Get.lazyPut(() => DeleteMedicationUseCase(Get.find()));
    Get.lazyPut(() => GetMedicationUseCase(Get.find()));

    Get.putAsync(() => ScheduleService(Get.find(),Get.find()).init());

    Get.lazyPut(() => CustomMedicationController(addMedicationUseCase: Get.find(), updateMedicationUseCase: Get.find(), deleteMedicationUseCase: Get.find(), getAllMedicationsUseCase: Get.find(), getMedicationUseCase: Get.find()),);

    Get.lazyPut(() => AddMedicationController(),);
  }
}
