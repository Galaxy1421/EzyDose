import 'package:get/get.dart';
import '../services/storage_service.dart';

class StorageBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<StorageService>(() => StorageService().init());
  }
}
