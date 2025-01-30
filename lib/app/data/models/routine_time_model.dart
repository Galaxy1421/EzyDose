import 'package:flutter/material.dart';

class RoutineTime {
  final String id;
  final String name;
  final String description;
  final TimeOfDay defaultTime;

  RoutineTime({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultTime,
  });
}

class RoutineTimePresets {
  static final List<RoutineTime> routines = [
    RoutineTime(
      id: 'wake_up',
      name: 'Wake Up',
      description: 'After waking up',
      defaultTime: TimeOfDay(hour: 7, minute: 0),
    ),
    RoutineTime(
      id: 'before_breakfast',
      name: 'Before Breakfast',
      description: '30 minutes before breakfast',
      defaultTime: TimeOfDay(hour: 7, minute: 30),
    ),
    RoutineTime(
      id: 'after_breakfast',
      name: 'After Breakfast',
      description: 'After breakfast',
      defaultTime: TimeOfDay(hour: 8, minute: 0),
    ),
    RoutineTime(
      id: 'before_lunch',
      name: 'Before Lunch',
      description: '30 minutes before lunch',
      defaultTime: TimeOfDay(hour: 11, minute: 30),
    ),
    RoutineTime(
      id: 'after_lunch',
      name: 'After Lunch',
      description: 'After lunch',
      defaultTime: TimeOfDay(hour: 13, minute: 0),
    ),
    RoutineTime(
      id: 'before_dinner',
      name: 'Before Dinner',
      description: '30 minutes before dinner',
      defaultTime: TimeOfDay(hour: 18, minute: 30),
    ),
    RoutineTime(
      id: 'after_dinner',
      name: 'After Dinner',
      description: 'After dinner',
      defaultTime: TimeOfDay(hour: 19, minute: 30),
    ),
    RoutineTime(
      id: 'bedtime',
      name: 'Bedtime',
      description: 'Before going to bed',
      defaultTime: TimeOfDay(hour: 22, minute: 0),
    ),
  ];
}
