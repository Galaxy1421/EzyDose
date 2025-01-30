import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminder/app/data/data_resources/remote_reminder_data_source.dart';
import 'package:reminder/app/services/custom_interaction_service.dart';
import 'package:uuid/uuid.dart';
import 'app/data/services/interaction_service.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/language_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/services/custom_schulder_service.dart';
import 'app/translations/app_translations.dart';
import 'dart:io';

// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // HttpOverrides.global = new MyHttpOverrides();

  await Firebase.initializeApp();
  await GetStorage.init();


  await Permission.camera.request();
  await Permission.storage.request();

  // Initialize services
  await initServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Medication Reminder',
      translations: AppTranslations(),
      locale: Get.find<LanguageService>().languageCode == 'ar'
          ? const Locale('ar')
          : const Locale('en'),
      fallbackLocale: const Locale('en'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9F4376)),
        useMaterial3: true,
        fontFamily: Get.locale?.languageCode == 'ar' ? 'Cairo' : 'Roboto',

      ),
      initialRoute: Routes.INITIAL,
      getPages: AppPages.routes,

      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> initServices() async {
  try {
    // Initialize core services first
    await Get.putAsync(() => StorageService().init());
     Get.lazyPut(() => AuthController(),);
    await Get.putAsync(() => LanguageService().init());

    // Initialize other services - they will load their data in onInit
    // Get.put(MedicationService());
    Get.put(AuthService());
    Get.lazyPut(() => CustomInteractionService(),);
    Get.lazyPut(() => RemoteReminderDatSourceImpl());

    // Get.put(NotificationService());
    // Get.put(RoutineService());
    Get.put(InteractionService());
    // Get.put(ReminderService());
    // Get.put(AddMedicationController());

    print('All services initialized');
  } catch (e) {
    print('Error initializing services: $e');
    rethrow;
  }
}
