

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppHelper{
  static String formatTimeBasedOnLanguage(DateTime dateTime) {
    final bool isArabic = Get.locale?.languageCode == 'ar'; // التحقق من اللغة العربية

    // تنسيق الوقت بدون صفر في البداية
    String formattedTime = DateFormat('h:mm a').format(dateTime);

    // إذا كانت اللغة عربية، نستبدل AM وPM بـ ص و م
    if (isArabic) {
      formattedTime = formattedTime
          .replaceAll('AM', 'ص')
          .replaceAll('PM', 'م');

      // تحويل الأرقام الإنجليزية إلى عربية
      formattedTime = convertToArabicNumerals(formattedTime);
    }

    // إذا كانت اللغة إنجليزية، نعيد الوقت كما هو
    return formattedTime;
  }

  static String convertToArabicNumerals(String input) {
    const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < englishNumerals.length; i++) {
      input = input.replaceAll(englishNumerals[i], arabicNumerals[i]);
    }

    return input;
  }
static bool get isArabic => Get.locale?.languageCode == 'ar';
}