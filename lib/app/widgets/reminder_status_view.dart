import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../data/models/reminder_model.dart';
import '../data/models/reminder_state.dart';

class ReminderStatusView extends StatelessWidget {
  final ReminderModel reminder;
  final DateTime date;
  final VoidCallback? onTap;

  const ReminderStatusView({
    Key? key,
    required this.reminder,
    required this.date,
    this.onTap,
  }) : super(key: key);

  Color _getStatusColor(ReminderState state) {
    switch (state) {
      case ReminderState.taken:
        return Colors.green;
      case ReminderState.missed:
        return Colors.red;
      case ReminderState.skipped:
        return Colors.orange;
      case ReminderState.pending:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(ReminderState state) {
    switch (state) {
      case ReminderState.taken:
        return Icons.check_circle;
      case ReminderState.missed:
        return Icons.cancel;
      case ReminderState.skipped:
        return Icons.skip_next;
      case ReminderState.pending:
        return Icons.schedule;
    }
  }

  String _getStatusText(ReminderState state) {
    return state.toString().split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final state = reminder.getStateForDate(date);
    final color = _getStatusColor(state);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(state),
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _getStatusText(state),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
