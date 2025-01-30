import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/history_controller.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/reminder_state.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('history'.tr, style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: Get.context!,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                controller.selectedDate.value = picked;
                controller.loadReminders();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.loadReminders();
        },
        child: Column(
          children: [
            _buildDateSelector(),
            _buildSummary(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.reminders.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.reminders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildDateHeader();
                    }
                    return _buildReminderCard(controller.reminders[index - 1]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_history_for_date'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'swipe_to_refresh'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'daily_summary'.tr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateNavigationButton(
                  icon: Icons.chevron_left,
                  onPressed: () {
                    controller.selectedDate.value =
                        controller.selectedDate.value.subtract(
                            const Duration(days: 1));
                    controller.loadReminders();
                  },
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('EEEE').format(controller.selectedDate.value),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      return Text(
                        DateFormat('MMMM d').format(
                            controller.selectedDate.value),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
                _buildDateNavigationButton(
                  icon: Icons.chevron_right,
                  onPressed: () {
                    controller.selectedDate.value =
                        controller.selectedDate.value.add(
                            const Duration(days: 1));
                    controller.loadReminders();
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSummary() {
    return Obx(() {
      if (controller.reminders.isEmpty) return const SizedBox();

      final stats = _calculateStats();
      final total = stats.values.reduce((a, b) => a + b);

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusCount(
                    stats['taken']!, Icons.check_circle, Colors.green,
                    'taken'.tr),
                _buildStatusCount(
                    stats['missed']!, Icons.cancel, Colors.red, 'missed'.tr),
                _buildStatusCount(
                    stats['skipped']!, Icons.skip_next, Colors.grey,
                    'skipped'.tr),
                _buildStatusCount(
                    stats['pending']!, Icons.schedule, Colors.orange,
                    'pending'.tr),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(stats, total),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildProgressIndicator(Map<String, int> stats, int total) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildProgressSegment(stats['taken']!, total, Colors.green),
          _buildProgressSegment(stats['missed']!, total, Colors.red),
          _buildProgressSegment(stats['skipped']!, total, Colors.grey),
          _buildProgressSegment(stats['pending']!, total, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildProgressSegment(int count, int total, Color color) {
    final percentage = count / total;
    return Flexible(
      flex: (percentage * 100).round(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    int taken = 0,
        missed = 0,
        skipped = 0,
        pending = 0;

    for (var reminder in controller.reminders) {
      switch (reminder.getCurrentState()) {
        case ReminderState.taken:
          taken++;
          break;
        case ReminderState.missed:
          missed++;
          break;
        case ReminderState.skipped:
          skipped++;
          break;
        case ReminderState.pending:
          pending++;
          break;
      }
    }

    return {
      'taken': taken,
      'missed': missed,
      'skipped': skipped,
      'pending': pending,
    };
  }

  Widget _buildStatusCount(int count, IconData icon, Color color,
      String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    final state = reminder.getCurrentState();
    final statusColor = _getStatusColor(state);
    final statusTime = reminder.statusHistory.isNotEmpty
        ? reminder.statusHistory.last.timestamp
        : reminder.dateTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(state),
                      color: statusColor,
                      size: 24,
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
                        // Text(
                        //   reminder. ?? '',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey[600],
                        //   ),
                        // ),/
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(state),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeInfo(
                    Icons.schedule,
                    DateFormat('hh:mm a').format(reminder.dateTime),
                    'scheduled'.tr,
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  _buildTimeInfo(
                    Icons.update,
                    DateFormat('hh:mm a').format(statusTime),
                    'updated'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(IconData icon, String time, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ReminderState state) {
    switch (state) {
      case ReminderState.pending:
        return Colors.orange;
      case ReminderState.taken:
        return Colors.green;
      case ReminderState.missed:
        return Colors.red;
      case ReminderState.skipped:
        return Colors.grey;
    }
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
}
