import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

class LanguageService extends GetxService {
  final _box = GetStorage();
  final _key = 'language';

  // Get saved language code
  String get languageCode => _box.read(_key) ?? 'en';

  // Save selected language code
  Future<void> saveLanguage(String code) async {
    await _box.write(_key, code);
    await updateLocale(code);
  }

  // Update app locale
  Future<void> updateLocale(String code) async {
    await initializeDateFormatting(code, null);
    Get.updateLocale(Locale(code));
  }

  // Initialize language service
  Future<LanguageService> init() async {
    await GetStorage.init();
    String savedCode = languageCode;
    await initializeDateFormatting(savedCode, null);
    await updateLocale(savedCode);
    return this;
  }
}
