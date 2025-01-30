class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<DateTime> schedule;
  final String instructions;
  final int quantity;
  final int remainingDoses;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.instructions,
    required this.quantity,
    required this.remainingDoses,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'schedule': schedule.map((date) => date.toIso8601String()).toList(),
      'instructions': instructions,
      'quantity': quantity,
      'remainingDoses': remainingDoses,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      schedule: (json['schedule'] as List)
          .map((date) => DateTime.parse(date))
          .toList(),
      instructions: json['instructions'],
      quantity: json['quantity'],
      remainingDoses: json['remainingDoses'],
    );
  }
}
