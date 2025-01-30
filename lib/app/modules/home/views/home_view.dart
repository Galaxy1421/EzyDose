import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder/app/modules/profile/controllers/profile_controller.dart';
import 'package:reminder/app/routes/app_pages.dart';
import 'package:reminder/excel_search.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../medications/views/medications_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  Widget _buildProfileImage() {
    final controller = Get.find<ProfileController>();
    String? imageSource = controller.user.value.imageBase64.toString();
    if (imageSource == null || imageSource.isEmpty) {
      return Icon(
        Icons.person,
        size: 24, // حجم الأيقونة داخل الحاوية
        color: Colors.grey.shade700,
      );
    }

    if (imageSource.startsWith('http')) {
      // إذا كان المصدر URL
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 24,
            color: Colors.grey.shade700,
          );
        },
      );
    } else {
      // إذا كان المصدر Base64
      try {
        return Image.memory(
          base64Decode(imageSource),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 24,
              color: Colors.grey.shade700,
            );
          },
        );
      } catch (e) {
        return Icon(
          Icons.person,
          size: 24,
          color: Colors.grey.shade700,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          centerTitle: true,
          // backgroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          leading: SizedBox(
            width: 30,
            height: 30,
            child: Container(
              margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white, // خلفية بيضاء
                shape: BoxShape.circle, // شكل دائري
                border: Border.all(color: Colors.lightBlueAccent, width: 0.6),
              ),
              child: ClipOval(
                child: _buildProfileImage(),
              ),
            ),
          ),

          // leading: SizedBox(
          //   width: 30,
          //   height: 30,
          //   child:Container(
          //
          //     // padding: EdgeInsets.all(8),
          //     // color: Colors.red,
          //     child: Container(
          //         margin: EdgeInsets.all(7),
          //
          //         decoration: BoxDecoration(
          //           // color: Colors.blue,
          //           color: Colors.white,
          //           shape: BoxShape.circle,
          //           border: Border.all(color: Colors.lightBlueAccent,width: .6)
          //         ),
          //         child: Icon(Icons.person,color: Colors.grey.shade700,)),
          //   ),
          // ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8), // مسافة حول الزر
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // زوايا دائرية
                ),
                elevation: 0, // ارتفاع الظل
                child: InkWell(
                  borderRadius: BorderRadius.circular(12), // تأثير الضغط
                  onTap: () {
                    // قم بإضافة الإجراء المطلوب هنا
                    print("Button Pressed");
                    Get.toNamed(Routes.ADD_MEDICATION);
                  },
                  child: Container(
                    width: 50, // عرض الزر
                    height: 50, // ارتفاع الزر
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white
                      // gradient: const LinearGradient(
                      //   colors: [Colors.white, Colors.white], // تدرج ألوان
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
                    ),
                    child: const Center( // مركز الأيقونة داخل الحاوية
                      child: Icon(
                        Icons.add,
                        color: Colors.black, // لون الأيقونة
                        size: 24, // حجم الأيقونة
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
,
          title: Obx(() => Text(
                controller.currentTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
        body: Column(
          children: [
            // Container(
            //   decoration: BoxDecoration(color: AppColors.primary
            //       // color: Colors.red,
            //       // gradient: AppColors.primaryGradient,
            //       // borderRadius: const BorderRadius.only(
            //       //   bottomLeft: Radius.circular(30),
            //       //   bottomRight: Radius.circular(30),
            //       // ),
            //       ),
            //   child: SafeArea(
            //     bottom: false,
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           // Image.asset("assets/images/logo.png",width: 40,),
            //           // Spacer(),
            //           Obx(() => Text(
            //                 controller.currentTitle,
            //                 style: const TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 24,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               )),
            //           // Spacer(),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.currentIndex.value,
                  children: [
                    DashboardView(),
                    MedicationsView(),
                    ProfileView(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'dashboard'.tr),
                    _buildNavItem(1, Icons.medication_outlined, Icons.medication, 'medications'.tr),
                    _buildNavItem(2, Icons.person_outline, Icons.person, 'profile'.tr),
                  ],
                ),
              ),
            ),
          ),
        ),

        // bottomNavigationBar: Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     boxShadow: [
        //       BoxShadow(
        //         color: AppColors.primary.withOpacity(0.1),
        //         blurRadius: 20,
        //         offset: const Offset(0, -5),
        //       ),
        //     ],
        //   ),
        //   child: SafeArea(
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //       child: SizedBox(
        //         height: 60,
        //         child: Obx(
        //           () => Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceAround,
        //             children: [
        //               _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'dashboard'.tr),
        //               _buildNavItem(1, Icons.medication_outlined, Icons.medication, 'medications'.tr),
        //               _buildNavItem(2, Icons.person_outline, Icons.person, 'profile'.tr),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        floatingActionButton:(true)?null: FloatingActionButton(
          // mini: true,

          heroTag: null,
          onPressed: () => Get.toNamed(Routes.ADD_MEDICATION),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
          elevation: 4,
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => Get.toNamed(Routes.ADD_MEDICATION),
        //   // onPressed: () {
        //   //   Get.snackbar('Notes', 'App is under development');
        //   // },
        //   backgroundColor: AppColors.primary,
        //   child: const Icon(Icons.add, color: Colors.red),
        //   elevation: 4,
        // ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 24,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem2(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedBuilder(
          animation: controller.animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? controller.iconAnimations[index].value : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 22,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
