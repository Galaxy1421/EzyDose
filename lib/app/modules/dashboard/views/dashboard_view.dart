import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:reminder/app/core/helper.dart';
import 'package:reminder/app/core/snackbar_services.dart';
import 'package:reminder/app/data/models/medication_model.dart';
import 'package:reminder/app/modules/dashboard/controllers/custom_reminder_controller.dart';
import 'package:reminder/app/modules/medications/controllers/custom_medication_contoller.dart';
import 'package:reminder/app/modules/medications/controllers/medications_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/reminder_state.dart';
import '../../../data/models/reminder_status.dart';
import '../../../data/usecases/medication/get_all_medications_usecase.dart';
import '../../../routes/app_pages.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ والوقت

class DashboardView extends GetView<CustomReminderController> {
  DashboardView({Key? key}) : super(key: key);

  final CustomReminderController _customReminderController = Get.find();
  final CustomMedicationController _customMedicationController = Get.find();
  final GetMedicationUseCase getMedicationUseCase = Get.find();

  Color _getStatusColor(ReminderState state) {
    switch (state) {
      case ReminderState.pending:
        return Colors.blue;
      case ReminderState.taken:
        return Colors.green;
      case ReminderState.missed:
        return Colors.red;
      case ReminderState.skipped:
        return Colors.orange;
    }
  }
  final RefreshController refreshController = RefreshController();
  //
  @override
  Widget build(BuildContext context) {

    _customReminderController.getAllReminders();

    return Scaffold(
      backgroundColor: AppColors.background,
      body:  SmartRefresher(

        controller: refreshController,
        onRefresh: () async {
          // تحديث البيانات
          await controller.getAllRemindersByDate(controller.selectedDate.value);
          refreshController.refreshCompleted(); // إعلام SmartRefresher بأن التحديث اكتمل
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildDateList(),
              _buildRemindersList(),

            ],
          ),
        ),
      ),

    );
  }


  Widget _buildDateList() {
    return Container(
      height: 100,
      color: Colors.lightBlueAccent.withOpacity(.05),
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Obx(() {
        final selectedDate = controller.selectedDate.value;
        final dates = List.generate(
          14,
              (index) => DateTime.now().add(Duration(days: index)),
        );

        return ListView.builder(
          scrollDirection: Axis.horizontal,

          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final isSelected = date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;
            final isToday = date.year == DateTime
                .now()
                .year &&
                date.month == DateTime
                    .now()
                    .month &&
                date.day == DateTime
                    .now()
                    .day;
            final bool isRTL = Get.locale?.languageCode == 'ar';

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: Container(
                width: 60,
                margin: EdgeInsets.only(
                  // // left: index == 0 ? 20 : 0,
                  // right: 12,

                  left: isRTL ? (index == dates.length - 1 ? 20 : 12) : (index == 0 ? 13 : 0), // الهامش الأيسر بناءً على اللغة
                  right: isRTL ? (index == 0 ? 20 : 0) : (index == dates.length - 1 ? 20 : 12), // الهامش الأيمن بناءً على اللغة
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.1),
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: Card(
                  elevation: isSelected?2:0,
                  color: isSelected ? AppColors.primary : Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: isSelected?22:20,
                          fontWeight:isSelected? FontWeight.bold:FontWeight.normal,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }


  void _showStatusUpdateSheet(BuildContext context, ReminderModel reminder) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
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
                Expanded(
                  child: Text(
                    reminder.medicationName ?? 'reminder'.tr,
                    maxLines: 2,//
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // تقصير النص إذا كان طويلاً
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'time_format2'.tr,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  AppHelper.formatTimeBasedOnLanguage(DateTime.parse(reminder.dateTime.toString())),
                  // DateFormat('hh:mm a').format(reminder.dateTime),
                  style: const TextStyle(fontSize: 18,fontFamily: 'Roboto',fontWeight: FontWeight.bold),
                ),


              ],
            ),
            const SizedBox(height: 20),
            Text(
              'update_status'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton(
                  context,
                  reminder,
                  ReminderState.taken,
                  Icons.check_circle,
                  Colors.green,
                  'taken'.tr,
                ),
                const SizedBox(width: 10), // مسافة بين الأزرار
                _buildStatusButton(
                  context,
                  reminder,
                  ReminderState.skipped,
                  Icons.skip_next,
                  Colors.orange,
                  'skip'.tr,
                ),
                const SizedBox(width: 10), // مسافة بين الأزرار
                _buildStatusButton(
                  context,
                  reminder,
                  ReminderState.missed,
                  Icons.cancel,
                  Colors.red,
                  'miss'.tr,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildStatusButton(BuildContext context,
      ReminderModel reminder,
      ReminderState state,
      IconData icon,
      Color color,
      String label,) {
    return InkWell(
      onTap: () async {
        try {
          final selectedDate = controller.selectedDate.value;

          final statusDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            reminder.dateTime.hour,
            reminder.dateTime.minute,
          );

          reminder.statusHistory.removeWhere((status) =>
          status.timestamp.year == selectedDate.year &&
              status.timestamp.month == selectedDate.month &&
              status.timestamp.day == selectedDate.day
          );

          reminder.statusHistory.add(ReminderStatus(
            timestamp: statusDateTime,
            state: state,
          ));

          reminder.statusHistory.sort((a, b) =>
              a.timestamp.compareTo(b.timestamp)
          );

          await _customReminderController.updateReminder(reminder);
          await _customReminderController.getAllReminders();

          // Get.snackbar(
          //   'success'.tr,
          //   'status_updated'.tr,
          //   backgroundColor: color.withOpacity(0.1),
          //   colorText: color,
          //   duration: const Duration(seconds: 2),
          //   snackPosition: SnackPosition.BOTTOM,
          //   margin: const EdgeInsets.all(8),
          // );
          SnackbarService().showSuccess('status_updated'.tr);

          Get.back();
        } catch (e) {
          // Get.snackbar(
          //   'error'.tr,
          //   'error_updating_status'.tr,
          //   backgroundColor: Colors.red[100],
          //   colorText: Colors.red,
          //   duration: const Duration(seconds: 2),
          //   snackPosition: SnackPosition.BOTTOM,
          //   margin: const EdgeInsets.all(8),
          // );

          SnackbarService().showError('error_updating_status'.tr,);

        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildReminderCard(ReminderModel reminder) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;

      // Get status for the selected date
      final statusForDate = reminder.statusHistory.firstWhere(
            (status) =>
        status.timestamp.year == selectedDate.year &&
            status.timestamp.month == selectedDate.month &&
            status.timestamp.day == selectedDate.day,
        orElse: () => ReminderStatus(
          timestamp: reminder.dateTime,
          state: ReminderState.pending,
        ),
      );

      final currentState = statusForDate.state;
      final statusColor = _getStatusColor(currentState);

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor),
        ),
        child: InkWell(
          onTap: () => _showStatusUpdateSheet(Get.context!, reminder),
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: FutureBuilder<MedicationModel?>(
                        future: getMedicationUseCase.call(
                            reminder.medicationId ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data?.imageUrl == null) {
                            return const Icon(Icons.medication_outlined);
                          }

                          return GestureDetector(
                            onTap: () {
                              // عرض الصورة في مربع حوار عند النقر
                              AppDialog.showImageDialog(
                                  context, snapshot.data!.imageUrl!);
                            },
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data!.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.medicationName ?? 'reminder'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.blueGrey,
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                AppHelper.formatTimeBasedOnLanguage(
                                    DateTime.parse(reminder.dateTime.toString())),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: Get.locale?.languageCode == 'ar' ? 0 : null, // ملتصق بالحافة اليسرى إذا كانت اللغة عربية
                right: Get.locale?.languageCode == 'en' ? 0 : null, // ملتصق بالحافة اليمنى إذا كانت اللغة إنجليزية
                bottom: 0, // ملتصق بالحافة السفلية
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Get.locale?.languageCode == 'ar'
                          ? Radius.circular(12) // زاوية مستديرة في الأعلى يمين للعربية
                          : Radius.zero, // بدون زاوية للأعلى يمين للإنجليزية
                      bottomLeft: Get.locale?.languageCode == 'ar'
                          ? Radius.circular(12) // زاوية مستديرة في الأسفل يسار للعربية
                          : Radius.zero, // بدون زاوية للأسفل يسار للإنجليزية
                      topLeft: Get.locale?.languageCode == 'en'
                          ? Radius.circular(12) // زاوية مستديرة في الأعلى يسار للإنجليزية
                          : Radius.zero, // بدون زاوية للأعلى يسار للعربية
                      bottomRight: Get.locale?.languageCode == 'en'
                          ? Radius.circular(12) // زاوية مستديرة في الأسفل يمين للإنجليزية
                          : Radius.zero, // بدون زاوية للأسفل يمين للعربية
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // لجعل الصف يأخذ أقل مساحة ممكنة
                    children: [
                      Icon(
                        _getStatusIcon(currentState), // أيقونة الحالة
                        size: 16, // حجم الأيقونة
                        color: statusColor, // لون الأيقونة
                      ),
                      const SizedBox(width: 4), // مسافة بين الأيقونة والنص
                      Text(
                        _getStatusText(currentState),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    });
  }
  IconData _getStatusIcon(ReminderState state) {
    switch (state) {
      case ReminderState.pending:
        return Icons.schedule;
      case ReminderState.taken:
        return Icons.check_circle;
      case ReminderState.missed:
        return Icons.cancel;
      case ReminderState.skipped:
        return Icons.skip_next;
    }
  }

  String _getStatusText(ReminderState state) {

    switch (state) {
      case ReminderState.pending:
        return 'pending'.tr;
      case ReminderState.taken:
        return 'taken'.tr;
      case ReminderState.missed:
        return 'missed'.tr;
      case ReminderState.skipped:
        return 'skipped'.tr;
    }
  }

  Widget _buildRemindersList() {
    return Expanded(
      child: Obx(() {
        final reminders = _customReminderController.reminders;

        if (_customReminderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }//
        if (reminders.isEmpty) {//
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'no_reminders_for_day'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Obx(() {
          if (controller.remindersList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_reminders_for_day'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Step 1: Group reminders by time
          Map<String, List<ReminderModel>> groupedReminders = {};
          for (var reminder in controller.remindersList) {
            // استخراج الوقت من `dateTime`
            String timeKey = DateFormat('hh:mm a').format(DateTime.parse(reminder.dateTime.toString()));
            if (!groupedReminders.containsKey(timeKey)) {
              groupedReminders[timeKey] = [];
            }
            groupedReminders[timeKey]!.add(reminder);
          }

          // Step 2: Convert groupedReminders Map to a List of grouped items
          List<List<ReminderModel>> groupedRemindersList = groupedReminders.values.toList();

          // Step 3: Build the UI for each group
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: groupedRemindersList.length,
            itemBuilder: (context, index) {
              final group = groupedRemindersList[index];
              return _buildGroupRemindersCardByTime(group);
            },
          );
        });
      }),
    );
  }
  Widget _buildGroupRemindersCardByTime(List<ReminderModel> reminders) {
    if (reminders.isEmpty) return Container();

    // استخراج الوقت من أول تذكير في المجموعة
    final DateTime dateTime = DateTime.parse(reminders.first.dateTime.toString());
    final String time = AppHelper.formatTimeBasedOnLanguage(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(.3)),
      ),
      color: Colors.white.withOpacity(.5),
      elevation: 0,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان المجموعة (الوقت)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey.shade700,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style:  TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontFamily: 'Roboto',
                      height: 1
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // عرض جميع التذكيرات في المجموعة
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
          ],
        ),
      ),
    );
  }




}
