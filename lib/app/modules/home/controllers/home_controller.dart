import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/settings_service.dart';
import '../../../data/services/routine_service.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxInt currentIndex = 0.obs;
  late final AuthService _authService;
  late final SettingsService _settingsService;
  late final RoutineService _routineService;
  late AnimationController animationController;
  late List<Animation<double>> iconAnimations;

  String get currentTitle {
    switch (currentIndex.value) {
      case 0:
        return 'dashboard'.tr;
      case 1:
        return 'medications'.tr;
      case 2:
        return 'profile'.tr;
      default:
        return 'Dashboard';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    iconAnimations = List.generate(
      4,
      (index) => Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            index * 0.2,
            index * 0.2 + 0.5,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize services
      _authService = Get.find<AuthService>();
      _settingsService = Get.find<SettingsService>();
      _routineService = Get.find<RoutineService>();

      // Load user data if available
      // final user = _authService.getLocalUser();
      // if (user != null) {
        // Load user-specific data
        // await _routineService.loadRoutines();
      // } else {
        // Handle non-logged in state
        // Get.offAllNamed('/login');
      // }
    } catch (e) {
      print('Error initializing services: $e');
      // Get.offAllNamed('/login');
    }
  }

  void signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      animationController.forward(from: 0);
    }
  }
}
