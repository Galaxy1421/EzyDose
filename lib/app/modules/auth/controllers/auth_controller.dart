import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  RxBool isLoading = false.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    isLoading.value = true;
    final user = await _authService.signUpWithEmail(email, password, name);
    isLoading.value = false;
    if (user != null) {
      currentUser.value = user;
      Get.offAllNamed(Routes.HOME);
      return true;
    }
    return false;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    final result = await _authService.signInWithEmail(email, password);
    isLoading.value = false;
    if (result != null) {
      Get.offAllNamed(Routes.HOME);
      return true;
    }
    return false;
  }

  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    final result = await _authService.signInWithGoogle();
    isLoading.value = false;
    if (result != null) {
      Get.offAllNamed(Routes.HOME);
      return true;
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    isLoading.value = true;
    final result = await _authService.resetPassword(email);
    isLoading.value = false;
    return result;
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
