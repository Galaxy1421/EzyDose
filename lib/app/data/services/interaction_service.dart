import 'dart:math' show min;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
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
  final String medicationName;
  final List<FlowEdge> edges;

  FlowNode(this.id, this.medicationName) : edges = [];
}

class InteractionService extends GetxService {
  final logger = Logger();

  /// Implements minimum cost flow algorithm for medication interactions
  /// Returns optimal scheduling considering interaction risks
  Map<String, List<DateTime>> findOptimalSchedule(List<MedicationModel> medications) {
    final nodes = _buildFlowNetwork(medications);
    final schedule = <String, List<DateTime>>{};
    
    // Initialize time slots (24 hours in 15-minute intervals)
    final timeSlots = List.generate(
      96, // 24 hours * 4 (15-minute intervals)
      (i) => DateTime.now().add(Duration(minutes: i * 15))
    );

    // Run minimum cost flow algorithm
    _minimumCostFlow(nodes);

    // Convert flow solution to schedule
    for (var node in nodes) {
      schedule[node.medicationName] = [];
      for (var edge in node.edges) {
        if (edge.flow > 0) {
          // Add time slots based on flow value
          final slotIndex = edge.to % timeSlots.length;
          schedule[node.medicationName]!.add(timeSlots[slotIndex]);
        }
      }
    }

    return schedule;
  }

  /// Builds the flow network from medications and their interactions
  List<FlowNode> _buildFlowNetwork(List<MedicationModel> medications) {
    final nodes = <FlowNode>[];
    
    // Create nodes for each medication
    for (var i = 0; i < medications.length; i++) {
      nodes.add(FlowNode(i, medications[i].name));
    }

    // Add edges for interactions
    for (var i = 0; i < medications.length; i++) {
      for (var interaction in medications[i].interactions) {
        // Find target medication index
        final targetIndex = medications.indexWhere(
          (m) => m.name == interaction.medicationName
        );
        
        if (targetIndex != -1) {
          // Cost based on risk level
          final cost = _calculateInteractionCost(interaction.riskLevel);
          
          // Add edge and residual edge
          final edge = FlowEdge(i, targetIndex, 1, cost);
          final residual = FlowEdge(targetIndex, i, 0, -cost);
          
          edge.residual = residual;
          residual.residual = edge;
          
          nodes[i].edges.add(edge);
          nodes[targetIndex].edges.add(residual);
        }
      }
    }

    return nodes;
  }

  /// Implements the minimum cost flow algorithm using successive shortest paths
  void _minimumCostFlow(List<FlowNode> nodes) {
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
      if (prev[nodes.length - 1] == -1) break;
      
      // Find minimum flow on the path
      var minFlow = double.infinity;
      for (var at = nodes.length - 1; prev[at] != -1; at = prev[at]) {
        final edge = edges[at]!;
        minFlow = min(minFlow, (edge.capacity - edge.flow).toDouble());
      }
      
      // Apply the flow
      for (var at = nodes.length - 1; prev[at] != -1; at = prev[at]) {
        final edge = edges[at]!;
        edge.flow += minFlow.toInt();
        edge.residual!.flow -= minFlow.toInt();
      }
    }
  }

  /// Calculates interaction cost based on risk level
  int _calculateInteractionCost(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.high:
        return 1000;
      case RiskLevel.moderate:
        return 500;
      case RiskLevel.low:
        return 100;
      case RiskLevel.none:
        return 0;
    }
  }

  @override
  Future<InteractionService> init() async {
    return this;
  }
}
