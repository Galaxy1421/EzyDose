import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reminder/app/core/theme/app_colors.dart';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:reminder/app/data/models/medication_model_dataset.dart';

class DialogFb3 extends StatelessWidget {
  const DialogFb3({super.key});

  final primaryColor = const Color(0xff4338CA);
  final secondaryColor = const Color(0xff6D28D9);
  final accentColor = const Color(0xffffffff);
  final backgroundColor = const Color(0xffffffff);
  final errorColor = const Color(0xffEF4444);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    width: 300,
                    height: MediaQuery.of(context).size.height / 5,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor]),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(12, 26),
                              blurRadius: 50,
                              spreadRadius: 0,
                              color: Colors.grey.withOpacity(.1)),
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: accentColor.withOpacity(.05),
                          radius: 25,
                          child: Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/FlutterBricksLogo-Med.png?alt=media&token=7d03fedc-75b8-44d5-a4be-c1878de7ed52"),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text("How are you doing?",
                            style: TextStyle(
                                color: accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 3.5,
                        ),
                        Text("This is a sub text, use it to clarify",
                            style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w300)),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: const Text('Gradient Dialog'));
  }
}


//================================
//================================
//================================

//
// class CustomDropdownExample extends StatefulWidget {
//   const CustomDropdownExample({super.key});
//
//   @override
//   State<CustomDropdownExample> createState() => _CustomDropdownExampleState();
// }
//
// class _CustomDropdownExampleState extends State<CustomDropdownExample> {
//   final SingleSelectController<String?> jobRoleCtrl =
//   SingleSelectController('');
//
//   Future<List<String>> getFakeRequestData(String query) async {
//     List<String> data = ['Developer', 'Designer', 'Consultant', 'Student'];
//
//     return await Future.delayed(const Duration(seconds: 1), () {
//       return data.where((e) {
//         return e.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomDropdown.searchRequest(
//       futureRequest: getFakeRequestData,
//
//       hintBuilder: (context, hint, enabled) {
//         return Text(
//           hint,
//           style: const TextStyle(color: Colors.black),
//         );
//       },
//       hintText: 'Search job role',
//
//       decoration: CustomDropdownDecoration(hintStyle: TextStyle(color: Colors.grey),),
//       onChanged: (value) {},
//       controller: jobRoleCtrl,
//       searchHintText: 'Developer',
//       futureRequestDelay: const Duration(seconds: 3),
//     );
//   }
// }


class CustomDropdownExample extends StatefulWidget {
  const CustomDropdownExample({super.key});

  @override
  State<CustomDropdownExample> createState() => _CustomDropdownExampleState();
}

class _CustomDropdownExampleState extends State<CustomDropdownExample> {
  final SingleSelectController<MedicineModelDataSet?> medicineCtrl = SingleSelectController<MedicineModelDataSet?>(null);

  Future<List<MedicineModelDataSet>> readExcelData() async {
    final ByteData data = await rootBundle.load('assets/dataSet/Medicines Dataset2.xlsx');
    final Uint8List bytes = data.buffer.asUint8List();
    final Excel excel = Excel.decodeBytes(bytes);

    List<MedicineModelDataSet> medicines = [];

    var sheet = excel.tables['sheet1 (2)'];

    if (sheet != null) {
      for (var row in sheet.rows) {
        if (row.length >= 13) { // التأكد من أن الصف يحتوي على بيانات كافية
          // medicines.add(MedicineModelDataSet(
          //   atcCode1: row[0]?.value.toString(), // العمود 1: AtcCode1
          //   tradeName: row[1]?.value.toString(), // العمود 2: Trade Name
          //   constraint: row[2]?.value.toString(), // العمود 3: constraint
          //   atcCode1Interact: row[3]?.value.toString(), // العمود 4: AtcCode1 Interact
          //   timingGap1: row[4]?.value.toString(), // العمود 5: timing gap1 (in minutes)
          //   atcCode2Interact: row[5]?.value.toString(), // العمود 6: AtcCode2 Interact
          //   timingGap2: row[6]?.value.toString(), // العمود 7: timing gap2 (in minutes)
          //   major: row[7]?.value.toString(), // العمود 8: Major
          //   moderate: row[8]?.value.toString(), // العمود 9: Moderate
          //   minor: row[9]?.value.toString(), // العمود 10: Minor
          //   packageSize: row[10]?.value.toString(), // العمود 11: PackageSize
          //   unit: row[11]?.value.toString(), // العمود 12: Unit
          //   photoLink: row[12]?.value.toString(), // العمود 13: Photo Link
          // ));
        }
      }
    } else {
      print("Sheet 'sheet1 (2)' not found!");
    }

    print("Medicines: $medicines"); // طباعة القائمة للتأكد من البيانات
    return medicines;
  }

  Future<List<MedicineModelDataSet>> getFakeRequestData(String query) async {
    List<MedicineModelDataSet> data = await readExcelData();

    return await Future.delayed(const Duration(seconds: 1), () {
      return data.where((medicine) {
        return medicine.tradeName?.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomDropdown.searchRequest(
            futureRequest: getFakeRequestData,
            hintBuilder: (context, hint, enabled) {
              return Text(
                hint,
                style: const TextStyle(color: Colors.black),
              );
            },
            hintText: 'Search medicine',
            decoration: CustomDropdownDecoration(hintStyle: TextStyle(color: Colors.grey)),
            onChanged: (value) {
              if (value != null) {
                print("Selected Medicine: ${value.tradeName}");
                print("ATC Code 1: ${value.atcCode1}");
                print("Constraint: ${value.constraint}");
                print("Photo Link: ${value.photoLink}");
              }
            },
            controller: medicineCtrl,
          
            searchHintText: 'Medicine name',
            futureRequestDelay: const Duration(seconds: 3),
          
            // itemToString: (item) {
            //   return item.tradeName ?? 'No Trade Name';
            // },
            listItemBuilder: (context, item, isSelected, isHovered) {
              return ListTile(
                // leading:

                  leading: item.photoLink != null
                      ? CachedNetworkImage(
                    imageUrl: item.photoLink!,
                    width: 50, // عرض الصورة
                    height: 50, // ارتفاع الصورة
                    fit: BoxFit.cover, // تغطية المساحة المحددة
                    placeholder: (context, url) => const CircularProgressIndicator(), // مؤشر تحميل أثناء جلب الصورة
                    errorWidget: (context, url, error) => const Icon(
                      Icons.medication,
                      size: 50,
                      color: Colors.grey, // إذا فشل تحميل الصورة، نعرض أيقونة بديلة
                    ),
                  )
                      : const Icon(
                    Icons.medication,
                    size: 50,
                    color: Colors.grey, // أيقونة افتراضية عند عدم وجود رابط صورة
                  ),
 // إذا لم يكن هناك رابط صورة
                title: Text(item.tradeName ?? 'No Trade Name'),
                subtitle: Container(
                    // color: Colors.red,
                    child: Text("ATC Code: ${item.atcCode1 ?? 'No ATC Code'}",
                      style: TextStyle(fontSize: 12,color: Colors.blueGrey),textAlign: TextAlign.start,)),
              );
            },
          ),
          ElevatedButton(onPressed: (){
            print("medicineCtrl.value.atcCode1 ${medicineCtrl.value!.atcCode1.toString()}");
          }, child: Text("ee"))
        ],
      ),
    );
  }
}
//================================
//================================
//================================


class CustomNavBarCurved extends StatefulWidget {
  const CustomNavBarCurved({super.key});

  @override
  CustomNavBarCurvedState createState() => CustomNavBarCurvedState();
}

class CustomNavBarCurvedState extends State<CustomNavBarCurved> {
  // Track selected index
  int _selectedIndex = 0;

  // Update index when an item is tapped
  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different pages based on the tapped index
    switch (index) {
      case 0:
      // Navigate to Home
        break;
      case 1:
      // Navigate to Search
        break;
      case 2:
      // Navigate to Cart
        break;
      case 3:
      // Navigate to Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 56;

    const primaryColor = Colors.amber;
    const secondaryColor = Colors.black54;
    const backgroundColor = Color.fromARGB(255, 195, 181, 181);

    return BottomAppBar(
      color:  Color.fromARGB(255, 195, 181, 181).withOpacity(.4),
      elevation: 0,
      padding: EdgeInsets.zero,

      child: Stack(
        children: [
          // CustomPaint(
          //   size: Size(size.width, height + 7),
          //   painter: BottomNavCurvePainter(backgroundColor: backgroundColor),
          // ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              backgroundColor: AppColors.primary,
              elevation: 0.1,
              onPressed: () {
                // Define action for FAB here
              },
              child: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarIcon(
                  text: "Home",
                  icon: CupertinoIcons.home,
                  selected: _selectedIndex == 0,
                  onPressed: () => _onNavBarItemTapped(0),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: "Search",
                  icon: CupertinoIcons.search,
                  selected: _selectedIndex == 1,
                  onPressed: () => _onNavBarItemTapped(1),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                const SizedBox(width: 56),
                NavBarIcon(
                  text: "Cart",
                  icon: Icons.local_grocery_store_outlined,
                  selected: _selectedIndex == 2,
                  onPressed: () => _onNavBarItemTapped(2),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: "Calendar",
                  icon: CupertinoIcons.person,
                  selected: _selectedIndex == 3,
                  onPressed: () => _onNavBarItemTapped(3),
                  selectedColor: primaryColor,
                  defaultColor: secondaryColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavCurvePainter extends CustomPainter {
  BottomNavCurvePainter(
      {this.backgroundColor = Colors.black, this.insetRadius = 38});

  Color backgroundColor;
  double insetRadius;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;
    path.quadraticBezierTo(size.width * 0.20, 0,
        insetCurveBeginnningX - transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(
        insetCurveBeginnningX, 0, insetCurveBeginnningX, insetRadius / 2);

    path.arcToPoint(Offset(insetCurveEndX, insetRadius / 2),
        radius: const Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(
        insetCurveEndX, 0, insetCurveEndX + transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(
        0,
        size.height +
            56); //+56 here extends the navbar below app bar to include extra space on some screens (iphone 11)
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class NavBarIcon extends StatelessWidget {
  const NavBarIcon(
      {super.key,
        required this.text,
        required this.icon,
        required this.selected,
        required this.onPressed,
        this.selectedColor = const Color(0xffFF8527),
        this.defaultColor = Colors.black54});
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: CircleAvatar(
        backgroundColor: selected ? Colors.white : Colors.transparent,
        child: Icon(
          icon,
          size: 25,
          color: selected ? Colors.black : defaultColor,
        ),
      ),
    );
  }
}


//=========================================================
//=========================================================
//=========================================================



class NeonGradientCardDemo extends StatelessWidget {
  const NeonGradientCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 200,
        child: Center(
          child: Container(
            child: const NeonCard(
              intensity: 0.5,
              glowSpread: .8,
              child: SizedBox(
                width: 300,
                height: 200,
                child: Center(
                  child: GradientText(
                    text: 'Neon\nGradient\nCard',
                    fontSize: 44,
                    gradientColors: [
                      // Pink
                      Color.fromARGB(255, 255, 41, 117),
                      Color.fromARGB(255, 255, 41, 117),
                      Color.fromARGB(255, 9, 221, 222), // Cyan
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeonCard extends StatefulWidget {
  final Widget child;
  final double intensity;
  final double glowSpread;

  const NeonCard({
    super.key,
    required this.child,
    this.intensity = 0.3,
    this.glowSpread = 2.0,
  });

  @override
  _NeonCardState createState() => _NeonCardState();
}

class _NeonCardState extends State<NeonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GlowRectanglePainter(
            progress: _controller.value,
            intensity: widget.intensity,
            glowSpread: widget.glowSpread,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class GlowRectanglePainter extends CustomPainter {
  final double progress;
  final double intensity;
  final double glowSpread;

  GlowRectanglePainter({
    required this.progress,
    this.intensity = 0.3,
    this.glowSpread = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    const firstColor = Color(0xFFFF00AA);
    const secondColor = Color(0xFF00FFF1);
    const blurSigma = 50.0;

    final backgroundPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height / 2),
        size.width * glowSpread,
        [
          Color.lerp(firstColor, secondColor, progress)!.withOpacity(intensity),
          Color.lerp(firstColor, secondColor, progress)!.withOpacity(0.0),
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawRect(rect.inflate(size.width * glowSpread), backgroundPaint);

    final blackPaint = Paint()..color = Colors.black;
    canvas.drawRRect(rrect, blackPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        colors: [
          Color.lerp(firstColor, secondColor, progress)!,
          Color.lerp(secondColor, firstColor, progress)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(GlowRectanglePainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.intensity != intensity ||
          oldDelegate.glowSpread != glowSpread;
}


class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color> gradientColors;

  const GradientText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: gradientColors,
          stops: const [0.0, 0.3, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1,
          letterSpacing: -1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

//=======================================================
//=======================================================
//=======================================================



class ExcelSearch extends StatefulWidget {
  @override
  _ExcelSearchState createState() => _ExcelSearchState();
}

class _ExcelSearchState extends State<ExcelSearch> {
  String? searchResult;

  // تحميل واستخراج البيانات من ملف Excel
  Future<void> loadExcelAndSearch(String searchTerm) async {
    try {
      // تحميل الملف من الأصول
      ByteData data = await rootBundle.load('assets/dataSet/Medicines Dataset.xlsx');
      Uint8List bytes = data.buffer.asUint8List();

      // فك تشفير البيانات
      var excel = Excel.decodeBytes(bytes);

      if (excel != null) {
        List<String> results = [];
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet != null) {
            print("Reading sheet: $table");

            int? tradeNameColumnIndex;

            // العثور على عمود "Trade Name"
            if (sheet.rows.isNotEmpty) {
              var headerRow = sheet.rows[0]
                  .map((cell) => cell?.value?.toString().trim().toLowerCase())
                  .toList();
              tradeNameColumnIndex = headerRow.indexOf('trade name');
            }

            // إذا تم العثور على العمود المطلوب
            if (tradeNameColumnIndex != null && tradeNameColumnIndex >= 0) {
              for (var row in sheet.rows.skip(1)) { // تجاوز الصف الأول (عناوين الأعمدة)
                var cellValue = row[tradeNameColumnIndex]?.value?.toString().trim() ?? "";

                // البحث عن النص في العمود المحدد
                if (cellValue.toLowerCase().contains(searchTerm.toLowerCase().trim())) {
                  results.add(row.map((cell) => cell?.value?.toString() ?? "").join(", "));
                }
              }
            } else {
              print("Column 'Trade Name' not found in sheet: $table");
            }
          }
        }

        // عرض النتائج
        if (results.isNotEmpty) {
          setState(() {
            searchResult = "Results:\n${results.join("\n")}";
          });
        } else {
          setState(() {
            searchResult = "No match found for '$searchTerm'.";
          });
        }
      }
    } catch (e) {
      print("Error loading excel file: $e");
      setState(() {
        searchResult = "Error loading data.";
      });
    }
  }


  Future<void> printExcelContents() async {
    try {
      // تحميل الملف من الأصول
      ByteData data = await rootBundle.load('assets/dataSet/Medicines Dataset.xlsx');
      Uint8List bytes = data.buffer.asUint8List();

      // فك تشفير البيانات
      var excel = Excel.decodeBytes(bytes);

      if (excel != null) {
        // التأكد من وجود أوراق بيانات في الملف
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet != null) {
            print("Reading sheet: $table");

            // طباعة محتويات البيانات بشكل مفصل
            for (var row in sheet.rows) {
              // استخراج القيم الفعلية من الخلايا
              var rowData = row.map((cell) => cell?.value).toList(); // استخراج قيم الخلايا فقط
              print(rowData);  // طباعة البيانات الفعلية
            }
          }
        }
      }
    } catch (e) {
      print("Error loading excel file: $e");
    }
  }
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Search Medicine in Excel"),
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [

              CustomDropdownExample(),
              const SizedBox(height: 20,),
              DialogFb3(),
              const SizedBox(height: 20,),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Enter Medicine Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  String searchTerm = searchController.text.trim();
                  if (searchTerm.isNotEmpty) {
                    loadExcelAndSearch(searchTerm);
                  } else {
                    setState(() {
                      searchResult = "Please enter a valid medicine name.";
                    });
                  }
                },
                child: Text("Search"),
              ),
              SizedBox(height: 16),
              Text(
                searchResult ?? "Enter a medicine name to search.",
                style: TextStyle(fontSize: 16),
              ),
          
              ElevatedButton(onPressed: ()async{
             await   printExcelContents();
              }, child: Text("print data")),
          
              const SizedBox(height: 20,),
              CustomElevatedButton(onPressed: (){},text: 'hello',),//
              const SizedBox(height: 20,),
              NeonGradientCardDemo(),

              const SizedBox(height: 20,),

            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBarCurved(),
    );
  }
}


class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? textColor;
  final FontWeight? textFontWeight;
  final double? fontSize;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final MainAxisSize? mainAxisSize;

  const CustomElevatedButton(
      {super.key,
        required this.text,
        required this.onPressed,
        this.backgroundColor,
        this.textStyle,
        this.textColor,
        this.textFontWeight,
        this.fontSize,
        this.borderRadius,
        this.padding,
        this.leadingIcon,
        this.trailingIcon,
        this.mainAxisSize});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        overlayColor: Colors.black,
        backgroundColor: backgroundColor ?? Colors.amber,
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8.0),
          ],
          Text(
            text,
            style: textStyle ??
                TextStyle(
                  color: textColor ?? Colors.black,
                  fontSize: fontSize ?? 18.0,
                  fontWeight: textFontWeight ?? FontWeight.w700,
                ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8.0),
            trailingIcon!,
          ],
        ],
      ),
    );
  }
}
