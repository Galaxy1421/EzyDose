import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();

    return ListTile(
      title: Text('language'.tr),
      subtitle: Text(languageService.languageCode == 'ar' ? 'arabic'.tr : 'english'.tr),
      trailing: const Icon(Icons.language),
      onTap: () => _showLanguageDialog(context, languageService),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('english'.tr),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: languageService.languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      languageService.saveLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('arabic'.tr),
                leading: Radio<String>(
                  value: 'ar',
                  groupValue: languageService.languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      languageService.saveLanguage(value);
                      Navigator.pop(context);
                    }
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
