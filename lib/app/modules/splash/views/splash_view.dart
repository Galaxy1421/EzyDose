import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/splash_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashView extends GetView<SplashController> {
  SplashView({Key? key}) : super(key: key);

  final PageController pageController = PageController();

  final List<OnboardingContent> contents = [
    OnboardingContent(
      title: 'onboarding_track_title'.tr,
      description: 'onboarding_track_desc'.tr,
      image: 'assets/images/logo.png',
    ),
    OnboardingContent(
      title: 'onboarding_reminder_title'.tr,
      description: 'onboarding_reminder_desc'.tr,
      image: 'assets/images/logo.png',
    ),
    OnboardingContent(
      title: 'onboarding_health_title'.tr,
      description: 'onboarding_health_desc'.tr,
      image: 'assets/images/logo.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() => controller.isLoading.value
            ? _buildLoadingView()
            : _buildOnboardingView()),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            // decoration: BoxDecoration(
            //   color: AppColors.primary.withOpacity(0.1),
            //   shape: BoxShape.circle,
            // ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'app_name'.tr,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingView() {
    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: controller.updatePage,
          itemCount: contents.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: Get.width * 0.7,
                    height: Get.width * 0.7,
                    // decoration: BoxDecoration(
                    //   color: AppColors.primary.withOpacity(0.1),
                    //   shape: BoxShape.circle,
                    // ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Image.asset(
                        contents[index].image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    contents[index].title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    contents[index].description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmoothPageIndicator(
                  controller: pageController,
                  count: contents.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 4,
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                Obx(() {
                  final isLastPage = controller.currentPage.value == contents.length - 1;
                  return Row(
                    children: [
                      if (!isLastPage) ...[
                        TextButton(
                          onPressed: () => controller.skip(),
                          child: Text(
                            'onboarding_skip'.tr,
                            style: GoogleFonts.poppins(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'onboarding_next'.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ] else
                        ElevatedButton(
                          onPressed: () => controller.skip(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'onboarding_start'.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}
