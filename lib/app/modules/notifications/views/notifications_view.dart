import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reminder/app/modules/medication/controllers/medication_controller.dart';
import 'package:reminder/app/modules/medications/controllers/medications_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../../../data/models/medication_model.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('notifications'.tr),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.medications.isEmpty) {
                return _buildEmptyState();
              }
              return _buildNotificationsList();
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationsList() {
    final expiredMeds = <MedicationModel>[];
    final lowQuantityMeds = <MedicationModel>[];

    // عملية غير متزامنة للحصول على الأدوية ذات الكمية المنخفضة
    Future<void> _loadLowQuantityMeds() async {
      for (var med in controller.medications) {
        // استدعاء دالة isExpiryDateNear للتحقق من قرب انتهاء الصلاحية
        final isExpiryNear = await Get.find<MedicationsController>().isExpiryDateNear(med);
        if (isExpiryNear) {
          expiredMeds.add(med); // إضافة الدواء إلى قائمة الأدوية المنتهية صلاحيتها
        }

        // استدعاء دالة isQuantitySufficient للتحقق من الكمية
        final isSufficient = await Get.find<MedicationsController>().isQuantitySufficient(med);
        if (!isSufficient) {
          lowQuantityMeds.add(med); // إضافة الدواء إلى قائمة الأدوية ذات الكمية المنخفضة
        }
      }
    }

    return FutureBuilder(
      future: _loadLowQuantityMeds(), // استخدام FutureBuilder لتحميل الأدوية
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (expiredMeds.isNotEmpty) ...[
              _buildSectionHeader('expiring_medications'.tr, Icons.warning, Colors.orange),
              ...expiredMeds.map((med) => _buildMedicationCard(med, isExpiry: true)),
            ],
            if (lowQuantityMeds.isNotEmpty) ...[
              if (expiredMeds.isNotEmpty) const SizedBox(height: 24),
              _buildSectionHeader('low_quantity_medications'.tr, Icons.inventory_2, Colors.red),
              ...lowQuantityMeds.map((med) => _buildMedicationCard(med, isExpiry: false)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNotificationsList22() {
    final expiredMeds = <MedicationModel>[];
    final lowQuantityMeds = <MedicationModel>[];

    // final con = Get.put(()=>MedicationsController());
    // عملية غير متزامنة للحصول على الأدوية ذات الكمية المنخفضة
    Future<void> _loadLowQuantityMeds() async {
      for (var med in controller.medications) {
        if (med.expiryDate != null) {
          final daysUntilExpiry = med.expiryDate!.difference(DateTime.now()).inDays;
          if (daysUntilExpiry >= controller.expiryDaysThreshold.value) {
            expiredMeds.add(med);
          }
        }

        // استدعاء دالة isQuantitySufficient للتحقق من الكمية
        final isSufficient = await Get.find<MedicationsController>().isQuantitySufficient(med);
        if (!isSufficient) {
          lowQuantityMeds.add(med);
        }
      }
    }

    return FutureBuilder(
      future: _loadLowQuantityMeds(), // استخدام FutureBuilder لتحميل الأدوية
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (expiredMeds.isNotEmpty) ...[
              _buildSectionHeader('expiring_medications'.tr, Icons.warning, Colors.orange),
              ...expiredMeds.map((med) => _buildMedicationCard(med, isExpiry: true)),
            ],
            if (lowQuantityMeds.isNotEmpty) ...[
              if (expiredMeds.isNotEmpty) const SizedBox(height: 24),
              _buildSectionHeader('low_quantity_medications'.tr, Icons.inventory_2, Colors.red),
              ...lowQuantityMeds.map((med) => _buildMedicationCard(med, isExpiry: false)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNotificationsList2() {
    final expiredMeds = <MedicationModel>[];
    final lowQuantityMeds = <MedicationModel>[];

    for (var med in controller.medications) {
      if (med.expiryDate != null) {
        final daysUntilExpiry = med.expiryDate!.difference(DateTime.now()).inDays;
        if (daysUntilExpiry >= controller.expiryDaysThreshold.value) {
          expiredMeds.add(med);
        }
      }
      if (med.doseQuantity <= controller.quantityThreshold.value) {
        lowQuantityMeds.add(med);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (expiredMeds.isNotEmpty) ...[
          _buildSectionHeader('expiring_medications'.tr, Icons.warning, Colors.orange),
          ...expiredMeds.map((med) => _buildMedicationCard(med, isExpiry: false)),
        ],
        if (lowQuantityMeds.isNotEmpty) ...[
          if (expiredMeds.isNotEmpty) const SizedBox(height: 24),
          _buildSectionHeader('low_quantity_medications'.tr, Icons.inventory_2, Colors.red),
          ...lowQuantityMeds.map((med) => _buildMedicationCard(med, isExpiry: false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(MedicationModel medication, {required bool isExpiry}) {
    final daysUntilExpiry = medication.expiryDate?.difference(DateTime.now()).inDays;
    final color = isExpiry ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpiry ? Icons.event : Icons.inventory_2,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isExpiry && daysUntilExpiry != null)
                      Text(
                        daysUntilExpiry <= 0
                            ? 'expired'.tr
                            : 'expires_in_days'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                      )
                    else if (!isExpiry)
                      Text(
                        'quantity_remaining'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'notifications_description'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
