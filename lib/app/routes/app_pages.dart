import 'package:get/get.dart';
import 'package:reminder/app/modules/dashboard/binding/dashbord_binding.dart';
import 'package:reminder/app/modules/medication/bindings/medication_binding.dart';
import 'package:reminder/app/modules/splash/binding/splash_binding.dart';
import '../modules/medication/views/add_medication_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/doctor_prescriptions/bindings/doctor_prescriptions_binding.dart';
import '../modules/doctor_prescriptions/views/doctor_prescriptions_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/medications/views/medications_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/routine/bindings/routine_binding.dart';
import '../modules/routine/views/routine_view.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () =>  SplashView(),
      binding: SplashBinding()
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      bindings: [HomeBinding(),ReminderBinding(),MedicationBinding()],
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () =>  LoginView(),
      // binding: AuthB(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () =>  SignupView(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () =>  ForgotPasswordView(),
    ),
    GetPage(
      name: _Paths.ADD_MEDICATION,
      page: () => const AddMedicationView(),
      binding: MedicationBinding(),
    ),
    // GetPage(
    //   name: _Paths.EDIT_MEDICATION,
    //   page: () => const EditMedicationView(),
    // ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () =>  DashboardView(),
      binding: ReminderBinding()
    ),
    GetPage(
      name: _Paths.MEDICATIONS,
      page: () =>  MedicationsView(),
      binding: MedicationBinding()
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.ROUTINE,
      page: () => const RoutineView(),
      binding: RoutineBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DOCTOR_PRESCRIPTIONS,
      page: () => const DoctorPrescriptionsView(),
      binding: DoctorPrescriptionsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
  ];
}
