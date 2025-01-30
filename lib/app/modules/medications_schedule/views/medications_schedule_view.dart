import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicationScheduleView extends StatelessWidget {
  final Map<String, List<DateTime>> schedule;

  MedicationScheduleView({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("جدولة الأدوية المثلى"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // عنوان الجدول
            Text(
              "جدول الأدوية",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            // قائمة الأدوية
            Expanded(
              child: ListView.builder(
                itemCount: schedule.keys.length,
                itemBuilder: (context, index) {
                  final medicationName = schedule.keys.elementAt(index);
                  final times = schedule[medicationName]!;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // أيقونة الدواء
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.medical_services_outlined,
                              size: 28,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // تفاصيل الدواء
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicationName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (times.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    children: times.map((time) {
                                      return Chip(
                                        avatar: Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          DateFormat('HH:mm').format(time),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        backgroundColor: Colors.green.shade400,
                                      );
                                    }).toList(),
                                  )
                                else
                                  Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.red.shade400),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "لم يتم تخصيص وقت",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Logic لإعادة تشغيل الخوارزمية
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("إعادة التشغيل"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Logic لتحديث الجدول
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("تحديث الجدول"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class MedicationScheduleView extends StatelessWidget {
//   final Map<String, List<DateTime>> schedule;
//
//   MedicationScheduleView({required this.schedule});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("جدولة الأدوية المثلى"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "الجدول الزمني للأدوية:",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: schedule.keys.length,
//                 itemBuilder: (context, index) {
//                   final medicationName = schedule.keys.elementAt(index);
//                   final times = schedule[medicationName]!;
//
//                   return Card(
//                     elevation: 4,
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             medicationName,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blueAccent,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           if (times.isNotEmpty)
//                             Wrap(
//                               spacing: 8,
//                               children: times.map((time) {
//                                 return Chip(
//                                   label: Text(
//                                     "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
//                                   ),
//                                   backgroundColor: Colors.green.shade100,
//                                 );
//                               }).toList(),
//                             )
//                           else
//                             Text(
//                               "لم يتم تخصيص وقت لهذا الدواء",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.redAccent,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Logic to re-run the scheduling algorithm
//                   },
//                   icon: Icon(Icons.restart_alt),
//                   label: Text("إعادة تشغيل الجدولة"),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Logic to refresh the schedule
//                   },
//                   icon: Icon(Icons.refresh),
//                   label: Text("تحديث الجدول"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
