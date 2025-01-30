part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const ADD_MEDICATION = _Paths.ADD_MEDICATION;
  static const EDIT_MEDICATION = _Paths.EDIT_MEDICATION;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const MEDICATIONS = _Paths.MEDICATIONS;
  static const HISTORY = _Paths.HISTORY;
  static const ROUTINE = _Paths.ROUTINE;
  static const PROFILE = _Paths.PROFILE;
  static const DOCTOR_PRESCRIPTIONS = _Paths.DOCTOR_PRESCRIPTIONS;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;

  static const INITIAL = _Paths.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () =>  SplashView(),
      // binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () =>  LoginView(),
      // binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.ROUTINE,
      page: () =>  RoutineView(),
      binding: RoutineBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      bindings: [HomeBinding(),ReminderBinding(),MedicationBinding()],
    ),
    GetPage(
      name: Routes.ADD_MEDICATION,
      page: () => const AddMedicationView(),
      // binding: AddMedicationBinding(),
    ),
    // GetPage(
    //   name: Routes.EDIT_MEDICATION,
    //   page: () => const EditMedicationView(),
    //   binding: EditMedicationBinding(),
    // ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () =>  DashboardView(),
      // binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.MEDICATIONS,
      page: () =>  MedicationsView(),
        binding: MedicationBinding()
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      // binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.DOCTOR_PRESCRIPTIONS,
      page: () => const DoctorPrescriptionsView(),
      // binding: DoctorPrescriptionsBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      // binding: NotificationsBinding(),
    ),
  ];
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const ADD_MEDICATION = '/add-medication';
  static const EDIT_MEDICATION = '/edit-medication';
  static const DASHBOARD = '/dashboard';
  static const MEDICATIONS = '/medications';
  static const HISTORY = '/history';
  static const ROUTINE = '/routine';
  static const PROFILE = '/profile';
  static const DOCTOR_PRESCRIPTIONS = '/doctor-prescriptions';
  static const NOTIFICATIONS = '/notifications';
}
