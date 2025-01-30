import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Get.theme.colorScheme.primary,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() => ListView(
        children: [
          _buildHeader(),
          _buildTimingSection(),
          _buildNotificationSection(),
          _buildAppearanceSection(),
        ],
      )),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              size: 40,
              color: Get.theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Customize Your Experience',
            style: TextStyle(
              color: Get.theme.colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalize your medication reminders and app settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Get.theme.colorScheme.onPrimary.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSection() {
    return _buildSection(
      'Medication Timing',
      Icons.access_time,
      [
        _buildSliderTile(
          'Before Meal Minutes',
          controller.beforeMealMinutes.toDouble(),
          (value) => controller.updateBeforeMealMinutes(value.toInt()),
          '${controller.beforeMealMinutes} min',
        ),
        _buildSliderTile(
          'After Meal Minutes',
          controller.afterMealMinutes.toDouble(),
          (value) => controller.updateAfterMealMinutes(value.toInt()),
          '${controller.afterMealMinutes} min',
        ),
        _buildSliderTile(
          'After Wake Up Minutes',
          controller.afterWakeUpMinutes.toDouble(),
          (value) => controller.updateAfterWakeUpMinutes(value.toInt()),
          '${controller.afterWakeUpMinutes} min',
        ),
        _buildSliderTile(
          'Before Bed Minutes',
          controller.beforeBedMinutes.toDouble(),
          (value) => controller.updateBeforeBedMinutes(value.toInt()),
          '${controller.beforeBedMinutes} min',
        ),
        _buildTimeTile(
          'Wake Up Time',
          controller.wakeUpTime,
          () async {
            final time = await showTimePicker(
              context: Get.context!,
              initialTime: controller.getTimeOfDay(controller.wakeUpTime),
            );
            if (time != null) {
              controller.updateWakeUpTime(time);
            }
          },
        ),
        _buildTimeTile(
          'Bed Time',
          controller.bedTime,
          () async {
            final time = await showTimePicker(
              context: Get.context!,
              initialTime: controller.getTimeOfDay(controller.bedTime),
            );
            if (time != null) {
              controller.updateBedTime(time);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      'Notifications',
      Icons.notifications,
      [
        _buildSwitchTile(
          'Dark Mode',
          'Toggle dark theme',
          Icons.dark_mode,
          controller.darkMode,
          (value) => controller.toggleDarkMode(),
        ),
        _buildSwitchTile(
          'Enable Notifications',
          'Get reminded about your medications',
          Icons.notifications_active,
          controller.notificationsEnabled,
          (value) => controller.toggleNotifications(),
        ),
        _buildSwitchTile(
          'Sound',
          'Play sound with notifications',
          Icons.volume_up,
          controller.soundEnabled,
          (value) => controller.toggleSound(),
        ),
        _buildSwitchTile(
          'Vibration',
          'Vibrate with notifications',
          Icons.vibration,
          controller.vibrationEnabled,
          (value) => controller.toggleVibration(),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      'Appearance',
      Icons.palette,
      [
        _buildLanguageTile(),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile(String title, double value, Function(double) onChanged, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                label,
                style: TextStyle(
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: 60,
          divisions: 12,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimeTile(String title, String time, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.access_time),
        label: Text(
          time,
          style: TextStyle(
            color: Get.theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      secondary: Icon(
        icon,
        color: value ? Get.theme.colorScheme.primary : Get.theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButton<String>(
          value: controller.language,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Spanish')),
            DropdownMenuItem(value: 'fr', child: Text('French')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.updateLanguage(value);
            }
          },
        ),
      ),
    );
  }
}
