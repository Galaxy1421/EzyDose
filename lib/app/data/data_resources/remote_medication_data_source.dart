import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reminder/app/data/models/medication_model.dart';

abstract class RemoteMedicationDataSource {
  Future<List<MedicationModel>> getAllMedications();
  Future<MedicationModel?> getMedicationById(String id);
  Future<void> addMedication(MedicationModel model);
  Future<void> removeMedication(MedicationModel model);
  Future<void> updateMedication(MedicationModel model);
}

class RemoteMedicationDataSourceImpl extends RemoteMedicationDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionName = "medications";

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  @override
  Future<List<MedicationModel>> getAllMedications() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collectionName)
          .get();
      return snapshot.docs
          .map((doc) => MedicationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all medications: $e');
      return [];
    }
  }

  @override
  Future<void> addMedication(MedicationModel model) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collectionName)
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      print('Error adding medication: $e');
      throw e;
    }
  }

  @override
  Future<void> removeMedication(MedicationModel model) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collectionName)
          .doc(model.id)
          .delete();
    } catch (e) {
      print('Error removing medication: $e');
      throw e;
    }
  }

  @override
  Future<void> updateMedication(MedicationModel model) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collectionName)
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      print('Error updating medication: $e');
      throw e;
    }
  }

  @override
  Future<MedicationModel?> getMedicationById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection(collectionName)
          .doc(id)
          .get();
      if (doc.exists) {
        return MedicationModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting medication by ID: $e');
      return null;
    }
  }
}