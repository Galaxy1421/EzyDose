import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDialog{
  static final AppDialog _instance = AppDialog._internal();

  AppDialog._internal();

  factory AppDialog() {
    return _instance;
  }



 static void showLoadingDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // منع المستخدم من إغلاق الـ Dialog بالضغط خارجها
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(), // مؤشر التحميل
                  SizedBox(height: 16),
                  Text(
                    Get.locale?.languageCode == 'ar'
                        ? 'جاري الحفظ...'
                        : 'Saving...',
                    style: const TextStyle(fontSize: 16),
                  )
,
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false, // منع إغلاق الـ Dialog بالضغط خارجها
    );
  }

  static   void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // لجعل خلفية الديالوج شفافة
          insetPadding: EdgeInsets.all(20), // هامش حول الصورة
          child: Stack(
            children: [
              // الصورة المعروضة بشكل كبير
              ClipRRect(
                borderRadius: BorderRadius.circular(12), // زوايا مستديرة
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              // زر الإغلاق في الزاوية العلوية اليمنى
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // إغلاق الديالوج
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
class SnackbarService {
  // الخطوة 1: إنشاء كائن ثابت يمثل الـ Singleton
  static final SnackbarService _instance = SnackbarService._internal();

  // الخطوة 2: تعريف البناء الخاص بالنمط Singleton
  SnackbarService._internal();

  // الخطوة 3: إرجاع نفس الكائن دائمًا
  factory SnackbarService() {
    return _instance;
  }

  // طريقة لإظهار Snackbar نجاح
  void showSuccess(String message) {
    Get.snackbar(
      'success'.tr, // العنوان (يمكن ترجمته)
      message, // الرسالة
      snackPosition: SnackPosition.TOP, // موقع الإشعار
      backgroundColor: Colors.green.withOpacity(0.9), // خلفية نصف شفافة
      colorText: Colors.white, // لون النص
      borderRadius: 12, // الحواف المستديرة
      margin: const EdgeInsets.all(12), // الهامش حول الإشعار
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 28), // أيقونة النجاح
      duration: const Duration(seconds: 2), // مدة العرض
      animationDuration: const Duration(milliseconds: 300), // سرعة الحركة
      isDismissible: true, // السماح بالإغلاق بالسحب
      forwardAnimationCurve: Curves.easeOutBack, // حركة الدخول
      reverseAnimationCurve: Curves.easeIn, // حركة الخروج
      snackStyle: SnackStyle.FLOATING, // الإشعار العائم
    );
  }

  // طريقة لإظهار Snackbar خطأ
  void showError(String message) {
    Get.snackbar(
      'error'.tr, // العنوان (يتم ترجمته)
      message, // الرسالة
      snackPosition: SnackPosition.TOP, // موقع الإشعار
      backgroundColor: Colors.red.withOpacity(0.9), // لون الخلفية أحمر شفاف
      colorText: Colors.white, // النص باللون الأبيض
      borderRadius: 12, // الحواف مستديرة
      margin: const EdgeInsets.all(12), // الهامش حول الإشعار
      icon: const Icon(Icons.error, color: Colors.white, size: 28), // أيقونة الخطأ
      duration: const Duration(seconds: 3), // مدة العرض
      animationDuration: const Duration(milliseconds: 300), // سرعة الحركة
      isDismissible: true, // السماح بالإغلاق بالسحب
      forwardAnimationCurve: Curves.easeOutBack, // حركة الدخول
      reverseAnimationCurve: Curves.easeIn, // حركة الخروج
      snackStyle: SnackStyle.FLOATING, // النمط العائم
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3), // ظل خفيف للإشعار
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ], // إضافة ظل خفيف
    );
  }
  void showWarning(String message) {
    Get.snackbar(
      'warning'.tr, // العنوان (يتم ترجمته)
      message, // الرسالة
      snackPosition: SnackPosition.TOP, // موقع الإشعار
      backgroundColor: Colors.deepOrange.withOpacity(0.9), // لون الخلفية أحمر شفاف
      colorText: Colors.white, // النص باللون الأبيض
      borderRadius: 12, // الحواف مستديرة
      margin: const EdgeInsets.all(12), // الهامش حول الإشعار
      icon: const Icon(Icons.error, color: Colors.white, size: 28), // أيقونة الخطأ
      duration: const Duration(seconds: 3), // مدة العرض
      animationDuration: const Duration(milliseconds: 300), // سرعة الحركة
      isDismissible: true, // السماح بالإغلاق بالسحب
      forwardAnimationCurve: Curves.easeOutBack, // حركة الدخول
      reverseAnimationCurve: Curves.easeIn, // حركة الخروج
      snackStyle: SnackStyle.FLOATING, // النمط العائم
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3), // ظل خفيف للإشعار
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ], // إضافة ظل خفيف
    );
  }

  void showMultipleErrors(List<String> errorMessages) {
    String errors = '';
    for (var message in errorMessages) {
      errors += '⬤ $message\n'; // إضافة "⬤" في بداية كل رسالة
    }

    Get.snackbar(
      'error'.tr, // العنوان (يتم ترجمته)
      errors, // الرسائل المجتمعة
      snackPosition: SnackPosition.TOP, // موقع الإشعار
      backgroundColor: Colors.red.withOpacity(0.9), // لون الخلفية أحمر شفاف
      colorText: Colors.white, // النص باللون الأبيض
      borderRadius: 12, // الحواف مستديرة
      margin: const EdgeInsets.all(12), // الهامش حول الإشعار
      icon: const Icon(Icons.error, color: Colors.white, size: 28), // أيقونة الخطأ
      duration: const Duration(seconds: 4), // مدة العرض
      animationDuration: const Duration(milliseconds: 300), // سرعة الحركة
      isDismissible: true, // السماح بالإغلاق بالسحب
      forwardAnimationCurve: Curves.easeOutBack, // حركة الدخول
      reverseAnimationCurve: Curves.easeIn, // حركة الخروج
      snackStyle: SnackStyle.FLOATING, // النمط العائم
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3), // ظل خفيف للإشعار
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ], // إضافة ظل خفيف
    );
  }
}
