import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuView extends ConsumerWidget {
  MenuView({super.key});
  
  final fetchDataProvider = FutureProvider((ref) async {
    final supabase = Supabase.instance.client;
    return await supabase
      .from('menu')
      .select().
      eq('restaurantId', ref.watch(userDocumentsProvider)['id']).single();
  });
  final menuProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
  final saveProvider = StateProvider<bool>((ref)=> false);
  final SupabaseClient supabase = Supabase.instance.client;
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(fetchDataProvider, (previous, next) {
      next.when(
        data: (value) {
          final menu = List<Map<String, dynamic>>.from(value['menu'] ?? []);
          ref.read(menuProvider.notifier).state = menu;
        },
        error: (e, _) {}, // Do nothing on error
        loading: () {}, // Do nothing while loading
      );
    });

    final menu = ref.watch(menuProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 16.sp,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).menu ,style: Theme.of(context).textTheme.headlineLarge,),
                  TextButton(
                    onPressed: (){
                      _showAddCategoryDialog(context, ref);
                    },
                    child: Text(S.of(context).add_category),
                  )
                ],
              ),
            ),
                Padding(
                  padding:  EdgeInsets.only(left: 16.sp, right: 16.sp),
                  child: menu.isEmpty? Text(S.of(context).menu_empty)
                
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
                          // child: Container(
                          //   alignment: Alignment.center,
                          //   decoration: BoxDecoration(
                          //     color: tertiaryColor.withOpacity(0.5),
                          //     borderRadius: BorderRadius.circular(16.sp),
                          //   ),
                          //   child: Text(menu[ind]["name"],),
                          // ),
                          child: Container(
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: BoxBorder.all(
                                color: secondaryColor.withOpacity(0.5),
                                width: 4.sp
                              ),
                              borderRadius: BorderRadius.circular(16.sp),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //add the rectangle shape here
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.sp,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16.sp),
                                      width: 2.w,
                                      height: 3.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [secondaryColor,  Color.fromARGB(255, 219, 98, 0)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter
                                        ),
                                        borderRadius: BorderRadius.circular(8.sp)
                                      ),
                                    ),
                                    Text(
                                      "${menu[ind]["name"]}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Iconsax.arrow_circle_right,
                                  color: tertiaryColor.withOpacity(0.8),
                                ),
                              ],
                            )
                          ),
                        );
                      },
                    ),
                ),
            Padding(
              padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).tags, style: Theme.of(context).textTheme.headlineLarge,),
                  TextButton(
                    onPressed: (){
                      showDialog(
                        context: context, 
                        builder: (context){
                          return RefDialog();
                        }
                        );
                    }, 
                    child: Text(S.of(context).edit)
                    )
                ],
              ),
            ),
            SingleChildScrollView(
            scrollDirection: Axis.horizontal,
              child: Row(
              children: List.generate(ref.watch(userDocumentsProvider)['tags'].length,(index){
                return Container(
                  alignment: Alignment.bottomCenter,
                  width: 30.w,
                  height: 30.w,
                  margin: EdgeInsets.only(left: 16.sp),
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.sp),
                  image: DecorationImage(image: AssetImage(tagImages[ref.watch(userDocumentsProvider)['tags'][index]]!))
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: BlurryContainer(
                      width: 24.w,
                      height: 10.w,
                      borderRadius: BorderRadius.circular(24.sp),
                      child: Center(
                        child: Text(
                          "${ref.watch(userDocumentsProvider)['tags'][index]}",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600, shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: Offset(2, 2),
                              blurRadius: 24,
                            ),
                          ]),
                          ))
                      ),
                  ),
                );
              }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    TextEditingController categoryController = TextEditingController();
    bool multiSizes = false;
    bool notable = false;
    List<Map<String, dynamic>> currentItems = [];

    showDialog(
      context: context,
      builder: (context1) {
        return StatefulBuilder(
          builder: (context1, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.all(16.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: IntrinsicWidth(
                stepWidth: 100.w,
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      spacing: 16.sp,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          controller: categoryController,
                          hintText: S.of(context).category_name,
                        ),
                        if(currentItems.isEmpty) Row(
                          children: [
                            Text(S.of(context).multi_sizes),
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
                        if(currentItems.isEmpty) Row(
                          children: [
                            Text(S.of(context).accept_notes),
                            Checkbox(
                              value: notable,
                              onChanged: (value) {
                                setState(() {
                                  notable = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        currentItems.isEmpty
                            ? Text(S.of(context).no_items)
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
                          child: Text(S.of(context).add_item),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (categoryController.text.isEmpty || currentItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).category_name_item_required)),
                              );
                              return;
                            }
                            final newCategory = {
                              "name": categoryController.text,
                              "multiSizes": multiSizes,
                              "items": currentItems,
                              "notable": notable
                            };
                            //await _saveToSupabase(newCategory, restaurantId);
                            ref.read(menuProvider.notifier).update((state) => [...state, newCategory]);
                            ref.read(saveProvider.notifier).state = true;
                            final supabase = Supabase.instance.client;
                                late var query;
                                try {
                                  query =  await supabase
                                    .from('menu')
                                    .update({'menu': ref.watch(menuProvider)})
                                    .eq('restaurantId', ref.watch(userDocumentsProvider)['id']);
                                  // You can return or use the insertedClient if needed
                                } on PostgrestException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("${S.of(context).failed_add_restaurant} ${e.message}"));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("${S.of(context).unexpected_error} $e"));
                                }
                                ref.read(saveProvider.notifier).state = false;
                            Navigator.pop(context1);
                          },
                          child: Text(S.of(context).save),
                        ),
                      ],
                    ),
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
    final bool notable = category["notable"];
    List<Map<String, dynamic>> currentItems = List<Map<String, dynamic>>.from(category["items"] ?? []);

    showDialog(
      context: context,
      builder: (context1) {
        return StatefulBuilder(
          builder: (context1, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(16.sp),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: IntrinsicWidth(
                stepWidth: 100.w,
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      spacing: 16.sp,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          controller: categoryController,
                          hintText: S.of(context).category_name,
                        ),
                        currentItems.isEmpty
                            ? Text(S.of(context).no_items)
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
                          child: Text(S.of(context).add_item),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (categoryController.text.isEmpty || currentItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).category_name_item_required)),
                              );
                              return;
                            }
                            final updatedCategory = {
                              "name": categoryController.text,
                              "multiSizes": multiSizes,
                              "items": currentItems,
                              "notable": notable ?? false
                            };
                            //await _updateCategoryInSupabase(category, updatedCategory, restaurantId);
                            ref.read(menuProvider.notifier).update((state) {
                              final newState = List<Map<String, dynamic>>.from(state);
                              newState[categoryIndex] = updatedCategory;
                              return newState;
                            });
                            print(ref.watch(menuProvider));
                            print("the id of restaurant: ${ref.watch(userDocumentsProvider)['id']}");
                            final supabase = Supabase.instance.client;
                                late var query;
                                try {
                                  query =  await supabase
                                    .from('menu')
                                    .update({'menu': ref.watch(menuProvider)})
                                    .eq('restaurantId', ref.watch(userDocumentsProvider)['id']);
                                  // You can return or use the insertedClient if needed
                                } on PostgrestException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("${S.of(context).failed_add_restaurant} ${e.message}"));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("${S.of(context).unexpected_error} $e"));
                                }
                                ref.read(saveProvider.notifier).state = false;
                            Navigator.pop(context1);
                          },
                          child: Text(S.of(context).save),
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
                          child: Text(S.of(context).delete_category, style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
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
          insetPadding: EdgeInsets.all(16.sp),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: IntrinsicWidth(
            stepWidth: 100.w,
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  spacing: 16.sp,
                  children: [
                    InputField(
                      controller: itemController,
                      hintText: S.of(context).item_name,
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
                            SnackBar(content: Text(S.of(context).items_must_be_filled)),
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
                      child: Text(S.of(context).add_item),
                    ),
                  ],
                ),
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
          insetPadding: EdgeInsets.all(16.sp),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: IntrinsicWidth(
            stepWidth: 100.w,
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  spacing: 16.sp,
                  children: [
                    InputField(
                      controller: itemController,
                      hintText: S.of(context).item_name,
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
                            SnackBar(content: Text(S.of(context).items_must_be_filled)),
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
                      child: Text(S.of(context).update_item),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RefDialog extends ConsumerWidget{
  RefDialog({super.key});

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.sp),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.sp,
          children: [
            Text(S.of(context).tags),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.sp,
                  crossAxisSpacing: 8.sp,
                  childAspectRatio: 1,
                ),
                itemCount: tagImages.entries.length,
                itemBuilder: (context, ind) {
                  final tagKey = tagImages.entries.elementAt(ind).key;
                  return InkWell(
                    onTap: () async{
                      if(ref.watch(userDocumentsProvider)['tags'].contains(tagKey)){
                        final currentState = ref.read(userDocumentsProvider.notifier).state;
                        final updatedTags = List<String>.from(currentState['tags'] ?? [])..remove(tagKey);
                        ref.read(userDocumentsProvider.notifier).state = {
                          ...currentState,
                          'tags': updatedTags,
                        };
                      } else {
                        final currentState = ref.read(userDocumentsProvider.notifier).state;
                        final updatedTags = List<String>.from(currentState['tags'] ?? [])..add(tagKey);
                        ref.read(userDocumentsProvider.notifier).state = {
                          ...currentState,
                          'tags': updatedTags,
                        };
                      }
                      final query = await supabase.from("restaurants").update({"tags" : ref.watch(userDocumentsProvider)['tags']})
                        .eq('id', ref.watch(userDocumentsProvider)['id']);
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: primaryColor,
                        width: ref.watch(userDocumentsProvider)['tags'].contains(tagKey)? 8.sp : 0.sp,
                      ),
                      borderRadius: BorderRadius.circular(24.sp),
                      image: DecorationImage(image: AssetImage(tagImages.entries.elementAt(ind).value), fit: BoxFit.cover)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: BlurryContainer(
                          width: 19.w,
                          height: 10.w,
                          borderRadius: BorderRadius.circular(24.sp),
                          child: Center(
                            child: Text(
                              "${tagImages.entries.elementAt(ind).key}",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600, shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: Offset(2, 2),
                                  blurRadius: 24,
                                ),
                              ]),
                              ))
                          ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}