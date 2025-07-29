import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
final SupabaseClient supabase = Supabase.instance.client;
final fetchDataProvider = FutureProvider((ref) async {
  // Your async fetch logic
  return await supabase
    .from('menu')
    .select().
    eq('restaurantId', ref.watch(userDocumentsProvider)['id']).single();
});

class MenuView extends ConsumerWidget {
  MenuView({super.key});

  final menuProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(fetchDataProvider);
    
    return data.when(
      error: (e, _) => Text('Error: $e'),
      loading: () => const CircularProgressIndicator(),
      data:(value) {
        final menu = value['menu'];
        //ref.read(menuProvider.notifier).state = List<Map<String, dynamic>>.from(menu ?? []);
        final bo = false;
        print(menu);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            spacing: 16.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              menu.isEmpty
                  ? Text("Menu is empty")
                  : GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.sp,
                        crossAxisSpacing: 8.sp,
                        childAspectRatio: 4,
                      ),
                      itemCount: menu.length,
                      itemBuilder: (context, ind) {
                        return InkWell(
                          onTap: () {
                            _showEditCategoryDialog(context, ref, ind, menu[ind]);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16.sp),
                            ),
                            child: Text(menu[ind]["name"]),
                          ),
                        );
                      },
                    ),
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: () {
                    _showAddCategoryDialog(context, ref);
                  },
                  child: Text("Add Category"),
                ),
              ),
              if(ref.watch(menuProvider).isNotEmpty) Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async{
                    // print(ref.watch(menuProvider)); 
                    // final table = MenuModel(
                    //   restaurantId: restaurantId, 
                    //   menu: menu);
                    // final supabase = Supabase.instance.client;
                    //     late var query;
                    //     try {
                    //       query =  await supabase
                    //         .from('menu')
                    //         .insert(table.toJson())
                    //         .select()
                    //         .single();
                    //       print(query['id']);
                    //       // You can return or use the insertedClient if needed
                    //     } on PostgrestException catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Failed to add restaurant: ${e.message}"));
                    //     } catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An unexpected error occurred: $e"));
                    //     }
                    //     ref.read(signUpProvider.notifier).state = 0; // update the sign up state to 3
                    //     AppNavigation.navRouter.go("/home");
                  }, 
                  child: Text("Save Menu")
                  ),
              )
            ],
          ),
        ),
      ),
    );
      }
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    TextEditingController categoryController = TextEditingController();
    bool multiSizes = false;
    List<Map<String, dynamic>> currentItems = [];

    showDialog(
      context: context,
      builder: (context1) {
        return StatefulBuilder(
          builder: (context1, setState) {
            return Dialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: SizedBox(
                width: 100.w,
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    spacing: 16.sp,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        controller: categoryController,
                        hintText: "Category Name",
                      ),
                      if(currentItems.isEmpty) Row(
                        children: [
                          Text("Multi size"),
                          Checkbox(
                            value: multiSizes,
                            onChanged: (value) {
                              setState(() {
                                multiSizes = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      currentItems.isEmpty
                          ? Text("No items")
                          : Column(
                              spacing: 16.sp,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(currentItems.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(currentItems[index]["name"]),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (multiSizes)
                                          Text("X    XL    XXL"),
                                          Text(multiSizes
                                              ? "${currentItems[index]["sizes"][0]} ${currentItems[index]["sizes"][1]} ${currentItems[index]["sizes"][2]}"
                                              : "${currentItems[index]["sizes"][0]}"),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                      OutlinedButton(
                        onPressed: () {
                          _showAddItemDialog(context, setState, multiSizes, currentItems);
                        },
                        child: Text("Add Item"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (categoryController.text.isEmpty || currentItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Category name and at least one item are required")),
                            );
                            return;
                          }
                          final newCategory = {
                            "name": categoryController.text,
                            "multiSizes": multiSizes,
                            "items": currentItems,
                          };
                          //await _saveToSupabase(newCategory, restaurantId);
                          ref.read(menuProvider.notifier).update((state) => [...state, newCategory]);
                          Navigator.pop(context1);
                        },
                        child: Text("Save"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, int categoryIndex, Map<String, dynamic> category) {
    TextEditingController categoryController = TextEditingController(text: category["name"]);
    final bool multiSizes = category["multiSizes"]; // Make multiSizes immutable
    List<Map<String, dynamic>> currentItems = List<Map<String, dynamic>>.from(category["items"] ?? []);

    showDialog(
      context: context,
      builder: (context1) {
        return StatefulBuilder(
          builder: (context1, setState) {
            return Dialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: SizedBox(
                width: 100.w,
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    spacing: 16.sp,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        controller: categoryController,
                        hintText: "Category Name",
                      ),
                      currentItems.isEmpty
                          ? Text("No items")
                          : Column(
                              spacing: 16.sp,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(currentItems.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(currentItems[index]["name"]),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (multiSizes)
                                          Text("X    XL    XXL"),
                                          Text(multiSizes
                                              ? "${currentItems[index]["sizes"][0]} ${currentItems[index]["sizes"][1]} ${currentItems[index]["sizes"][2]}"
                                              : "${currentItems[index]["sizes"][0]}"),
                                        ],
                                      ),
                                      Switch(
                                        value: currentItems[index]["isActive"] ?? true,
                                        onChanged: (value) {
                                          setState(() {
                                            currentItems[index]["isActive"] = value;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 16.sp),
                                        onPressed: () {
                                          _showEditItemDialog(context, setState, multiSizes, currentItems, index);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 16.sp),
                                        onPressed: () {
                                          setState(() {
                                            currentItems.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                      OutlinedButton(
                        onPressed: () {
                          _showAddItemDialog(context, setState, multiSizes, currentItems);
                        },
                        child: Text("Add Item"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (categoryController.text.isEmpty || currentItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Category name and at least one item are required")),
                            );
                            return;
                          }
                          final updatedCategory = {
                            "name": categoryController.text,
                            "multiSizes": multiSizes,
                            "items": currentItems,
                          };
                          //await _updateCategoryInSupabase(category, updatedCategory, restaurantId);
                          ref.read(menuProvider.notifier).update((state) {
                            final newState = List<Map<String, dynamic>>.from(state);
                            newState[categoryIndex] = updatedCategory;
                            return newState;
                          });
                          Navigator.pop(context1);
                        },
                        child: Text("Save"),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                        ),
                        onPressed: () async {
                          //await _deleteCategoryFromSupabase(category, restaurantId);
                          ref.read(menuProvider.notifier).update((state) {
                            final newState = List<Map<String, dynamic>>.from(state);
                            newState.removeAt(categoryIndex);
                            return newState;
                          });
                          Navigator.pop(context1);
                        },
                        child: Text("Delete Category", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog(
      BuildContext context, StateSetter setState, bool multiSizes, List<Map<String, dynamic>> currentItems) {
    TextEditingController itemController = TextEditingController();
    List<String> sizes = ["X", "XL", "XXL"];
    List<TextEditingController> sizeControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (context2) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: SizedBox(
            width: 100.w,
            height: 50.h,
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                spacing: 16.sp,
                children: [
                  InputField(
                    controller: itemController,
                    hintText: "Item Name",
                  ),
                  Column(
                    children: List.generate(multiSizes ? 3 : 1, (index) {
                      return InputField(
                        controller: sizeControllers[index],
                        hintText: sizes[index],
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (itemController.text.isEmpty ||
                          (multiSizes && sizeControllers.any((controller) => controller.text.isEmpty)) ||
                          (!multiSizes && sizeControllers[0].text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("All fields must be filled")),
                        );
                        return;
                      }
                      setState(() {
                        currentItems.add({
                          "name": itemController.text,
                          "sizes": multiSizes
                              ? [
                                  int.parse(sizeControllers[0].text),
                                  int.parse(sizeControllers[1].text),
                                  int.parse(sizeControllers[2].text),
                                ]
                              : [int.parse(sizeControllers[0].text)],
                          "isActive": true,
                        });
                        print(currentItems);
                        Navigator.pop(context2);
                      });
                    },
                    child: Text("Add Item"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditItemDialog(
      BuildContext context, StateSetter setState, bool multiSizes, List<Map<String, dynamic>> currentItems, int itemIndex) {
    final item = currentItems[itemIndex];
    TextEditingController itemController = TextEditingController(text: item["name"]);
    List<String> sizes = ["X", "XL", "XXL"];
    List<TextEditingController> sizeControllers = List.generate(
      multiSizes ? 3 : 1,
      (index) => TextEditingController(text: item["sizes"][index]?.toString() ?? ""),
    );

    showDialog(
      context: context,
      builder: (context2) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: SizedBox(
            width: 100.w,
            height: 50.h,
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                spacing: 16.sp,
                children: [
                  InputField(
                    controller: itemController,
                    hintText: "Item Name",
                  ),
                  Column(
                    children: List.generate(multiSizes ? 3 : 1, (index) {
                      return InputField(
                        controller: sizeControllers[index],
                        hintText: sizes[index],
                      );
                    },
                    )
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (itemController.text.isEmpty ||
                          (multiSizes && sizeControllers.any((controller) => controller.text.isEmpty)) ||
                          (!multiSizes && sizeControllers[0].text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("All fields must be filled")),
                        );
                        return;
                      }
                      setState(() {
                        currentItems[itemIndex] = {
                          "name": itemController.text,
                          "sizes": multiSizes
                              ? [
                                  int.parse(sizeControllers[0].text),
                                  int.parse(sizeControllers[1].text),
                                  int.parse(sizeControllers[2].text),
                                ]
                              : [int.parse(sizeControllers[0].text)],
                          "isActive": currentItems[itemIndex]["isActive"] ?? true,
                        };
                        Navigator.pop(context2);
                      });
                    },
                    child: Text("Update Item"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}