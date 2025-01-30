
import 'package:uuid/uuid.dart';

class MedicineModelDataSet {
  final String? id;
  final String? atcCode1;
  final String? tradeName;
  final String? constraint;
  final String? atcCode1Interact;
  final String? timingGap1;
  final String? atcCode2Interact;
  final String? timingGap2;
  final String? major;
  final String? moderate;
  final String? minor;
  final String? packageSize;
  final String? unit;
  final String? photoLink;

  MedicineModelDataSet({
    String? id ,
    this.atcCode1,
    this.tradeName,
    this.constraint,
    this.atcCode1Interact,
    this.timingGap1,
    this.atcCode2Interact,
    this.timingGap2,
    this.major,
    this.moderate,
    this.minor,
    this.packageSize,
    this.unit,
    this.photoLink,
  }): id = id ?? Uuid().v4();



  Map<String, dynamic> toJson() {
    return {
      'atcCode1': atcCode1,
      'tradeName': tradeName,
      'constraint': constraint,
      'atcCode1Interact': atcCode1Interact,
      'timingGap1': timingGap1,
      'atcCode2Interact': atcCode2Interact,
      'timingGap2': timingGap2,
      'major': major,
      'moderate': moderate,
      'minor': minor,
      'packageSize': packageSize,
      'unit': unit,
      'photoLink': photoLink,
    };
  }

  // تحويل JSON إلى MedicineModel
  factory MedicineModelDataSet.fromJson(Map<String, dynamic> json) {
    return MedicineModelDataSet(
      atcCode1: json['atcCode1'],
      tradeName: json['tradeName'],
      constraint: json['constraint'],
      atcCode1Interact: json['atcCode1Interact'],
      timingGap1: json['timingGap1'],
      atcCode2Interact: json['atcCode2Interact'],
      timingGap2: json['timingGap2'],
      major: json['major'],
      moderate: json['moderate'],
      minor: json['minor'],
      packageSize: json['packageSize'],
      unit: json['unit'],
      photoLink: json['photoLink'],
    );
  }

  @override
  String toString() {
    return tradeName ?? 'No Trade Name';
  }

  // تحويل Map إلى MedicineModel (اختياري)

  factory MedicineModelDataSet.fromMap(Map<String, dynamic> map) {
    return MedicineModelDataSet(
      atcCode1: map['atcCode1'],
      tradeName: map['tradeName'],
      constraint: map['constraint'],
      atcCode1Interact: map['atcCode1Interact'],
      timingGap1: map['timingGap1'],
      atcCode2Interact: map['atcCode2Interact'],
      timingGap2: map['timingGap2'],
      major: map['major'],
      moderate: map['moderate'],
      minor: map['minor'],
      packageSize: map['packageSize'],
      unit: map['unit'],
      photoLink: map['photoLink'],
    );
  }
}
