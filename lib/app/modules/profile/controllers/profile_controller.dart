import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/services/medication_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _logger = Logger();
  final _storage = GetStorage();
  final _imagePicker = ImagePicker();
  
  final user = Rx<UserModel>(UserModel(
    id: '',
    name: '',
    email: '',
    imageBase64: null,
  ));
  
  final isLoading = false.obs;
  final imageError = ''.obs;
  final selectedLanguage = 'en'.obs;
  final notificationsEnabled = true.obs;
  final flashEnabled = false.obs;
  final isFlashEnabled = false.obs;
  final areNotificationsEnabled = false.obs;

  // Settings
  final expiryDaysThreshold = 8.obs;
  final quantityThreshold = 5.obs;

  // Reminder settings
  final selectedExpiryReminderDays = 3.obs;
  final selectedQuantityReminderDays = 3.obs;
  final expiryReminderOptions = [3, 7, 14, 30];
  final quantityReminderOptions = [3, 7, 14, 30];

  final RxList<MedicationModel> prescriptionMedications = <MedicationModel>[].obs;
  final searchQuery = ''.obs;
  final filteredPrescriptionMedications = <MedicationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadSettings();
    loadPrescriptionMedications();
    _checkPermissions();
    ever(prescriptionMedications, (_) {
      searchPrescriptions(searchQuery.value);
    });
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final currentUser = await _authService.getLocalUser();
      if (currentUser != null) {
        // Load saved image from storage
        final savedImage = _storage.read<String>('user_image');
        
        user.value = user.value.copyWith(
          imageBase64: savedImage,
          name: currentUser.name ?? '',
          email: currentUser.email ?? '',
        );
      }
    } catch (e) {
      _logger.e('Error loading user profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadSettings() {
    selectedLanguage.value = _storage.read('language') ?? 'en';
    expiryDaysThreshold.value = _storage.read('expiryDaysThreshold') ?? 8;
    quantityThreshold.value = _storage.read('quantityThreshold') ?? 5;
    notificationsEnabled.value = _storage.read('notificationsEnabled') ?? true;
    flashEnabled.value = _storage.read('flashEnabled') ?? false;
    selectedExpiryReminderDays.value = _storage.read('expiry_reminder_days') ?? 3;
    selectedQuantityReminderDays.value = _storage.read('quantity_reminder_days') ?? 3;
  }

  Future<void> loadPrescriptionMedications() async {
    try {
      final medicationService = Get.find<MedicationService>();
      await medicationService.loadMedications();
      prescriptionMedications.value = medicationService.medications
          .where((med) => med.hasPrescription &&
                (med.prescriptionImage != null || med.prescriptionText?.isNotEmpty == true))
          .toList();
    } catch (e) {
      _logger.e('Error loading prescription medications: $e');
      Get.snackbar(
        'Error',
        'Failed to load prescriptions',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Check notification permission
      final notificationStatus = await Permission.notification.status;
      areNotificationsEnabled.value = notificationStatus.isGranted;

      // Check camera permission for flash
      final cameraStatus = await Permission.camera.status;
      isFlashEnabled.value = cameraStatus.isGranted;
    } catch (e) {
      _logger.e('Error checking permissions: $e');
    }
  }

  Future<void> updateProfile(String name) async {
    try {
      isLoading.value = true;
      final updatedUser = UserModel(
        id: user.value.id,
        name: name,
        email: user.value.email,
        imageBase64: user.value.imageBase64,
      );

      await _authService.updateUserProfile(updatedUser);
      user.update((val) {
        if (val != null) {
          val.name = name;
        }
      });
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
      );
      _logger.i('Profile updated successfully');
    } catch (e) {
      _logger.e('Error updating profile', error: e, stackTrace: StackTrace.current);
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        user.update((val) {
          if (val != null) {
            val.imageBase64 = base64Image;
          }
        });
        
        // Save to local storage
        await _storage.write('user_image', base64Image);
        
        // Update user profile
        await updateProfile(user.value.name!);
      }
    } catch (e) {
      _logger.e('Error picking image', error: e, stackTrace: StackTrace.current);
      imageError.value = 'Failed to pick image';
    }
  }

  void updateLanguage(String langCode) {
    selectedLanguage.value = langCode;
    _storage.write('language', langCode);
    Get.updateLocale(Locale(langCode));
  }

  void updateExpiryThreshold(int days) {
    expiryDaysThreshold.value = days;
    _storage.write('expiryDaysThreshold', days);
  }

  void updateQuantityThreshold(int quantity) {
    quantityThreshold.value = quantity;
    _storage.write('quantityThreshold', quantity);
    _updateNotificationSettings();
  }

  void toggleExpiryNotifications(bool enabled) {
    // expiryNotificationsEnabled.value = enabled;
    _storage.write('expiryNotificationsEnabled', enabled);
    _updateNotificationSettings();
  }

  void toggleQuantityNotifications(bool enabled) {
    // quantityNotificationsEnabled.value = enabled;
    _storage.write('quantityNotificationsEnabled', enabled);
    _updateNotificationSettings();
  }

  void _updateNotificationSettings() {
    try {
      // final notificationService = Get.find<NotificationService>();
      // notificationService.updateNotificationSettings(
      //   expiryDaysThreshold: expiryDaysThreshold.value,
      //   quantityThreshold: quantityThreshold.value,
      //   expiryEnabled: expiryNotificationsEnabled.value,
      //   quantityEnabled: quantityNotificationsEnabled.value,
      // );
    } catch (e) {
      _logger.e('Error updating notification settings: $e');
    }
  }

  void toggleNotifications(bool value) async {
    try {
      notificationsEnabled.value = value;
      _storage.write('notifications_enabled', value);
      // Handle notification permissions
      if (value) {
        // Add your notification permission request logic here
        _logger.i('Notifications enabled');
      } else {
        _logger.i('Notifications disabled');
      }
    } catch (e) {
      _logger.e('Error toggling notifications', error: e);
      Get.snackbar(
        'Error',
        'Failed to update notification settings',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  void toggleFlash(bool value) {
    try {
      flashEnabled.value = value;
      _storage.write('flash_enabled', value);
      _logger.i('Flash ${value ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error toggling flash', error: e);
      Get.snackbar(
        'Error',
        'Failed to update flash settings',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  Future<void> toggleFlashPermission(bool enable) async {
    try {
      if (enable) {
        final status = await Permission.camera.request();
        if (status.isGranted) {
          isFlashEnabled.value = true;
          // Enable flash in your camera service
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      } else {
        isFlashEnabled.value = false;
        // Disable flash in your camera service
      }
    } catch (e) {
      _logger.e('Error toggling flash: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle flash',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> toggleNotificationsPermission(bool enable) async {
    try {
      if (enable) {
        final status = await Permission.notification.request();
        if (status.isGranted) {
          areNotificationsEnabled.value = true;
          // Enable notifications in your notification service
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      } else {
        areNotificationsEnabled.value = false;
        // Disable notifications in your notification service
      }
    } catch (e) {
      _logger.e('Error toggling notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle notifications',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void logout() {
    try {
      _authService.signOut();
      user.value = UserModel(
        id: '',
        name: '',
        email: '',
        imageBase64: null,
      );
      _logger.i('User signed out successfully');
      Get.offAllNamed('/login');
    } catch (e) {
      _logger.e('Error signing out', error: e, stackTrace: StackTrace.current);
      Get.snackbar(
        'Error',
        'Failed to sign out',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    }
  }

  void searchPrescriptions(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredPrescriptionMedications.value = prescriptionMedications;
      return;
    }

    filteredPrescriptionMedications.value = prescriptionMedications
        .where((med) => 
          med.name.toLowerCase().contains(query.toLowerCase()) ||
          (med.prescriptionText?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  Future<void> removeProfileImage() async {
    try {
      isLoading.value = true;
      // Update user model with null image
      user.value = user.value.copyWith(imageBase64: null);
      
      // Save to storage
      await _storage.write('user_image', null);
      
      Get.snackbar(
        'success'.tr,
        'profile_updated'.tr,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      _logger.e('Error removing profile image: $e');
      Get.snackbar(
        'error'.tr,
        'update_failed'.tr,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeLanguage(String langCode) {
    try {
      selectedLanguage.value = langCode;
      Get.updateLocale(Locale(langCode));
      
      // Save language preference
      _storage.write('language', langCode);
      
      Get.snackbar(
        'success'.tr,
        'language_changed'.tr,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      _logger.e('Error changing language: $e');
      Get.snackbar(
        'error'.tr,
        'language_change_failed'.tr,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void onExpiryReminderDaysChanged(int days) {
    selectedExpiryReminderDays.value = days;
    _storage.write('expiry_reminder_days', days);
  }

  void onQuantityReminderDaysChanged(int days) {
    selectedQuantityReminderDays.value = days;
    _storage.write('quantity_reminder_days', days);
  }
}
