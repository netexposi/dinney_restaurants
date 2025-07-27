import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class MenuCreationView extends ConsumerWidget{
  final int restaurantId;
  MenuCreationView(this.restaurantId, {super.key});
  List<dynamic> menu = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            spacing: 16.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menu'),
              menu.isEmpty? Text("menu is empty") : Row(),
              // For Any Added Category
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: (){
                    showDialog(
                      context: context, 
                      builder: (context){
                        TextEditingController categoryController = TextEditingController();
                        bool multiSizes = false;
                        List<Map<String, List<double>>> items = [];
                        return StatefulBuilder(builder: (context, setState){
                          return Dialog( 
                            backgroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.sp)
                            ),
                            child: SizedBox(
                              width: 100.w,
                              child: Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 16.sp,
                                  children: [
                                    InputField(controller: categoryController, hintText: "Category Name"),
                                    Row(
                                      children: [
                                        Text("Multi size"),
                                        Checkbox(
                                          value: multiSizes, 
                                          onChanged: (value){
                                            setState(() {
                                              multiSizes = value!;
                                            });
                                          }
                                        ),
                                      ],
                                    ),
                                    items.isEmpty? Text("No items") 
                                    : Column(),
                                    OutlinedButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context, 
                                          builder: (context){
                                            List<String> sizes = ["X", "XL", "XXL"];
                                            TextEditingController itemController = TextEditingController();
                                            List<TextEditingController> sizeControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
                                            return Center(
                                              child: Dialog(
                                                backgroundColor: backgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(24.sp)
                                                ),
                                                child: SizedBox(
                                                  width: 100.w,
                                                  height: 50.h,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(16.sp),
                                                    child: Column(
                                                      children: [
                                                        InputField(
                                                          controller: itemController, 
                                                          hintText: "Item Name"
                                                        ),
                                                        Column(
                                                          children: List.generate(multiSizes? 3 : 1, (index){
                                                            return InputField(controller: sizeControllers[index], hintText: sizes[index]);
                                                          }),
                                                        )
                                                      ],
                                                    ),
                                                    ),
                                                ),
                                              ),
                                            );
                                          }
                                          );
                                      }, 
                                      child: Text("Add Item")
                                      ),
                                    ElevatedButton(
                                      onPressed: (){}, 
                                      child: Text("Save")
                                      )
                                  ],
                                ),
                                ),
                            ),
                          );
                        });
                      }
                    );
                  }, 
                  child: Text("Add Category")
                ),
              )
            ],
          ),
          ),
      ),
    );
  }
}