import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/routine_controller.dart';
import '../../../core/theme/app_colors.dart';

class RoutineView extends GetView<RoutineController> {
  const RoutineView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'daily_routine'.tr,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTimeSection(
                          title: 'wake_up_time'.tr,
                          icon: Icons.wb_sunny_outlined,
                          time: controller.currentRoutine.value?.wakeUpTime,
                          onTap: () => controller.updateWakeUpTime(),
                          color: const Color(0xFFFFB74D),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSection(
                          title: 'breakfast_time'.tr,
                          icon: Icons.free_breakfast_outlined,
                          time: controller.currentRoutine.value?.breakfastTime,
                          onTap: () => controller.updateBreakfastTime(),
                          color: const Color(0xFF4FC3F7),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSection(
                          title: 'lunch_time'.tr,
                          icon: Icons.lunch_dining_outlined,
                          time: controller.currentRoutine.value?.lunchTime,
                          onTap: () => controller.updateLunchTime(),
                          color: const Color(0xFF81C784),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSection(
                          title: 'dinner_time'.tr,
                          icon: Icons.dinner_dining_outlined,
                          time: controller.currentRoutine.value?.dinnerTime,
                          onTap: () => controller.updateDinnerTime(),
                          color: const Color(0xFFBA68C8),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeSection(
                          title: 'bed_time'.tr,
                          icon: Icons.bedtime_outlined,
                          time: controller.currentRoutine.value?.bedTime,
                          onTap: () => controller.updateBedTime(),
                          color: const Color(0xFF7986CB),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'routine_description'.tr,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection({
    required String title,
    required IconData icon,
    required String? time,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time ?? 'tap_to_set_time'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: time == null ? AppColors.textLight : color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Get.locale?.languageCode == 'ar' ? Icons.chevron_left : Icons.chevron_right,
                  color: color.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
