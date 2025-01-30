import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reminder/app/data/models/reminder_model.dart';

import '../../../core/theme/app_colors.dart';

class ExampleView extends GetView {
  const ExampleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final medication = ExampleData.getDailyMedicationExample();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Medication Example',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take daily at ${medication.reminders[0].time.format(context)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Remaining: ${medication.remainingQuantity} ${medication.unit}s',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Next 7 Days Status:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Status List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medication.reminders.length,
              itemBuilder: (context, index) {
                final reminder = medication.reminders[index];
                final date = DateTime(
                  now.year,
                  now.month,
                  now.day + index,
                );
                final reminderTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  reminder.time.hour,
                  reminder.time.minute,
                );

                // Determine status and color
                String status;
                Color statusColor;
                if (reminderTime.isBefore(now)) {
                  status = 'Missed';
                  statusColor = AppColors.error;
                } else {
                  status = 'Pending';
                  statusColor = AppColors.primary;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '${date.toString().split(' ')[0]} - ${reminder.time.format(context)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleData {
  static getDailyMedicationExample() {

  }
}
