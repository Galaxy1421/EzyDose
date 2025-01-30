import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';
import 'package:logger/logger.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _storage = GetStorage();
  final _logger = Logger();
  
  RxInt currentPage = 0.obs;
  RxBool isLoading = true.obs;
  final pageController = PageController();

  static const String _firstLaunchKey = 'is_first_launch';

  @override
  void onInit() {
    super.onInit();
    checkAuthAndNavigate();
  }

  Future<void> checkAuthAndNavigate() async {
    try {
      isLoading.value = true;
      
      // Add a small delay for smoother transition
      await Future.delayed(const Duration(seconds: 2));

      // Check if this is first launch
      final isFirstLaunch = _storage.read(_firstLaunchKey) ?? true;
      
      if (!isFirstLaunch) {
        // Not first launch, check auth status
        final user = _authService.getLocalUser();
        if (user != null) {
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
        return;
      }

      // First launch, show onboarding
      _storage.write(_firstLaunchKey, false);
      isLoading.value = false;
      
    } catch (e) {
      _logger.e('Error in splash navigation', error: e, stackTrace: StackTrace.current);
      // On error, default to home
      Get.offAllNamed(Routes.HOME);
    }
  }

  void updatePage(int index) {
    currentPage.value = index;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      skip();
    }
  }

  void skip() {
    Get.offAllNamed('/login');
  }

  void onGetStarted() {
    // After onboarding, check auth status
    final user = _authService.getLocalUser();
    if (user != null) {
       _loadUserData();
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _loadUserData() async {
    // Add implementation to load user data
  }
}
