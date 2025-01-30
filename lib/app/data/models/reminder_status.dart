import 'reminder_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderStatus {
  final DateTime timestamp;
   ReminderState state;

  ReminderStatus({
    required this.timestamp,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'state': state.toString().split('.').last,
    };
  }

  factory ReminderStatus.fromJson(Map<String, dynamic> json) {
    // Handle both Timestamp and String for timestamp
    DateTime parsedTimestamp;
    final timestampValue = json['timestamp'];
    if (timestampValue is Timestamp) {
      parsedTimestamp = timestampValue.toDate();
    } else if (timestampValue is String) {
      parsedTimestamp = DateTime.parse(timestampValue);
    } else {
      parsedTimestamp = DateTime.now();
      print('Warning: Invalid timestamp format in JSON: $timestampValue');
    }

    return ReminderStatus(
      timestamp: parsedTimestamp,
      state: ReminderState.values.firstWhere(
        (e) => e.toString().split('.').last == (json['state'] as String? ?? 'pending'),
        orElse: () => ReminderState.pending,
      ),
    );
  }
}
