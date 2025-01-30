import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:reminder/app/data/data_resources/local_reminder_data_source.dart';
import 'package:reminder/app/data/data_resources/remote_reminder_data_source.dart';
import 'package:reminder/app/data/repository/reminder_repository.dart';
import 'package:reminder/app/data/repository/reminder_repository_impl.dart';
import 'package:reminder/app/data/usecases/reminder/add_reminder_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/delete_reminder_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/get_all_reminders_by_medcations_id_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/get_all_reminders_usecase.dart';
import 'package:reminder/app/data/usecases/reminder/update_reminder_usecase.dart';
import 'package:reminder/app/modules/dashboard/controllers/custom_reminder_controller.dart';

class ReminderBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocalReminderDatSourceImpl
    Get.lazyPut<LocalReminderDataSource>(() => LocalReminderDatSourceImpl());

    // Register RemoteReminderDatSourceImpl (if you're using it)
    Get.lazyPut<RemoteReminderDataSource>(() => RemoteReminderDatSourceImpl());

    // Register ReminderRepository
    Get.lazyPut<ReminderRepository>(() => ReminderRepositoryImpl(
      localReminderDatSource: LocalReminderDatSourceImpl(),
      remoteReminderDatSource: RemoteReminderDatSourceImpl(),
    ));

    // Register UseCases
    Get.lazyPut(() => AddReminderUseCase(repository: Get.find()));
    Get.lazyPut(() => DeleteReminderUsecase(repository: Get.find()));
    Get.lazyPut(() => DeleteMedicationRemindersUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateReminderUseCase(repository: Get.find()));
    Get.lazyPut(() => GetAllRemindersByMedicationsIdUseCase(repository: Get.find()));
    Get.lazyPut(() => GetAllRemindersUsecase(repository: Get.find()));
    Get.lazyPut(() => GetAllRemindersByDateUsecase(repository: Get.find()));
    Get.lazyPut(() => GetReminderUseCase(repository: Get.find()));

    // Register CustomReminderController
    Get.lazyPut(() => CustomReminderController(
      addReminderUseCase: Get.find(),
      getAllByDate: Get.find(),
      deleteMedicationRemindersUseCase: Get.find(),
      updateReminderUseCase: Get.find(),
      deleteReminderUseCase: Get.find(),
      allRemindersUseCase: Get.find(),
      allRemindersByMedicationsIdUseCase: Get.find(), getReminderUseCase: Get.find(),
    ));

    Get.lazyPut(() => FirebaseAuth.instance,);
    Get.lazyPut(() => FirebaseFirestore.instance,);
  }
}