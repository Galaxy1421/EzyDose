import 'dart:math' show min;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import '../models/medication_model.dart';
import '../models/interaction_model.dart';

/// Edge in the flow network representing a medication interaction
class FlowEdge {
  final int from;
  final int to;
  int capacity;
  int flow;
  final int cost;
  FlowEdge? residual;

  FlowEdge(this.from, this.to, this.capacity, this.cost) : flow = 0;
}

/// Node in the flow network representing a medication
class FlowNode {
  final int id;
  // final String medicationName;
  final ReminderModel reminder;
  final List<FlowEdge> edges;

  FlowNode(this.id, this.reminder) : edges = [];
}
class NewInteractionService extends GetxService {
  final logger = Logger();

  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risks
  // Map<String, List<DateTime>> findOptimalSchedule(List<MedicationModel> medications) {
  //   logger.i("Starting the scheduling process...");
  //   final nodes = _buildFlowNetwork(medications);
  //   logger.i("Flow network built successfully with ${nodes.length} nodes.");
  //
  //   final schedule = <String, List<DateTime>>{};
  //
  //   // Initialize time slots (24 hours in 15-minute intervals)
  //   final timeSlots = List.generate(
  //       96, // 24 hours * 4 (15-minute intervals)
  //           (i) => DateTime.now().add(Duration(minutes: i * 15))
  //   );
  //   logger.i("Time slots initialized successfully: ${timeSlots.length} slots created.");
  //
  //   // Run minimum cost flow algorithm
  //   logger.i("Running the minimum cost flow algorithm...");
  //   _minimumCostFlow(nodes);
  //
  //   // Convert flow solution to schedule
  //   for (var node in nodes) {
  //     schedule[node.medicationName] = [];
  //     for (var edge in node.edges) {
  //       if (edge.flow > 0) {
  //         // Add time slots based on flow value
  //         final slotIndex = edge.to % timeSlots.length;
  //         schedule[node.medicationName]!.add(timeSlots[slotIndex]);
  //         logger.d("Flow added for medication: ${node.medicationName}, Time Slot: ${timeSlots[slotIndex]}");
  //       }
  //     }
  //   }
  //
  //   logger.i("Scheduling process completed.");
  //   return schedule;
  // }

  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risks

  /// Builds the flow network from reminders and their interactions

  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risks
  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risks
  ///

  Map<String, List<ReminderModel>> _groupRemindersByMedication(List<ReminderModel> reminders) {
    final groupedReminders = <String, List<ReminderModel>>{};

    for (var reminder in reminders) {
      final medicationName = reminder.medicationName ?? 'Unknown Medication';
      if (!groupedReminders.containsKey(medicationName)) {
        groupedReminders[medicationName] = [];
      }
      groupedReminders[medicationName]!.add(reminder);
    }

    return groupedReminders;
  }

  Map<String, List<DateTime>> findOptimalSchedule(
      List<ReminderModel> newReminders,
      List<ReminderModel> existingReminders) {
    print("======================================\n\n\nStarting the scheduling process...");

    // قائمة العقد
    final nodes = <FlowNode>[];
    int nodeId = 0;

    final groupedNewReminders = _groupRemindersByMedication(newReminders);
    final groupedExistingReminders = _groupRemindersByMedication(existingReminders);

// إنشاء العقد للتذكيرات الجديدة
    for (var entry in groupedNewReminders.entries) {

      final reminders = entry.value;
      final medicationName = reminders.first.medicationName??reminders.first.medicineModelDataSet!.tradeName;
      final newNode = FlowNode(nodeId++, reminders.first); // استخدام أول تذكير كمرجعية
      nodes.add(newNode);
      print("Node created for new medication: $medicationName");
    }

// إنشاء العقد للتذكيرات الحالية
    for (var entry in groupedExistingReminders.entries) {
      // final medicationName = entry.key;
      final reminders = entry.value;
      final medicationName = reminders.first.medicationName?? reminders.first.medicineModelDataSet!.tradeName;

      final existingNode = FlowNode(nodeId++, reminders.first); // استخدام أول تذكير كمرجعية
      nodes.add(existingNode);
      print("Node created for existing medication: $medicationName");
    }

    final addedEdges = <String>{}; // لتتبع الحواف التي تمت إضافتها

    for (var node in nodes) {
      for (var targetNode in nodes) {
        if (node.id != targetNode.id) {
          final edgeKey = "${node.id}-${targetNode.id}";
          if (!addedEdges.contains(edgeKey)) {
            final cost = _calculateInteractionCost(
              node.reminder.medicineModelDataSet,
              targetNode.reminder.medicineModelDataSet!,
            );
            if (cost > 0) {
              final edge = FlowEdge(node.id, targetNode.id, 1, cost);
              final residual = FlowEdge(targetNode.id, node.id, 0, -cost);

              edge.residual = residual;
              residual.residual = edge;

              node.edges.add(edge);
              targetNode.edges.add(residual);
              addedEdges.add(edgeKey);

              print(
                  "Edge added: ${node.reminder.medicineModelDataSet!.tradeName} -> ${targetNode.reminder.medicineModelDataSet!.tradeName}, Cost: $cost");
            }
          }
        }
      }
    }

    // إضافة الحواف (Edges) بناءً على التفاعلات
    // for (var node in nodes) {
    //   for (var targetNode in nodes) {
    //     if (node.id != targetNode.id) {
    //       // حساب التكلفة بناءً على التفاعل بين التذكيرات
    //       final cost = _calculateInteractionCost(
    //         node.reminder.medicineModelDataSet,
    //         targetNode.reminder.medicineModelDataSet!,
    //       );
    //       if (cost > 0) {
    //         final edge = FlowEdge(node.id, targetNode.id, 1, cost);
    //         final residual = FlowEdge(targetNode.id, node.id, 0, -cost);
    //
    //         edge.residual = residual;
    //         residual.residual = edge;
    //
    //         node.edges.add(edge);
    //         targetNode.edges.add(residual);
    //
    //         print(
    //             "Edge added: ${node.reminder.medicineModelDataSet!.tradeName} -> ${targetNode.reminder.medicineModelDataSet!.tradeName}, Cost: $cost");
    //
    //         print("Edge flow for ${node.reminder.medicineModelDataSet!.tradeName} -> ${edge.to}: ${edge.flow}");
    //
    //       }
    //     }//
    //   }
    // }

    print("Flow network built successfully with ${nodes.length} nodes.");

    // الجدول الزمني النهائي
    final schedule = <String, List<DateTime>>{};

    // إنشاء فترات زمنية (24 ساعة بفواصل زمنية 15 دقيقة)
    final timeSlots = List.generate(
        96, // 24 hours * 4 (15-minute intervals)
            (i) => DateTime.now().add(Duration(minutes: i * 15)));
    print("Time slots initialized successfully: ${timeSlots.length} slots created.");

    // تشغيل خوارزمية تدفق التكلفة الدنيا
    _minimumCostFlow(nodes);

    // تحويل التدفق إلى جدول زمني
    for (var node in nodes) {
      final medicationName = node.reminder.medicineModelDataSet?.tradeName ?? "Unknown Medication";
      schedule[medicationName] = [];//
      for (var edge in node.edges) {
        if (edge.flow > 0) {
          // حساب الفترات الزمنية بناءً على التدفق
          final slotIndex = edge.to % timeSlots.length;
          final timeSlot = timeSlots[slotIndex];
          schedule[medicationName]!.add(timeSlot);

          print("Scheduled time for $medicationName: $timeSlot");
        }
      }
    }
    for (var node in nodes) {
      if (schedule[node.reminder.medicineModelDataSet!.tradeName]!.isEmpty) {
        final slotIndex = node.id % timeSlots.length;
        schedule[node.reminder.medicineModelDataSet!.tradeName]!.add(timeSlots[slotIndex]);
        print("Default time assigned for ${node.reminder.medicineModelDataSet!.tradeName}: ${timeSlots[slotIndex]}");
      }
    }

    print("Scheduling process completed.\n\n\n ======================================");
    return schedule;
  }



  /// Implements the minimum cost flow algorithm using successive shortest paths
  void _minimumCostFlow(List<FlowNode> nodes) {
    print("Starting the minimum cost flow algorithm...");
    while (true) {
      final dist = List.filled(nodes.length, double.infinity);
      final prev = List.filled(nodes.length, -1);
      final edges = List<FlowEdge?>.filled(nodes.length, null);

      // Find shortest path using Bellman-Ford
      dist[0] = 0;

      bool updated = false;
      for (var i = 0; i < nodes.length - 1; i++) {
        updated = false;
        for (var node in nodes) {
          for (var edge in node.edges) {
            if (edge.capacity > edge.flow &&
                dist[edge.from] + edge.cost < dist[edge.to]) {
              dist[edge.to] = dist[edge.from] + edge.cost;
              prev[edge.to] = edge.from;
              edges[edge.to] = edge;
              updated = true;
            }
          }
        }
        if (!updated) break;
      }

      // No more paths found
      if (prev[nodes.length - 1] == -1) {
        print("No more paths found. Algorithm completed.");
        break;
      }

      // Find minimum flow on the path
      var minFlow = double.infinity;
      for (var at = nodes.length - 1; prev[at] != -1; at = prev[at]) {
        final edge = edges[at]!;
        minFlow = min(minFlow, (edge.capacity - edge.flow).toDouble());
      }
      print("Minimum flow found: $minFlow");

      // Apply the flow
      for (var at = nodes.length - 1; prev[at] != -1; at = prev[at]) {
        final edge = edges[at]!;
        edge.flow += minFlow.toInt();
        edge.residual!.flow -= minFlow.toInt();
        print("Flow applied: ${edge.from} -> ${edge.to}, Flow: ${edge.flow}");
      }
    }
  }

  int _calculateInteractionCost(MedicineModelDataSet? newMedication, MedicineModelDataSet existingMedication) {
    final newAtcCode1 = newMedication?.atcCode1;

    // إذا كان AtcCode1Interact يحتوي على "all"، فإن التفاعل يعتبر Major
    // if (existingMedication.atcCode1Interact == "all") {
    //   return 1000; // تكلفة تفاعل خطير
    // }

    // التحقق من وجود كود ATC للدواء الجديد في أعمدة Major, Moderate, Minor
    if (newAtcCode1 != null) {
      if (existingMedication.major != null && existingMedication.major!.contains(newAtcCode1)) {
        return 1000; // تكلفة تفاعل خطير
      } else if (existingMedication.moderate != null && existingMedication.moderate!.contains(newAtcCode1)) {
        return 500; // تكلفة تفاعل متوسط
      } else if (existingMedication.minor != null && existingMedication.minor!.contains(newAtcCode1)) {
        return 100; // تكلفة تفاعل طفيف
      }
    }

    return 0; // لا يوجد تفاعل
  }

  /// Calculates interaction cost based on risk level
  int _calculateInteractionCost2(String interactionType) {
    final cost = switch (interactionType) {
      'Major' => 1000,
      'Moderate' => 500,
      'Minor' => 100,
      _ => 0, // No Interaction
    };
    logger.d("Interaction cost calculated for type $interactionType: $cost");
    return cost;
  }

  @override
  Future<NewInteractionService> init() async {
    logger.i("NewInteractionService initialized.");
    return this;
  }
}

// class NewInteractionService extends GetxService {
//   final logger = Logger();
//
//   /// Implements minimum cost flow algorithm for medication interactions
//   /// Returns optimal scheduling considering interaction risks
//   Map<String, List<DateTime>> findOptimalSchedule(List<MedicationModel> medications) {
//     final nodes = _buildFlowNetwork(medications);
//     final schedule = <String, List<DateTime>>{};
//
//     // Initialize time slots (24 hours in 15-minute intervals)
//     final timeSlots = List.generate(
//         96, // 24 hours * 4 (15-minute intervals)
//             (i) => DateTime.now().add(Duration(minutes: i * 15))
//     );
//
//     // Run minimum cost flow algorithm
//     _minimumCostFlow(nodes);
//
//     // Convert flow solution to schedule
//     for (var node in nodes) {
//       schedule[node.medicationName] = [];
//       for (var edge in node.edges) {
//         if (edge.flow > 0) {
//           // Add time slots based on flow value
//           final slotIndex = edge.to % timeSlots.length;
//           schedule[node.medicationName]!.add(timeSlots[slotIndex]);
//         }
//       }
//     }
//
//     return schedule;
//   }
//
//   /// Builds the flow network from medications and their interactions
//   List<FlowNode> _buildFlowNetwork(List<MedicationModel> medications) {
//     final nodes = <FlowNode>[];
//
//     // Create nodes for each medication
//     for (var i = 0; i < medications.length; i++) {
//       nodes.add(FlowNode(i, medications[i].name));
//     }
//
//     // Add edges for interactions
//     for (var i = 0; i < medications.length; i++) {
//       for (var interaction in medications[i].newInteractions) {
//         // Find target medication index
//         final targetIndex = medications.indexWhere(
//                 (m) => m.name == interaction.interactingMedicationName
//         );
//
//         if (targetIndex != -1) {
//           // Cost based on interaction type
//           final cost = _calculateInteractionCost(interaction.interactionType);
//
//           // Add edge and residual edge
//           final edge = FlowEdge(i, targetIndex, 1, cost);
//           final residual = FlowEdge(targetIndex, i, 0, -cost);
//
//           edge.residual = residual;
//           residual.residual = edge;
//
//           nodes[i].edges.add(edge);
//           nodes[targetIndex].edges.add(residual);
//         }
//       }
//     }
//
//     return nodes;
//   }
//
//   /// Implements the minimum cost flow algorithm using successive shortest paths
//   void _minimumCostFlow(List<FlowNode> nodes) {
//     while (true) {
//       final dist = List.filled(nodes.length, double.infinity);
//       final prev = List.filled(nodes.length, -1);
//       final edges = List<FlowEdge?>.filled(nodes.length, null);
//
//       // Find shortest path using Bellman-Ford
//       dist[0] = 0;
//
//       bool updated = false;
//       for (var i = 0; i < nodes.length - 1; i++) {
//         updated = false;
//         for (var node in nodes) {
//           for (var edge in node.edges) {
//             if (edge.capacity > edge.flow &&
//                 dist[edge.from] + edge.cost < dist[edge.to]) {
//               dist[edge.to] = dist[edge.from] + edge.cost;
//               prev[edge.to] = edge.from;
//               edges[edge.to] = edge;
//               updated = true;
//             }
//           }
//         }
//         if (!updated) break;
//       }
//
//       // No more paths found
//       if (prev[nodes.length - 1] == -1) break;
//
//       // Find minimum flow on the path
//       var minFlow = double.infinity;
//       for (var at = nodes.length - 1; prev[at] != -1; at = prev[at]) {
//         final edge = edges[at]!;
//         minFlow = min(minFlow, (edge.capacity - edge.flow).toDouble());
//       }
//
//       // Apply the flow
//       for (var at = nodes.length - 1; prev[at] != -1; at = prev[at]) {
//         final edge = edges[at]!;
//         edge.flow += minFlow.toInt();
//         edge.residual!.flow -= minFlow.toInt();
//       }
//     }
//   }
//
//   /// Calculates interaction cost based on risk level
//   int _calculateInteractionCost(String interactionType) {
//     switch (interactionType) {
//       case 'Major':
//         return 1000;
//       case 'Moderate':
//         return 500;
//       case 'Minor':
//         return 100;
//       default:
//         return 0; // No Interaction
//     }
//   }
//   @override
//   Future<NewInteractionService> init() async {
//     return this;
//   }
// }
