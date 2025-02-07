
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
  final List<NewInteractionModel> interactionsList = []; // قائمة لتخزين التفاعلات

  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risk

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

  Map<String, dynamic> findOptimalSchedule(List<ReminderModel> newReminders, List<ReminderModel> existingReminders) {
    print("======================================\n\n\nStarting the scheduling process...");

    // مسح القائمة الحالية قبل إضافة التفاعلات الجديدة
    interactionsList.clear();

    // قائمة العقد
    final nodes = <FlowNode>[];
    int nodeId = 0;

    final groupedNewReminders = _groupRemindersByMedication(newReminders);
    final groupedExistingReminders = _groupRemindersByMedication(existingReminders);

    // إنشاء العقد للتذكيرات الجديدة
    for (var entry in groupedNewReminders.entries) {
      final reminders = entry.value;
      final medicationName = reminders.first.medicationName ?? reminders.first.medicineModelDataSet!.tradeName;
      final newNode = FlowNode(nodeId++, reminders.first); // استخدام أول تذكير كمرجعية
      nodes.add(newNode);
      print("Node created for new medication: $medicationName");
    }

    // إنشاء العقد للتذكيرات الحالية
    for (var entry in groupedExistingReminders.entries) {
      final reminders = entry.value;
      final medicationName = reminders.first.medicationName ?? reminders.first.medicineModelDataSet!.tradeName;

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
            final interactions = _calculateAllInteractions(
              node.reminder.medicineModelDataSet,
              targetNode.reminder.medicineModelDataSet!,
            );

            if (interactions.isNotEmpty) {
              for (var interaction in interactions) {
                final edge = FlowEdge(node.id, targetNode.id, 1, interaction.cost);
                final residual = FlowEdge(targetNode.id, node.id, 0, -interaction.cost);

                edge.residual = residual;
                residual.residual = edge;

                node.edges.add(edge);
                targetNode.edges.add(residual);
                addedEdges.add(edgeKey);

                // إضافة التفاعل إلى القائمة
                interactionsList.add(NewInteractionModel(
                  id: "${node.id}-${targetNode.id}",
                  medicationId: node.reminder.medicineModelDataSet?.id ?? "Unknown",
                  interactingMedicationId: targetNode.reminder.medicineModelDataSet?.id ?? "Unknown",
                  medicationName: node.reminder.medicineModelDataSet?.tradeName ?? "Unknown",
                  interactingMedicationName: targetNode.reminder.medicineModelDataSet?.tradeName ?? "Unknown",
                  interactionType: interaction.type,
                  timingGap: _getRequiredInterval(interaction.type).toString(),
                  description:
                      "Interaction between ${node.reminder.medicineModelDataSet?.tradeName} and ${targetNode.reminder.medicineModelDataSet?.tradeName}",
                  recommendation: "Consult your doctor for further advice.",
                ));

                print("\n➕ EDGE ADDED: ${node.reminder.medicineModelDataSet!.tradeName} ↔ ${targetNode.reminder.medicineModelDataSet!.tradeName}");
                print("   Interaction Type: ${interaction.type} | Cost: ${interaction.cost}");
              }
            }
          }
        }
      }
    }

    print("Flow network built successfully with ${nodes.length} nodes.");

    // الجدول الزمني النهائي
    final schedule = <String, List<DateTime>>{};

    // إنشاء فترات زمنية (24 ساعة بفواصل زمنية 15 دقيقة)
    final timeSlots = List.generate(
        96, // 24 hours * 4 (15-minute intervals)
        (i) => DateTime.now().add(Duration(minutes: i * 15)));
    print("Time slots initialized successfully: ${timeSlots.length} slots created.");
    final occupiedSlots = <int>{}; // لتتبع الفترات المستخدمة

    // تشغيل خوارزمية تدفق التكلفة الدنيا
    _minimumCostFlow(nodes);

    // تحويل التدفق إلى جدول زمني
    for (var node in nodes) {
      final medicationName = node.reminder.medicineModelDataSet?.tradeName ?? "Unknown Medication";
      schedule[medicationName] = [];
      int minInterval = _calculateMinInterval(node);
      int SafeTimes = 6;
      int addedSafeTimes = 0;


print("\n🔍 Searching for safe times for $medicationName (minimum interval: ${minInterval} minutes):");
      for (int i = 0; i < timeSlots.length && addedSafeTimes < SafeTimes; i++) {
        bool isSlotSafe = occupiedSlots.every((occupied) => (i - occupied).abs() >= minInterval ~/ 15);
        if (isSlotSafe) {
          schedule[medicationName]!.add(timeSlots[i]);
          occupiedSlots.add(i);
          addedSafeTimes++;
        }
      }
    }
    print("Scheduling process completed.\n\n\n ======================================");
    // بعد إنشاء الجدول
    print("\n\n📅 FINAL SCHEDULE:");
    schedule.forEach((med, times) {
      print("💊 $med:");
      times.forEach((time) {
        print("   - ${time.hour}:${time.minute.toString().padLeft(2, '0')}");
      });
    });

    // إرجاع الجدول الزمني وقائمة التفاعلات
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
            if (edge.capacity > edge.flow && dist[edge.from] + edge.cost < dist[edge.to]) {
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

  List<InteractionModel2> _calculateAllInteractions(MedicineModelDataSet? newMedication, MedicineModelDataSet existingMedication) {
    final interactions = <InteractionModel2>[];
    final newAtcCode1 = newMedication?.atcCode1;

    if (newAtcCode1 == null) {
      print("⚠️ No ATC code found for new medication: ${newMedication?.tradeName}");
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
      print("✅ No interaction found between ${newMedication?.tradeName} and ${existingMedication.tradeName}");
    } else {
      print("🔍 Interactions detected between ${newMedication?.tradeName} and ${existingMedication.tradeName}: ${interactions.length}");
    }

    return interactions;
  }

  @override
  Future<NewInteractionService> init() async {
    logger.i("NewInteractionService initialized.");
    return this;
  }
}
