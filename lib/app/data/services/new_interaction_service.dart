import 'dart:math' show min;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';
import 'package:reminder/app/data/models/new_interaction_model.dart';
import 'package:reminder/app/data/models/reminder_model.dart';
import '../models/medication_model.dart';

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
  final ReminderModel reminder;
  final List<FlowEdge> edges;

  FlowNode(this.id, this.reminder) : edges = [];
}

class InteractionModel2 {
  final String type;
  final int cost;

  InteractionModel2({required this.type, required this.cost});
}

class NewInteractionService extends GetxService {
  final logger = Logger();
  final List<NewInteractionModel> interactionsList =
      []; // قائمة لتخزين التفاعلات

  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risk

  Map<String, List<ReminderModel>> _groupRemindersByMedication(
      List<ReminderModel> reminders) {
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

  Map<String, dynamic> findOptimalSchedule(
      List<ReminderModel> newReminders, List<ReminderModel> existingReminders) {
    print(
        "======================================\n\n\nStarting the scheduling process...");

    interactionsList.clear(); // Clear the previous interactions

    final nodes = <FlowNode>[];
    int nodeId = 0;

    final groupedNewReminders = _groupRemindersByMedication(newReminders);
    final groupedExistingReminders =
        _groupRemindersByMedication(existingReminders);

    // Create nodes for new reminders
    for (var entry in groupedNewReminders.entries) {
      final reminders = entry.value;
      final medicationName = reminders.first.medicationName ??
          reminders.first.medicineModelDataSet!.tradeName;
      final newNode = FlowNode(
          nodeId++, reminders.first); // Use first reminder as reference
      nodes.add(newNode);
      print("Node created for new medication: $medicationName");
    }

    // Create nodes for existing reminders
    for (var entry in groupedExistingReminders.entries) {
      final reminders = entry.value;
      final medicationName = reminders.first.medicationName ??
          reminders.first.medicineModelDataSet!.tradeName;
      final existingNode = FlowNode(
          nodeId++, reminders.first); // Use first reminder as reference
      nodes.add(existingNode);
      print("Node created for existing medication: $medicationName");
    }

    final addedEdges = <String>{};

    for (var node in nodes) {
      for (var targetNode in nodes) {
        if (node.id != targetNode.id) {
          final edgeKey = "${node.id}-${targetNode.id}";
          if (!addedEdges.contains(edgeKey)) {
            final interactions = _calculateAllInteractions(
              node.reminder.medicineModelDataSet,
              targetNode.reminder.medicineModelDataSet!,
            );

            if (interactions.isNotEmpty) {
              for (var interaction in interactions) {
                final edge =
                    FlowEdge(node.id, targetNode.id, 1, interaction.cost);
                final residual =
                    FlowEdge(targetNode.id, node.id, 0, -interaction.cost);

                edge.residual = residual;
                residual.residual = edge;

                node.edges.add(edge);
                targetNode.edges.add(residual);
                addedEdges.add(edgeKey);

                interactionsList.add(NewInteractionModel(
                  id: "${node.id}-${targetNode.id}",
                  medicationId:
                      node.reminder.medicineModelDataSet?.id ?? "Unknown",
                  interactingMedicationId:
                      targetNode.reminder.medicineModelDataSet?.id ?? "Unknown",
                  medicationName:
                      node.reminder.medicineModelDataSet?.tradeName ??
                          "Unknown",
                  interactingMedicationName:
                      targetNode.reminder.medicineModelDataSet?.tradeName ??
                          "Unknown",
                  interactionType: interaction.type,
                  timingGap: _getRequiredInterval(interaction.type).toString(),
                  description:
                      "Interaction between ${node.reminder.medicineModelDataSet?.tradeName} and ${targetNode.reminder.medicineModelDataSet?.tradeName}",
                  recommendation: "Consult your doctor for further advice.",
                ));

                print(
                    "\n➕ EDGE ADDED: ${node.reminder.medicineModelDataSet!.tradeName} ↔ ${targetNode.reminder.medicineModelDataSet!.tradeName}");
                print(
                    "   Interaction Type: ${interaction.type} | Cost: ${interaction.cost}");
              }
            }
          }
        }
      }
    }

    print("Flow network built successfully with ${nodes.length} nodes.");

    // Initialize scheduling
    final schedule = <String, List<DateTime>>{};

    final timeSlots =
        List.generate(96, (i) => DateTime.now().add(Duration(minutes: i * 15)));
    print("⏳ Created 96 time slots (15-minute intervals).");

    final occupiedSlots = <int>{};


print("\n🔎 Checking existing reminders:");
print("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
print("Current time: ${DateTime.now()}");
print("Total existing reminders: ${existingReminders.length}");

   // Map existing reminders to occupied slots
for (final reminder in existingReminders) {
  final now = DateTime.now();
  final reminderTime = reminder.dateTime;

  // احسب الفرق بالدقائق مع مراعاة التواريخ
  final difference = reminderTime.difference(now).inMinutes;
  
  // تجاهل التذكيرات الماضية
  if (difference >= 0) {
    final slotIndex = (difference / 15).floor();
    
    if (slotIndex < 96) {
      occupiedSlots.add(slotIndex);
      print("🔗 Found existing reminder: "
          "${reminder.medicationName} at ${_formatTime(reminderTime)} "
          "(slot $slotIndex)");
    } else {
      print("⚠️ Skipping reminder beyond 24h: "
          "${reminder.medicationName} at ${_formatTime(reminderTime)}");
    }
  } else {
    print("⚠️ Skipping past reminder: "
        "${reminder.medicationName} at ${_formatTime(reminderTime)}");
  }
}
print("📊 Occupied slots after processing: $occupiedSlots");


    _minimumCostFlow(nodes);

    for (var node in nodes) {
      final medicationName =
          node.reminder.medicineModelDataSet?.tradeName ?? "Unknown Medication";
      schedule[medicationName] = [];
      int minInterval = _calculateMinInterval(node);
      int safeTimes = 6;
      int addedSafeTimes = 0;

      print("\n🔎 Searching for safe times for: $medicationName");
      print("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
      print(
          "Minimum required interval: ${minInterval ~/ 60} hours ${minInterval % 60} minutes");

      for (int i = 0; i < timeSlots.length && addedSafeTimes < safeTimes; i++) {
       
       final nearestGap = occupiedSlots.isNotEmpty 
      ? occupiedSlots.map((o) => (i - o).abs() * 15).reduce(min)
      : 1440; // 24h إذا لم توجد تذكيرات
  
        final isSlotSafe = nearestGap >= minInterval;

        if (isSlotSafe && !occupiedSlots.contains(i)) {
          final time = timeSlots[i];
          final formattedTime =
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}";

          schedule[medicationName]!.add(time);
          occupiedSlots.add(i);
          addedSafeTimes++;

        

          print("✅ [Scheduled #${addedSafeTimes}]");
          print("   Medication: $medicationName");
          print("   Time: $formattedTime");
          print(
              "    Gap from Others : ${_calculateGapFromOthers(i, occupiedSlots, timeSlots)}");
          print("══════════════════════════════");
        }
      }

      if (addedSafeTimes < safeTimes) {
        print(
            "\n⚠️ Warning: Only found $addedSafeTimes time slots out of $safeTimes required.");
        print("   Possible reasons:");
        print("   - Too many drug interactions");
        print("   - Not enough available time slots");
      } else {
        print("\n✔️ Successfully scheduled for $medicationName.");
        print("   Total scheduled times: $safeTimes");
      }
    }

    print("\n\n📅 Final Schedule:");
    schedule.forEach((med, times) {
      print("\n💊 $med:");
      times.forEach((time) {
        print("   - ${time.hour}:${time.minute.toString().padLeft(2, '0')}");
      });
    });

    return {
      'schedule': schedule,
      'interactions': interactionsList,
    };
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

  String _getInteractionType(int cost) {
    switch (cost) {
      case 1000:
        return 'MAJOR';
      case 500:
        return 'MODERATE';
      case 100:
        return 'MINOR';
      default:
        return 'NONE';
    }
  }

  int _getRequiredInterval(String interactionType) {
    switch (interactionType) {
      case 'MAJOR':
        return 180; // 180 دقيقة
      case 'MODERATE':
        return 90; // 90 دقيقة
      case 'MINOR':
        return 60; // 60 دقيقة
      default:
        return 0;
    }
  }

  int _calculateMinInterval(FlowNode node) {
    int maxInterval = 0;
    for (var edge in node.edges) {
      if (edge.cost > 0) {
        String interactionType = _getInteractionType(edge.cost);
        int requiredInterval = _getRequiredInterval(interactionType);
        if (requiredInterval > maxInterval) {
          maxInterval = requiredInterval;
        }
      }
    }
    return maxInterval;
  }

  List<InteractionModel2> _calculateAllInteractions(
      MedicineModelDataSet? newMedication,
      MedicineModelDataSet existingMedication) {
    final interactions = <InteractionModel2>[];
    final newAtcCode1 = newMedication?.atcCode1;

    if (newAtcCode1 == null) {
      print(
          "⚠️ No ATC code found for new medication: ${newMedication?.tradeName}");
      return interactions;
    }

    if (existingMedication.major?.contains(newAtcCode1) ?? false) {
      interactions.add(InteractionModel2(type: 'MAJOR', cost: 1000));
    }
    if (existingMedication.moderate?.contains(newAtcCode1) ?? false) {
      interactions.add(InteractionModel2(type: 'MODERATE', cost: 500));
    }
    if (existingMedication.minor?.contains(newAtcCode1) ?? false) {
      interactions.add(InteractionModel2(type: 'MINOR', cost: 100));
    }

    if (interactions.isEmpty) {
      print(
          "✅ No interaction found between ${newMedication?.tradeName} and ${existingMedication.tradeName}");
    } else {
      print(
          "🔍 Interactions detected between ${newMedication?.tradeName} and ${existingMedication.tradeName}: ${interactions.length}");
    }

    return interactions;
  }

  

  String _calculateGapFromOthers(
      int currentIndex, Set<int> occupied, List<DateTime> slots) {
    final gaps = occupied
        .where((o) => o != currentIndex)
        .map((o) => (currentIndex - o).abs() * 15)
        .toList();

    if (gaps.isEmpty) return "  ";

    final nearestGap = gaps.reduce(min);
    return "Nearest dose : ${nearestGap ~/ 60} Hours ${nearestGap % 60} Minutes";
  }
  
String _formatTime(DateTime time) => 
    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  @override
  Future<NewInteractionService> init() async {
    logger.i("NewInteractionService initialized.");
    return this;
  }
}
