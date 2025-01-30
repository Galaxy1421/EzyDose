import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:reminder/app/core/snackbar_services.dart';
import 'package:reminder/app/modules/medication/controllers/medication_controller.dart';
import 'package:reminder/app/modules/medication/views/add_medication_view.dart';
import 'package:reminder/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/interaction_model.dart';
import '../controllers/custom_medication_contoller.dart';
import '../controllers/medications_controller.dart';

class MedicationsView extends GetView<MedicationsController> {
  MedicationsView({Key? key}) : super(key: key);

  final CustomMedicationController medicationController = Get.find();

  Future<void> preloadQuantities2() async {
    for (var medication in medicationController.medications) {
      final isSufficient = await Get.find<MedicationsController>().isQuantitySufficient(medication);
      medication.isQuantitySufficient = isSufficient; // افترض أن `MedicationModel` به هذا الحقل.
    }
  }

  Future<void> preloadMedicationData() async {
    for (var medication in medicationController.medications) {
      final isQuantitySufficient = await Get.find<MedicationsController>().isQuantitySufficient(medication);
      final isExpiryDateNear = await Get.find<MedicationsController>().isExpiryDateNear(medication);

      // تخزين القيم المحسوبة داخل كائن الدواء
      medication.isQuantitySufficient = isQuantitySufficient;
      medication.isExpiryDateNear = isExpiryDateNear;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          if (medicationController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (medicationController.medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_medications'.tr,
                    style: TextStyle(fontSize: 16, color: AppColors.textLight, height: 2.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.all(8.0),
                    child: InkWell(
                      radius: 50,
                      onTap: () {
                        Get.toNamed(Routes.ADD_MEDICATION);
                      },
                      child: Text(
                        'add_medication_hint'.tr,
                        style: TextStyle(
                            fontSize: 16,
                            // color: AppColors.textLight,
                            color: Colors.blueGrey,
                            height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return FutureBuilder(
            future: preloadMedicationData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: medicationController.medications.length,
                itemBuilder: (context, index) {
                  final medication = medicationController.medications[index];
                  return _buildMedicationCard(medication);
                },
              );
            },
          );
          // return ListView.builder(
          //   padding: const EdgeInsets.all(16),
          //   itemCount: medicationController.medications.length,
          //   itemBuilder: (context, index) {
          //     final medication = medicationController.medications[index];
          //     return _buildMedicationCard(medication);
          //   },
          // );
        }),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => Get.toNamed('/add-medication'),
        //   backgroundColor: AppColors.primary,
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
      ),
    );
  }

  int getDaysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();

    // تعيين الوقت لكلا التاريخين إلى منتصف الليل
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    return expiry.difference(today).inDays;
  }

  bool isExpiredMedication(DateTime expiryDate) {
    final now = DateTime.now();
    return now.isAfter(expiryDate); // التحقق إذا كان اليوم بعد تاريخ الصلاحية
  }

  // todo :: _buildMedicationCard
  Widget _buildMedicationCard(MedicationModel medication) {
    final isExpired = (medication.expiryDate != null) ? isExpiredMedication(medication.expiryDate!) : false;

    print("medication.isQuantitySufficient ${medication.isQuantitySufficient}");
    return Stack(
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: medication.isExpiryDateNear == true
                    ? Colors.red
                    : (medication.isQuantitySufficient == false)
                        ? Colors.deepOrange
                        : Colors.grey.withOpacity(.3),
              ),
              borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Theme(
            data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: [
                if (medication.expiryDate != null)
                  if (medication.isExpiryDateNear == true)
                    Container(
                      // height: 30,
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: Color(0xFFff0000).withOpacity(.9),
                          // color: Color(0xFFa41532).withOpacity(1),
                          // color: Color(0xFF420014).withOpacity(1),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // for(int i=0;i<=2;i++)
                          Container(
                              margin: EdgeInsets.only(left: 4, right: 4, bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, size: 13, color: Colors.white),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  isExpired
                                      ? Text(
                                          'منتهي الصلاحية',
                                          // 'low_quantity_warning2'.tr +"\t" + " ["+medication.doseQuantity.toString()+"] " +medication.unit.toString()+' '+'only'.tr,
                                          style: TextStyle(
                                              fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, height: 2),
                                        )
                                      : Text(
                                          'expiry_warning'.tr + ": " + "${(getDaysUntilExpiry(medication.expiryDate!)).toString()} " + 'day'.tr,
                                          // 'low_quantity_warning2'.tr +"\t" + " ["+medication.doseQuantity.toString()+"] " +medication.unit.toString()+' '+'only'.tr,
                                          style: TextStyle(
                                              fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, height: 2),
                                        ),

                                  // Spacer(),
                                ],
                              )),
                        ],
                      ),
                    ),
                if (medication.isQuantitySufficient == false)
                  Container(
                    // height: 30,
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: (medication.isExpiryDateNear == true)
                            ? BorderRadius.zero
                            : BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // for(int i=0;i<=2;i++)
                        Container(
                            margin: EdgeInsets.only(left: 4, right: 4, bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.error, size: 13, color: Colors.deepOrange),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'low_quantity_warning2'.tr +
                                      "\t" +
                                      " [" +
                                      medication.doseQuantity.toString() +
                                      "] " +
                                      medication.unit.toString() +
                                      ' ' +
                                      'only'.tr,
                                  style:
                                      TextStyle(fontFamily: 'Cairo', color: Colors.deepOrange, fontWeight: FontWeight.w600, fontSize: 12, height: 2),
                                ),

                                //todo :: sync
                                // Spacer(),
                                // InkResponse(
                                //     onTap: (){
                                //
                                //     },
                                //     child: Icon(Icons.sync,size: 20,color: Colors.lightBlue,))
                              ],
                            )),
                      ],
                    ),
                  ),
                ExpansionTile(
                    onExpansionChanged: (v) {
                      if (v == false) {
                        controller.showMore.value = false;
                      }
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            medication.optionalName.isNotEmpty ? medication.optionalName : medication.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: (isExpired) ? TextDecoration.lineThrough : null,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationThickness: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${medication.doseQuantity} ${medication.unit.toString().tr} ${'per_dose'.tr}',
                          style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 2),
                        ),
                        if (medication.expiryDate != null)
                          Text(
                            '${'expires'.tr}: ${controller.formatDate(medication.expiryDate)}',
                            style: TextStyle(fontSize: 13, color: isExpired ? Colors.red : AppColors.textLight, height: 1.5),
                          ),

                        // if(medication.isQuantitySufficient==false)
                        // Text(
                        //   'low_quantity_warning2'.tr + ' ${(medication.doseQuantity).toString() + medication.unit.toString()} ' + 'only'.tr,
                        //     style: TextStyle(
                        //       fontFamily: 'Cairo',
                        //       fontSize: 12,
                        //       color: Colors.orangeAccent,
                        //     ),
                        //   ),
                      ],
                    ),
                    leading: SizedBox(
                      width: 60, // Adjust the width as needed
                      child: GestureDetector(
                        onTap: () {
                          if (medication.imageUrl != null) AppDialog.showImageDialog(Get.context!, medication.imageUrl!);
                        },
                        child: Container(
                          // padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withOpacity(.1))),
                          child: medication.imageUrl != null && medication.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: medication.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.primary,
                                    size: 40,
                                  ),
                                )
                              : Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => controller.showMedicationOptions(medication),
                    ),
                    children: [
                      Obx(() => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                _buildDetailRow('ATC Code', '${medication.medicineModelDataSet?.atcCode1} '),
                                _buildDetailRow( Get.locale?.languageCode == 'ar'?'وحدة الدواء':'Unit',
                                    '${(medication.medicineModelDataSet != null) ? medication.medicineModelDataSet!.unit.toString() : medication.unit}'),
                                _buildDetailRow('total_quantity'.tr, '${medication.totalQuantity} '),

                                FutureBuilder<int>(
                                  future: controller.calculateTakenReminders(medication.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return SizedBox(
                                        // width: 20,
                                        // height: 20,
                                        child: Row(
                                          children: [
                                            Text('remaining'.tr),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            SizedBox(
                                                width: 14,
                                                height: 14,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                )),
                                          ],
                                        ),
                                      );
                                    }

                                    final takenQuantity = snapshot.data ?? 0;

                                    final remainingQuantity = medication.totalQuantity - takenQuantity;
                                    return _buildDetailRow('remaining'.tr, '${remainingQuantity} ');
                                  },
                                ),
                                if (!(controller.showMore.value))
                                  GestureDetector(
                                    onTap: () {
                                      // setState(() {
                                      controller.showMore.value = !(controller.showMore.value); // تغيير حالة العرض
                                      // });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (controller.showMore.value) ? 'Show Less' : 'Show More',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          Icon(
                                            (controller.showMore.value) ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                            color: Colors.blueGrey,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (controller.showMore.value)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (medication.medicineModelDataSet != null) ...[
                                        // _buildDetailRow('constraint',
                                        //     '${(medication.medicineModelDataSet != null) ? medication.medicineModelDataSet!.constraint.toString() : ''}'),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(top: 7),
                                                  child: Icon(Icons.circle,size: 5,color: Colors.red,)),
                                              const SizedBox(width: 3,),
                                              Text(
                                                Get.locale?.languageCode == 'ar'?'تعليمات':'Constraint',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade800.withOpacity(0.7), // لون شفاف للنص
                                                ),
                                              ),
                                              const SizedBox(width: 4,),
                                              Expanded(
                                                child: Text(
                                                  '${(medication.medicineModelDataSet != null) ? medication.medicineModelDataSet!.constraint.toString() : ''}',
                                                  textAlign: TextAlign.end,

                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade900,
                                                  ),
                                                  softWrap: true, // السماح بلف النص إلى سطر جديد إذا لزم الأمر
                                                ),
                                              ),
                                              // Text(
                                              //   '${(medication.medicineModelDataSet != null) ? medication.medicineModelDataSet!.constraint.toString() : ''}',
                                              //   style: TextStyle(
                                              //     fontSize: 13,
                                              //     fontWeight: FontWeight.bold,
                                              //     color: Colors.grey.shade900,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        )
                                      ],
                                      // Get.locale?.languageCode == 'ar'?'تعليمات':'Constraint'
                                      _buildDetailRow( Get.locale?.languageCode == 'ar'?'تاريخ الإنشاء':'Creation Date',
                                          '${intl.DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(medication.createdAt.toString()))}'),
                                    ],
                                  ),
                                if ((controller.showMore.value))
                                  GestureDetector(
                                    onTap: () {
                                      // setState(() {
                                      controller.showMore.value = !(controller.showMore.value); // تغيير حالة العرض
                                      // });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (controller.showMore.value) ? 'Show Less' : 'Show More',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          Icon(
                                            (controller.showMore.value) ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                            color: Colors.blueGrey,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ]
                    // children: [
                    //   Padding(
                    //     padding: const EdgeInsets.all(16),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         if (medication.instructions.isNotEmpty) ...[
                    //           Text(
                    //             'instructions'.tr,
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 4),
                    //           Text(
                    //             medication.instructions,
                    //             style: GoogleFonts.poppins(fontSize: 14),
                    //           ),
                    //           const SizedBox(height: 16),
                    //         ],
                    //
                    //         // Quantity Section
                    //         Row(
                    //           children: [
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'total_quantity'.tr,
                    //                     style: GoogleFonts.poppins(
                    //                       fontSize: 14,
                    //                       fontWeight: FontWeight.w600,
                    //                     ),
                    //                   ),
                    //                   Text(
                    //                     '${medication.totalQuantity} ${medication.unit}',
                    //                     style: GoogleFonts.poppins(fontSize: 14),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'remaining'.tr,
                    //                     style: GoogleFonts.poppins(
                    //                       fontSize: 14,
                    //                       fontWeight: FontWeight.w600,
                    //                     ),
                    //                   ),
                    //                   FutureBuilder<int>(
                    //                     future: controller.calculateTakenReminders(medication.id),
                    //                     builder: (context, snapshot) {
                    //                       if (snapshot.connectionState == ConnectionState.waiting) {
                    //                         return const SizedBox(
                    //                           width: 20,
                    //                           height: 20,
                    //                           child: CircularProgressIndicator(strokeWidth: 2),
                    //                         );
                    //                       }
                    //
                    //                       final takenQuantity = snapshot.data ?? 0;
                    //
                    //                       final remainingQuantity = medication.totalQuantity - takenQuantity;
                    //
                    //                       return Text(
                    //                         '${remainingQuantity} ${medication.unit}',
                    //                         style: GoogleFonts.poppins(
                    //                           fontSize: 14,
                    //                           color: remainingQuantity <= 5 ? Colors.red : AppColors.textLight,
                    //                         ),
                    //                       );
                    //                     },
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //
                    //         // Interactions Section
                    //         if (medication.interactions.isNotEmpty) ...[
                    //           const SizedBox(height: 16),
                    //           Text(
                    //             'interactions'.tr,
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 8),
                    //           ...medication.interactions.map((interaction) => ListTile(
                    //                 contentPadding: EdgeInsets.zero,
                    //                 leading: Icon(
                    //                   Icons.warning,
                    //                   color: _getInteractionColor(interaction),
                    //                 ),
                    //                 title: Text(
                    //                   interaction.medicationName,
                    //                   style: GoogleFonts.poppins(
                    //                     fontWeight: FontWeight.w500,
                    //                   ),
                    //                 ),
                    //                 subtitle: Column(
                    //                   crossAxisAlignment: CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text(
                    //                       interaction.description,
                    //                       style: GoogleFonts.poppins(fontSize: 12),
                    //                     ),
                    //                     Text(
                    //                       'recommendation'.tr + ': ${interaction.recommendation}',
                    //                       style: GoogleFonts.poppins(
                    //                         fontSize: 12,
                    //                         fontStyle: FontStyle.italic,
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               )),
                    //         ],
                    //
                    //
                    //       ],
                    //     ),
                    //   ),
                    // ],
                    ),
              ],
            ),
          ),
        ),
        if (false)
          if (medication.expiryDate != null) //
            if (isExpiredMedication(medication.expiryDate!))
              Positioned.fill(
                  child: GestureDetector(
                // onTap: (){},
                child: Card(
                  color: Colors.black.withOpacity(.09), margin: const EdgeInsets.only(bottom: 16),
                  // child: Center(child: ExpiredStamp(),),
                ),
              ))
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle,size: 5,color: Colors.red,),
          const SizedBox(width: 3,),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800.withOpacity(0.7), // لون شفاف للنص
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Color _getInteractionColor(InteractionModel interaction) {
    switch (interaction.riskLevel) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.moderate:
        return Colors.orange;
      case RiskLevel.low:
        return Colors.yellow;
      case RiskLevel.none:
        return Colors.green;
    }
  }
}

class ExpiredStamp extends StatelessWidget {
  const ExpiredStamp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("object");
      },
      child: Container(
        width: 200,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.red, // الخلفية الحمراء
          borderRadius: BorderRadius.circular(12), // الزوايا المستديرة
        ),
        alignment: Alignment.center,
        child: Text(
          "EXPIRED",
          style: TextStyle(
            color: Colors.white, // النص الأبيض
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4, // تباعد الأحرف
          ),
        ),
      ),
    );
  }
}
