import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineModel {
  final String? id;
  final String? wakeUpTime;
  final String? breakfastTime;
  final String? lunchTime;
  final String? dinnerTime;
  final String? bedTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoutineModel({
    this.id,
    this.wakeUpTime,
    this.breakfastTime,
    this.lunchTime,
    this.dinnerTime,
    this.bedTime,
    this.createdAt,
    this.updatedAt,
  });

  RoutineModel copyWith({
    String? id,
    String? wakeUpTime,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    String? bedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      bedTime: bedTime ?? this.bedTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wakeUpTime': wakeUpTime,
      'breakfastTime': breakfastTime,
      'lunchTime': lunchTime,
      'dinnerTime': dinnerTime,
      'bedTime': bedTime,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'],
      wakeUpTime: json['wakeUpTime'],
      breakfastTime: json['breakfastTime'],
      lunchTime: json['lunchTime'],
      dinnerTime: json['dinnerTime'],
      bedTime: json['bedTime'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
