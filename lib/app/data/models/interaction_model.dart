import 'package:flutter/material.dart';

enum RiskLevel {
  high,
  moderate,
  low,
  none;

  String get displayName {
    switch (this) {
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.none:
        return 'No Risk';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.moderate:
        return Colors.orange;
      case RiskLevel.low:
        return Colors.yellow;
      case RiskLevel.none:
        return Colors.green;
    }
  }
}

class InteractionModel {
  final String id;
  final String medicationId;
  final String interactingMedicationId;
  final String medicationName;
  final RiskLevel riskLevel;
  final String description;
  final String recommendation;

  InteractionModel({
    required this.id,
    required this.medicationId,
    required this.interactingMedicationId,
    required this.medicationName,
    required this.riskLevel,
    required this.description,
    required this.recommendation,
  });

  factory InteractionModel.fromJson(Map<String, dynamic> json) {
    return InteractionModel(
      id: json['id'],
      medicationId: json['medicationId'],
      interactingMedicationId: json['interactingMedicationId'],
      medicationName: json['medicationName'] ?? '',
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == json['riskLevel'],
        orElse: () => RiskLevel.none,
      ),
      description: json['description'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'interactingMedicationId': interactingMedicationId,
      'medicationName': medicationName,
      'riskLevel': riskLevel.toString(),
      'description': description,
      'recommendation': recommendation,
    };
  }

  InteractionModel copyWith({
    String? id,
    String? medicationId,
    String? interactingMedicationId,
    String? medicationName,
    RiskLevel? riskLevel,
    String? description,
    String? recommendation,
  }) {
    return InteractionModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      interactingMedicationId: interactingMedicationId ?? this.interactingMedicationId,
      medicationName: medicationName ?? this.medicationName,
      riskLevel: riskLevel ?? this.riskLevel,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
