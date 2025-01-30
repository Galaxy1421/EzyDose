import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reminder/app/routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Container(

                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildSettingsSection(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() => GestureDetector(
                onTap: () => _showEditProfileSheet(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : ClipOval(
                          child: _buildProfileImage(controller.user.value.imageBase64),
                        ),
                ),
              )),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _showEditProfileSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
            controller.user.value.name?.isNotEmpty == true
                ? controller.user.value.name!
                : 'Login Required',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Text(
            controller.user.value.email?.isNotEmpty == true
                ? controller.user.value.email!
                : 'Please login to access your profile',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          )),
        ],
      ),
    );
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: controller.user.value.name);
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'edit_profile'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  Obx(() => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: ClipOval(
                      child: _buildProfileImage(controller.user.value.imageBase64),
                    ),
                  )),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: InkWell(
                        onTap: () => _showImageOptions(),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'name'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.updateProfile(nameController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'save'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'settings'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.medical_information),
            title: Text('doctor_prescriptions'.tr),
            trailing: Icon(
              Get.locale?.languageCode == 'ar'
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => Get.toNamed('/doctor-prescriptions'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('notifications_profile'.tr),
            trailing: Icon(
              Get.locale?.languageCode == 'ar'
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => Get.toNamed('/notifications'),
          ),
          const Divider(height: 1),
          ListTile(
            leading:Icon(Icons.hourglass_bottom_outlined),
            title: Text('routine'.tr),
            trailing: Icon(
              Get.locale?.languageCode == 'ar'
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => Get.toNamed(Routes.ROUTINE),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text('history'.tr),
            trailing: Icon(
              Get.locale?.languageCode == 'ar'
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () => Get.toNamed('/history'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('language'.tr),
            trailing: DropdownButton<String>(
              value: controller.selectedLanguage.value,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('english'.tr),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('arabic'.tr),
                ),
              ],
              onChanged: (value) {
                if (value != null) controller.changeLanguage(value);
              },
            ),
          ),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
            title: Text('enable_notifications'.tr),
            subtitle: Text('notification_description'.tr),
            activeColor: AppColors.primary,
            value: controller.areNotificationsEnabled.value,
            onChanged: (value) => controller.toggleNotificationsPermission(value),
          )),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
            title: Text('enable_flash'.tr),
            subtitle: Text('flash_description'.tr),
            activeColor: AppColors.primary,
            value: controller.isFlashEnabled.value,
            onChanged: (value) => controller.toggleFlashPermission(value),
          )),
          const Divider(height: 1),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedExpiryReminderDays.value,
              decoration: InputDecoration(
                labelText: 'remind_before_expiry'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: controller.expiryReminderOptions.map((days) => DropdownMenuItem(
                value: days,
                child: Text('$days ${'days'.tr}'),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.onExpiryReminderDaysChanged(value);
                }
              },
            )),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => DropdownButtonFormField<int>(
              value: controller.selectedQuantityReminderDays.value,
              decoration: InputDecoration(
                labelText: 'remind_before_quantity_low'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: controller.quantityReminderOptions.map((days) => DropdownMenuItem(
                value: days,
                child: Text('$days ${'days'.tr}'),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.onQuantityReminderDaysChanged(value);
                }
              },
            )),
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('logout'.tr),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
        AlertDialog(
          title: Text(
            Get.locale?.languageCode == 'ar' ? 'تأكيد تسجيل الخروج' : 'Confirm Logout',
          ),
          content: Text(
            Get.locale?.languageCode == 'ar' ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟' : 'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                Get.locale?.languageCode == 'ar' ? 'لا' : 'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                Get.locale?.languageCode == 'ar' ? 'نعم' : 'Yes',
              ),
            ),
          ],
        )

      // AlertDialog(
      //   title: Text('confirm_logout'.tr),
      //   content: Text('logout_message'.tr),
      //   actions: [
      //     TextButton(
      //       onPressed: () => Get.back(),
      //       child: Text('no'.tr),
      //     ),
      //     ElevatedButton(
      //       onPressed: () {
      //         Get.back();
      //         controller.logout();
      //       },
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: Colors.red,
      //         foregroundColor: Colors.white,
      //       ),
      //       child: Text('yes'.tr),
      //     ),
      //   ],
      // ),
    );
  }

  void _showImageOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('take_photo'.tr),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('choose_from_gallery'.tr),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
            if (controller.user.value.imageBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('remove_photo'.tr),
                onTap: () {
                  Get.back();
                  controller.removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) {
      return Icon(
        Icons.person,
        size: 60,
        color: AppColors.primary,
      );
    }

    if (imageSource.startsWith('http')) {
      // Handle URL-based images (e.g., Google profile photos)
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 60,
            color: AppColors.primary,
          );
        },
      );
    } else {
      // Handle base64 images
      try {
        return Image.memory(
          base64Decode(imageSource),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            );
          },
        );
      } catch (e) {
        return Icon(
          Icons.person,
          size: 60,
          color: AppColors.primary,
        );
      }
    }
  }
}
