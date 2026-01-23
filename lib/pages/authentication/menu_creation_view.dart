import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/schedule_view.dart';
import 'package:dinney_restaurant/services/models/menu_model.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:dinney_restaurant/widgets/circles_indicator.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:translator/translator.dart';

final tagsProvider = StateProvider<List<String>>((ref) => []);

class MenuCreationView extends ConsumerWidget {
  final int restaurantId;
  MenuCreationView(this.restaurantId, {super.key});

  final menuProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

  final SupabaseClient supabase = Supabase.instance.client;
  final translator = GoogleTranslator();
  final languages = ["en", "ar", "fr"];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 16.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.sp),
                child: ThreeDotsIndicator(index: 2),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: menu.isEmpty
                    ? Text(S.of(context).menu_empty)
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
                              _showEditCategoryDialog(
                                context,
                                ref,
                                ind,
                                menu[ind],
                              );
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
              ),
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: () {
                    _showAddCategoryDialog(context, ref);
                  },
                  child: Text(S.of(context).add_category),
                ),
              ),
              ref.watch(tagsProvider).isNotEmpty
                  ? Column(
                      spacing: 16.sp,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp),
                          child: Text(
                            S.of(context).tags,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              ref.watch(tagsProvider).length,
                              (index) {
                                return Container(
                                  alignment: Alignment.bottomCenter,
                                  width: 30.w,
                                  height: 30.w,
                                  margin: EdgeInsets.only(left: 16.sp),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.sp),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        tagImages[ref.watch(
                                          tagsProvider,
                                        )[index]]!,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: BlurryContainer(
                                      padding: 4.sp,
                                      borderRadius: BorderRadius.circular(
                                        24.sp,
                                      ),
                                      child: Center(
                                        child: FutureBuilder(
                                          future: translator.translate(
                                            ref.watch(tagsProvider)[index],
                                            to:
                                                languages[ref.watch(
                                                  languageStateProvider,
                                                )],
                                          ),
                                          builder: (context, translation) {
                                            if (translation.data != null &&
                                                translation.hasData) {
                                              return Text(
                                                translation.data!.text,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black
                                                              .withOpacity(0.4),
                                                          offset: Offset(2, 2),
                                                          blurRadius: 24,
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            } else {
                                              return SizedBox.shrink();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Text(S.of(context).no_tags_selected),
                    ),
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (contetx) {
                        return TagsDialog();
                      },
                    );
                  },
                  child: ref.watch(tagsProvider).isEmpty
                      ? Text(S.of(context).add_tags)
                      : Text(S.of(context).edit_tags),
                ),
              ),
              if (ref.watch(menuProvider).isNotEmpty &&
                  ref.watch(tagsProvider).isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: !ref.watch(savingLoadingButton)
                      ? ElevatedButton(
                          onPressed: () async {
                            ref.read(savingLoadingButton.notifier).state = true;
                            final table = MenuModel(
                              restaurantId: restaurantId,
                              menu: menu,
                            );
                            final supabase = Supabase.instance.client;
                            try {
                              final response = await supabase
                                  .from('menu')
                                  .insert(table.toJson())
                                  .select();
                              if (response.isNotEmpty) {
                                await supabase
                                    .from("restaurants")
                                    .update({
                                      "tags": List.from(ref.read(tagsProvider)),
                                      "menu_id": response[0]['id'],
                                    })
                                    .eq("id", restaurantId)
                                    .whenComplete(() {
                                      ref.read(signUpProvider.notifier).state =
                                          3; // update the sign up state to 3
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ScheduleView(id: restaurantId),
                                        ),
                                      );
                                    });
                              }
                              // You can return or use the insertedClient if needed
                            } on PostgrestException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                ErrorMessage(
                                  "${S.of(context).failed_add_restaurant} ${e.message}",
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                ErrorMessage(
                                  "${S.of(context).unexpected_error} $e",
                                ),
                              );
                            }
                            ref.read(savingLoadingButton.notifier).state =
                                false;
                          },
                          child: Text(S.of(context).save),
                        )
                      : LoadingSpinner(),
                ),
            ],
          ),
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
              backgroundColor: backgroundColor,
              insetPadding: EdgeInsets.all(8.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 16.sp,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputField(
                        controller: categoryController,
                        hintText: S.of(context).caregory_name,
                      ),
                      if (currentItems.isEmpty)
                        Row(
                          children: [
                            Text(S.of(context).multi_sizes),
                            Transform.scale(
                              scale: 1.5,
                              child: Checkbox(
                                value: multiSizes,
                                onChanged: (value) {
                                  setState(() {
                                    multiSizes = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      if (currentItems.isEmpty)
                        Row(
                          children: [
                            Text(S.of(context).accept_notes),
                            Transform.scale(
                              scale: 1.5,
                              child: Checkbox(
                                value: notable,
                                onChanged: (value) {
                                  setState(() {
                                    notable = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      currentItems.isEmpty
                          ? Text(S.of(context).no_items)
                          : SizedBox(
                              height: 50.h,
                              child: SingleChildScrollView(
                                child: Column(
                                  spacing: 16.sp,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(currentItems.length, (
                                    index,
                                  ) {
                                    return Container(
                                      padding: EdgeInsets.all(16.sp),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.sp,
                                        ),
                                        color: tertiaryColor.withOpacity(0.1),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            currentItems[index]["name"],
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (multiSizes)
                                                ...List.generate(
                                                  currentItems[index]["sizes"]
                                                      .length,
                                                  (i) => Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          sizes[i],
                                                        ), // e.g. "L", "XL", "XXL"
                                                        Text(
                                                          "${currentItems[index]["sizes"][i]} ${S.of(context).da}",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              else
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${currentItems[index]["sizes"][0]} ${S.of(context).da}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                      OutlinedButton(
                        onPressed: () {
                          _showAddItemDialog(
                            context,
                            setState,
                            multiSizes,
                            currentItems,
                          );
                        },
                        child: Text(S.of(context).add_item),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (categoryController.text.isEmpty ||
                              currentItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Category name and at least one item are required",
                                ),
                              ),
                            );
                            return;
                          }
                          final newCategory = {
                            "name": categoryController.text,
                            "multiSizes": multiSizes,
                            "items": currentItems,
                            "notable": notable,
                          };
                          //await _saveToSupabase(newCategory, restaurantId);
                          ref
                              .read(menuProvider.notifier)
                              .update((state) => [...state, newCategory]);
                          Navigator.pop(context1);
                        },
                        child: Text(S.of(context).save),
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

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    int categoryIndex,
    Map<String, dynamic> category,
  ) {
    TextEditingController categoryController = TextEditingController(
      text: category["name"],
    );
    final bool multiSizes = category["multiSizes"]; // Make multiSizes immutable
    List<Map<String, dynamic>> currentItems = List<Map<String, dynamic>>.from(
      category["items"] ?? [],
    );
    final bool notable = category["notable"];

    showDialog(
      context: context,
      builder: (context1) {
        return StatefulBuilder(
          builder: (context1, setState) {
            return Dialog(
              backgroundColor: backgroundColor,
              insetPadding: EdgeInsets.all(8.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 16.sp,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputField(
                        controller: categoryController,
                        hintText: S.of(context).caregory_name,
                      ),
                      currentItems.isEmpty
                          ? Text(S.of(context).no_items)
                          : SizedBox(
                              height: 50.h,
                              child: SingleChildScrollView(
                                child: Column(
                                  spacing: 16.sp,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(currentItems.length, (
                                    index,
                                  ) {
                                    return Container(
                                      padding: EdgeInsets.all(16.sp),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          24.sp,
                                        ),
                                        color: tertiaryColor.withOpacity(0.1),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            currentItems[index]["name"],
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (multiSizes)
                                                    ...List.generate(
                                                      currentItems[index]["sizes"]
                                                          .length,
                                                      (i) => Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8.0,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              sizes[i],
                                                            ), // e.g. "L", "XL", "XXL"
                                                            Text(
                                                              "${currentItems[index]["sizes"][i]} ${S.of(context).da}",
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  else
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(sizes[0]),
                                                        Text(
                                                          "${currentItems[index]["sizes"][0]} ${S.of(context).da}",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Switch(
                                                    activeColor: secondaryColor,
                                                    value:
                                                        currentItems[index]["isActive"] ??
                                                        true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currentItems[index]["isActive"] =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      size: 16.sp,
                                                    ),
                                                    onPressed: () {
                                                      _showEditItemDialog(
                                                        context,
                                                        setState,
                                                        multiSizes,
                                                        currentItems,
                                                        index,
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      size: 16.sp,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        currentItems.removeAt(
                                                          index,
                                                        );
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                      OutlinedButton(
                        onPressed: () {
                          _showAddItemDialog(
                            context,
                            setState,
                            multiSizes,
                            currentItems,
                          );
                        },
                        child: Text(S.of(context).add_item),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (categoryController.text.isEmpty ||
                              currentItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  S.of(context).category_name_item_required,
                                ),
                              ),
                            );
                            return;
                          }
                          final updatedCategory = {
                            "name": categoryController.text,
                            "multiSizes": multiSizes,
                            "items": currentItems,
                            "notable": notable,
                          };
                          //await _updateCategoryInSupabase(category, updatedCategory, restaurantId);
                          ref.read(menuProvider.notifier).update((state) {
                            final newState = List<Map<String, dynamic>>.from(
                              state,
                            );
                            newState[categoryIndex] = updatedCategory;
                            return newState;
                          });
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
                            final newState = List<Map<String, dynamic>>.from(
                              state,
                            );
                            newState.removeAt(categoryIndex);
                            return newState;
                          });
                          Navigator.pop(context1);
                        },
                        child: Text(
                          S.of(context).delete_category,
                          style: TextStyle(color: Colors.red),
                        ),
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
    BuildContext context,
    StateSetter setState,
    bool multiSizes,
    List<Map<String, dynamic>> currentItems,
  ) {
    TextEditingController itemController = TextEditingController();
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
          insetPadding: EdgeInsets.all(8.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: SizedBox(
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16.sp,
                  children: [
                    InputField(
                      controller: itemController,
                      hintText: S.of(context).item_name,
                    ),
                    Column(
                      spacing: 16.sp,
                      children: List.generate(multiSizes ? 3 : 1, (index) {
                        return InputField(
                          keyboard: true,
                          controller: sizeControllers[index],
                          hintText: multiSizes
                              ? "${S.of(context).price_of} ${sizes[index]}"
                              : S.of(context).price,
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (itemController.text.isEmpty ||
                            (multiSizes &&
                                sizeControllers.any(
                                  (controller) => controller.text.isEmpty,
                                )) ||
                            (!multiSizes && sizeControllers[0].text.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).items_must_be_filled),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          try {
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
                          } catch (e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(ErrorMessage(S.of(context).error));
                          }
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
    BuildContext context,
    StateSetter setState,
    bool multiSizes,
    List<Map<String, dynamic>> currentItems,
    int itemIndex,
  ) {
    final item = currentItems[itemIndex];
    TextEditingController itemController = TextEditingController(
      text: item["name"],
    );
    List<TextEditingController> sizeControllers = List.generate(
      multiSizes ? 3 : 1,
      (index) =>
          TextEditingController(text: item["sizes"][index]?.toString() ?? ""),
    );

    showDialog(
      context: context,
      builder: (context2) {
        return Dialog(
          backgroundColor: backgroundColor,
          insetPadding: EdgeInsets.all(8.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16.sp,
                children: [
                  InputField(
                    controller: itemController,
                    hintText: S.of(context).item_name,
                  ),
                  Column(
                    spacing: 16.sp,
                    children: List.generate(multiSizes ? 3 : 1, (index) {
                      return InputField(
                        keyboard: true,
                        controller: sizeControllers[index],
                        hintText: sizes[index],
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (itemController.text.isEmpty ||
                          (multiSizes &&
                              sizeControllers.any(
                                (controller) => controller.text.isEmpty,
                              )) ||
                          (!multiSizes && sizeControllers[0].text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).items_must_be_filled),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        try {
                          currentItems[itemIndex] = {
                            "name": itemController.text,
                            "sizes": multiSizes
                                ? [
                                    int.parse(sizeControllers[0].text),
                                    int.parse(sizeControllers[1].text),
                                    int.parse(sizeControllers[2].text),
                                  ]
                                : [int.parse(sizeControllers[0].text)],
                            "isActive":
                                currentItems[itemIndex]["isActive"] ?? true,
                          };
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(ErrorMessage(S.of(context).error));
                        }
                        Navigator.pop(context2);
                      });
                    },
                    child: Text(S.of(context).update_item),
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

class TagsDialog extends ConsumerWidget {
  TagsDialog({super.key});

  final supabase = Supabase.instance.client;
  final translator = GoogleTranslator();
  final languages = ["en", "ar", "fr"];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: EdgeInsets.all(8.sp),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h, maxWidth: 90.w),
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16.sp,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).tags,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (ref.watch(tagsProvider).isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      S.of(context).save,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: secondaryColor),
                    ),
                  ),
              ],
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16.sp,
                  crossAxisSpacing: 16.sp,
                  childAspectRatio: 1,
                ),
                itemCount: tagImages.entries.length,
                itemBuilder: (context, ind) {
                  final tagKey = tagImages.entries.elementAt(ind).key;
                  return InkWell(
                    borderRadius: BorderRadius.circular(24.sp),
                    onTap: () async {
                      if (ref.watch(tagsProvider).contains(tagKey)) {
                        final currentState = ref
                            .read(tagsProvider.notifier)
                            .state;
                        final updatedTags = List<String>.from(
                          currentState ?? [],
                        )..remove(tagKey);
                        ref.read(tagsProvider.notifier).state = updatedTags;
                      } else {
                        final currentState = ref
                            .read(tagsProvider.notifier)
                            .state;
                        final updatedTags = List<String>.from(
                          currentState ?? [],
                        )..add(tagKey);
                        ref.read(tagsProvider.notifier).state = updatedTags;
                      }
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        border: BoxBorder.all(
                          color: primaryColor,
                          width: ref.watch(tagsProvider).contains(tagKey)
                              ? 8.sp
                              : 0.sp,
                        ),
                        borderRadius: BorderRadius.circular(24.sp),
                        image: DecorationImage(
                          image: AssetImage(
                            tagImages.entries.elementAt(ind).value,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: BlurryContainer(
                          padding: 4.sp,
                          borderRadius: BorderRadius.circular(24.sp),
                          child: Center(
                            child: FutureBuilder(
                              future: translator.translate(
                                tagImages.entries.elementAt(ind).key,
                                to: languages[ref.watch(languageStateProvider)],
                              ),
                              builder: (context, translation) {
                                if (translation.data != null &&
                                    translation.hasData) {
                                  return Text(
                                    translation.data!.text,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
                                              offset: Offset(2, 2),
                                              blurRadius: 24,
                                            ),
                                          ],
                                        ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                          ),
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
