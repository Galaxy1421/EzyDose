import 'package:get/get.dart';
import 'package:reminder/app/data/models/medication_model.dart';
import 'package:reminder/app/data/usecases/medication/get_all_medications_usecase.dart';

class DoctorPrescriptionsController extends GetxController {
  final GetAllMedicationsUseCase _getAllMedicationsUseCase = Get.find();
  
  final RxList<MedicationModel> medications = <MedicationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedications();
  }

  Future<void> loadMedications() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Get all medications and filter for those with prescriptions
      final allMedications = await _getAllMedicationsUseCase();
      medications.value = allMedications.where((med) => med.hasPrescription == true).toList();
      
      // Sort by prescription date if available, otherwise by name

    } catch (e) {
      error.value = 'error_loading_prescriptions'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPrescriptions() async {
    await loadMedications();
  }
}
