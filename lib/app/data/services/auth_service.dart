import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      this.user.value = user;
    });
  }

  @override
  Future<AuthService> init() async {
    await _initializeAuth();
    return this;
  }

  Future<void> _initializeAuth() async {
    // Add initialization code here if needed
  }

  // Create user in Firestore
  Future<void> _createUserInFirestore(UserModel userModel) async {
    try {
      final userDoc = _firestore.collection('users').doc(userModel.id);
      
      // Check if user exists
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        // Create new user document
        await userDoc.set(userModel.toJson());
        _logger.i('User created in Firestore successfully');
      } else {
        // Update existing user document
        await userDoc.update({
          'name': userModel.name,
          'email': userModel.email,
          'photoUrl': userModel.imageBase64,
          'imageBase64': userModel.imageBase64,
        });
        _logger.i('User updated in Firestore successfully');
      }
    } catch (e) {
      _logger.e('Error creating/updating user in Firestore', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      isLoading.value = true;
      
      // Create auth user
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        
        // Create Firestore user
        final userModel = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          imageBase64: userCredential.user!.photoURL,
        );

        await _createUserInFirestore(userModel);
        await _saveUserLocally(userCredential.user!);
        
        // Get.snackbar(
        //   'Success',
        //   'Account created successfully!',
        //   backgroundColor: Colors.green.withOpacity(0.1),
        //   colorText: Colors.green,
        //   duration: const Duration(seconds: 2),
        // );

        SnackbarService().showSuccess(AppHelper.isArabic ? "تم إنشاء الحساب بنجاح!" : "Account created successfully!");
        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error during sign up',
        error: e,
        stackTrace: StackTrace.current,
        time: DateTime.now(),
      );
      // String message =AppHelper.isArabic?'': 'An error occurred';
      // switch (e.code) {
      //   case 'weak-password':
      //     message = AppHelper.isArabic?'':'The password provided is too weak';
      //     break;
      //   case 'email-already-in-use':
      //     message = AppHelper.isArabic?'':'An account already exists for this email';
      //     break;
      //   default:
      //     message = e.message ?? 'An error occurred';
      // }
      String message = AppHelper.isArabic ? 'حدث خطأ' : 'An error occurred';
      switch (e.code) {
        case 'weak-password':
          message = AppHelper.isArabic
              ? 'كلمة المرور التي أدخلتها ضعيفة جدًا'
              : 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = AppHelper.isArabic
              ? 'يوجد حساب مسجل بالفعل بهذا البريد الإلكتروني'
              : 'An account already exists for this email';
          break;
        default:
          message = AppHelper.isArabic
              ? (e.message ?? 'حدث خطأ')
              : (e.message ?? 'An error occurred');
      }

      SnackbarService().showError(message);

      // Get.snackbar(
      //   'Error',
      //   message,
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      return null;
    } catch (e) {
      _logger.e('Unexpected error during sign up',
        error: e,
        stackTrace: StackTrace.current,
      );
      SnackbarService().showError(AppHelper.isArabic ? "حدث خطأ غير متوقع" : "An unexpected error occurred");

      // Get.snackbar(
      //   'Error',
      //   'An unexpected error occurred',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Check and update Firestore user
        final userModel = UserModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName,
          email: userCredential.user!.email,
          imageBase64: userCredential.user!.photoURL,
        );

        await _createUserInFirestore(userModel);
        await _saveUserLocally(userCredential.user!);
        SnackbarService().showSuccess(AppHelper.isArabic ? "مرحباً بعودتك!" : "Welcome back!");

        // Get.snackbar(
        //   'Success',
        //   'Welcome back!',
        //   backgroundColor: Colors.green.withOpacity(0.1),
        //   colorText: Colors.green,
        //   duration: const Duration(seconds: 2),
        // );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error during sign in',
        error: e,
        stackTrace: StackTrace.current,
      );
      // String message = 'An error occurred';
      // switch (e.code) {
      //   case 'user-not-found':
      //     message = 'No user found for this email';
      //     break;
      //   case 'wrong-password':
      //     message = 'Wrong password provided';
      //     break;
      //   default:
      //     message = e.message ?? 'An error occurred';
      // }
      String message = AppHelper.isArabic ? 'حدث خطأ' : 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = AppHelper.isArabic
              ? 'لا يوجد مستخدم مرتبط بهذا البريد الإلكتروني'
              : 'No user found for this email';
          break;
        case 'wrong-password':
          message = AppHelper.isArabic
              ? 'كلمة المرور التي أدخلتها غير صحيحة'
              : 'Wrong password provided';
          break;
        default:
          message = AppHelper.isArabic
              ? (e.message ?? 'حدث خطأ')
              : (e.message ?? 'An error occurred');
      }
      SnackbarService().showError(message);

      // Get.snackbar(
      //   'Error',
      //   message,
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      return null;
    } catch (e) {
      _logger.e('Unexpected error during sign in',
        error: e,
        stackTrace: StackTrace.current,
      );
      SnackbarService().showError(AppHelper.isArabic ? "حدث خطأ غير متوقع" : "An unexpected error occurred");

      // Get.snackbar(
      //   'Error',
      //   'An unexpected error occurred',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Create/Update Firestore user
        final userModel = UserModel(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName,
          email: userCredential.user!.email,
          imageBase64: userCredential.user!.photoURL,
        );

        await _createUserInFirestore(userModel);
        await _saveUserLocally(userCredential.user!);

        SnackbarService().showSuccess(
            AppHelper.isArabic
                ? "تم تسجيل الدخول باستخدام Google بنجاح!"
                : "Signed in with Google successfully!"
        );

        // Get.snackbar(
        //   'Success',
        //   'Signed in with Google successfully!',
        //   backgroundColor: Colors.green.withOpacity(0.1),
        //   colorText: Colors.green,
        //   duration: const Duration(seconds: 2),
        // );
      }

      return userCredential;
    } catch (e) {
      _logger.e('Error during Google sign in',
        error: e,
        stackTrace: StackTrace.current,
      );

      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل تسجيل الدخول باستخدام Google: ${e.toString()}"
              : "Failed to sign in with Google: ${e.toString()}"
      );

      // Get.snackbar(
      //   'Error',
      //   'Failed to sign in with Google: ${e.toString()}',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Save user data locally
  Future<void> _saveUserLocally(User firebaseUser) async {
    try {
      final userModel = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        imageBase64: firebaseUser.photoURL,
      );

      // Save user ID for reference
      await _storage.write('current_user_id', firebaseUser.uid);
      
      // Save user data
      await _storage.write('user_${firebaseUser.uid}', userModel.toJson());
      
      _logger.d('User data saved locally');
    } catch (e) {
      _logger.e('Error saving user locally',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Get local user data
  UserModel? getLocalUser() {
    try {
      final String? userId = _storage.read('current_user_id');
      if (userId == null) {
        _logger.d('No local user ID found');
        return null;
      }

      final userData = _storage.read('user_${user.value!.uid}');
      if (userData == null) {
        _logger.d('No user data found for ID: $userId');
        return null;
      }
      return UserModel.fromJson(userData);
    } catch (e) {
      _logger.e('Error getting local user',
          error: e, stackTrace: StackTrace.current);
      return null;
    }
  }

  // Clear local user data
  Future<void> _clearLocalUser() async {
    try {
      await _storage.erase();
      _logger.i('Local user data cleared');
    } catch (e) {
      _logger.e('Error clearing local user data',
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _clearLocalUser();
      _logger.i('User signed out successfully');
      SnackbarService().showSuccess(
          AppHelper.isArabic
              ? "تم تسجيل الخروج بنجاح"
              : "Signed out successfully"
      );

      // Get.snackbar(
      //   'Success',
      //   'Signed out successfully',
      //   backgroundColor: Colors.green.withOpacity(0.1),
      //   colorText: Colors.green,
      //   duration: const Duration(seconds: 2),
      // );
    } catch (e) {
      _logger.e('Error during sign out',
        error: e,
        stackTrace: StackTrace.current,
      );
      // Get.snackbar(
      //   'Error',
      //   'Failed to sign out: ${e.toString()}',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل تسجيل الخروج: ${e.toString()}"
              : "Failed to sign out: ${e.toString()}"
      );

    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent successfully');
      // Get.snackbar(
      //   'Success',
      //   'Password reset link has been sent to your email',
      //   backgroundColor: Colors.green.withOpacity(0.1),
      //   colorText: Colors.green,
      //   duration: const Duration(seconds: 3),
      // );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // SnackbarService().showSuccess('Password reset link has been sent to your email');
        SnackbarService().showSuccess(
            AppHelper.isArabic
                ? "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"
                : "Password reset link has been sent to your email"
        );
      });

      // SnackbarService().showSuccess(
      //     AppHelper.isArabic
      //         ? "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"
      //         : "Password reset link has been sent to your email"
      // );


      return true;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error during password reset',
        error: e,
        stackTrace: StackTrace.current,
      );
      // String message = 'Failed to send reset email';
      // switch (e.code) {
      //   case 'user-not-found':
      //     message = 'No user found for this email';
      //     break;
      //   case 'invalid-email':
      //     message = 'Invalid email address';
      //     break;
      //   default:
      //     message = e.message ?? 'Failed to send reset email';
      // }
      // Get.snackbar(
      //   'Error',
      //   message,
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      String message = AppHelper.isArabic ? 'فشل في إرسال بريد إعادة تعيين كلمة المرور' : 'Failed to send reset email';
      switch (e.code) {
        case 'user-not-found':
          message = AppHelper.isArabic
              ? 'لا يوجد مستخدم مرتبط بهذا البريد الإلكتروني'
              : 'No user found for this email';
          break;
        case 'invalid-email':
          message = AppHelper.isArabic
              ? 'عنوان البريد الإلكتروني غير صالح'
              : 'Invalid email address';
          break;
        default:
          message = AppHelper.isArabic
              ? (e.message ?? 'فشل في إرسال بريد إعادة تعيين كلمة المرور')
              : (e.message ?? 'Failed to send reset email');
      }

      SnackbarService().showError(message);

      return false;
    } catch (e) {
      _logger.e('Unexpected error during password reset',
        error: e,
        stackTrace: StackTrace.current,
      );
      // Get.snackbar(
      //   'Error',
      //   'Failed to send reset email: ${e.toString()}',
      //   backgroundColor: Colors.red.withOpacity(0.1),
      //   colorText: Colors.red,
      //   duration: const Duration(seconds: 3),
      // );
      SnackbarService().showError(
          AppHelper.isArabic
              ? "فشل في إرسال بريد إعادة تعيين كلمة المرور: ${e.toString()}"
              : "Failed to send reset email: ${e.toString()}"
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;

      // Save locally
      await _storage.write('user_${updatedUser.id}', updatedUser.toJson());
      
      // Update in Firestore
      // await _firestore
      //     .collection('users')
      //     .doc(updatedUser.id)
      //     .set(updatedUser.toJson());

      _logger.i('User profile updated successfully');
    } catch (e) {
      _logger.e('Error updating user profile',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile image using base64
  Future<void> updateProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Limit image size
        maxHeight: 512,
        imageQuality: 70, // Reduce quality to keep base64 string smaller
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        if (user.value != null) {
          final updatedUser = UserModel(
            id: user.value!.uid,
            name: user.value!.displayName,
            email: user.value!.email,
            imageBase64: base64Image,
          );
          
          await _updateUser(updatedUser);
        }
      }
    } catch (e) {
      _logger.e('Error updating profile image',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Future<void> _updateUser(UserModel user) async {
    try {
      // Save to local storage
      await _storage.write('user_${user.id}', user.toJson());
      
      // Update Firestore user data
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
      _logger.i('User data updated successfully');
    } catch (e) {
      _logger.e('Error updating user data',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Helper method to get image widget from base64
  Widget getProfileImage() {
    final String? imageBase64 = _storage.read('user_${user.value!.uid}');
    if (imageBase64 != null) {
      try {
        // final userData = UserModel.fromJson(imageBase64);
        final bytes = base64Decode(imageBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            _logger.e('Error loading profile image',
              error: error,
              stackTrace: stackTrace,
            );
            return const Icon(Icons.person);
          },
        );
      } catch (e) {
        _logger.e('Error decoding base64 profile image',
          error: e,
          stackTrace: StackTrace.current,
        );
        return const Icon(Icons.person);
      }
    }
    return const Icon(Icons.person);
  }
}
