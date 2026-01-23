import 'dart:io';
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/services/functions/array_handlings.dart';
import 'package:dinney_restaurant/services/functions/geo_functions.dart';
import 'package:dinney_restaurant/services/functions/storage_functions.dart';
import 'package:dinney_restaurant/services/functions/string_handlings.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/maps_view.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:dinney_restaurant/widgets/timer_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class UserProfileView extends ConsumerWidget {
  UserProfileView({super.key});
  final displayMapsKey = GlobalKey<MapsViewState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> translatedDays = [
      S.of(context).sunday,
      S.of(context).monday,
      S.of(context).tuesday,
      S.of(context).wednesday,
      S.of(context).thursday,
      S.of(context).friday,
      S.of(context).saturday,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).profile)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.sp,
              children: [
                // SECTION INFORMATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).information,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            var changeProvider = false;
                            bool loading = false;
                            TextEditingController nameController =
                                TextEditingController(
                                  text: ref.watch(
                                    userDocumentsProvider,
                                  )["name"],
                                );

                            return StatefulBuilder(
                              builder: (context, setState) {
                                nameController.addListener(() {
                                  setState(() {
                                    changeProvider = true;
                                  });
                                });

                                return Dialog(
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(8.sp),
                                  child: IntrinsicWidth(
                                    stepWidth: 100.w,
                                    child: IntrinsicHeight(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.sp),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 16.sp,
                                          children: [
                                            Text(
                                              S.of(context).edit_information,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                            ),
                                            InputField(
                                              controller: nameController,
                                              hintText: S.of(context).name,
                                            ),

                                            if (changeProvider)
                                              Align(
                                                alignment: Alignment.center,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    if (nameController.text !=
                                                        ref.watch(
                                                          userDocumentsProvider,
                                                        )["name"]) {
                                                      try {
                                                        await supabase
                                                            .from("restaurants")
                                                            .update({
                                                              "name":
                                                                  nameController
                                                                      .text,
                                                            })
                                                            .eq(
                                                              "id",
                                                              ref.watch(
                                                                userDocumentsProvider,
                                                              )["id"],
                                                            )
                                                            .whenComplete(() async {
                                                              final newUserData =
                                                                  await supabase
                                                                      .from(
                                                                        "restaurants",
                                                                      )
                                                                      .select()
                                                                      .eq(
                                                                        "id",
                                                                        ref.watch(
                                                                          userDocumentsProvider,
                                                                        )["id"],
                                                                      )
                                                                      .single();
                                                              if (newUserData
                                                                  .isNotEmpty) {
                                                                ref
                                                                        .read(
                                                                          userDocumentsProvider
                                                                              .notifier,
                                                                        )
                                                                        .state =
                                                                    newUserData;
                                                              }
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SuccessMessage(
                                                                  S
                                                                      .of(
                                                                        context,
                                                                      )
                                                                      .name_changed_successfully,
                                                                ),
                                                              );
                                                            });
                                                      } catch (e) {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          ErrorMessage(
                                                            "${S.of(context).unexpected_error} {$e}",
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text(
                                                    S.of(context).save,
                                                  ),
                                                ),
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
                      },
                      child: Text(S.of(context).edit),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16.sp),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.sp,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${ref.watch(userDocumentsProvider)["name"]}",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(color: secondaryColor),
                              children: [
                                TextSpan(
                                  text:
                                      "${calculateAverageRating(ref.watch(userDocumentsProvider)["rating"]).toStringAsFixed(2)} • ${ref.watch(userDocumentsProvider)["rating"].length}",
                                ),
                                TextSpan(
                                  text:
                                      ref
                                              .watch(
                                                userDocumentsProvider,
                                              )["rating"]
                                              .length ==
                                          1
                                      ? " rating"
                                      : " ratings",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${ref.watch(userDocumentsProvider)["email"]}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // SCHEDULE SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).schedule,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        //v//ar schedule = ref.watch(userDocumentsProvider)["schedule"];
                        showDialog(
                          context: context,
                          builder: (context) {
                            List<String> days = [
                              "Sunday",
                              "Monday",
                              "Tuesday",
                              "Wednesday",
                              "Thursday",
                              "Friday",
                              "Saturday",
                            ];

                            List<Map<String, dynamic>> schedule = List.from(
                              ref.read(userDocumentsProvider)["schedule"] ?? [],
                            );
                            bool changeProvider = false;
                            Map<String, dynamic>? getScheduleForDay(
                              String dayName,
                            ) {
                              try {
                                return schedule.firstWhere(
                                  (item) => item["day"] == dayName,
                                );
                              } catch (e) {
                                return null;
                              }
                            }

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(8.sp),
                                  child: IntrinsicWidth(
                                    stepWidth: 100.w,
                                    child: IntrinsicHeight(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.sp),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 16.sp,
                                          children: [
                                            Text(
                                              S.of(context).edit_schedule,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(days.length, (
                                                index,
                                              ) {
                                                var entry = getScheduleForDay(
                                                  days[index],
                                                );
                                                bool exists = entry!
                                                    .containsKey("opening");
                                                return Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 30.w,
                                                              child: Text(
                                                                translatedDays[index],
                                                                style: exists
                                                                    ? Theme.of(
                                                                        context,
                                                                      ).textTheme.bodyLarge
                                                                    : Theme.of(
                                                                        context,
                                                                      ).textTheme.bodyLarge!.copyWith(
                                                                        decoration:
                                                                            TextDecoration.lineThrough,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                              ),
                                                            ),
                                                            Switch(
                                                              value: exists,
                                                              activeColor:
                                                                  Colors.green,
                                                              inactiveThumbColor:
                                                                  Colors.red,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  if (!value) {
                                                                    schedule[index] = {
                                                                      "day":
                                                                          days[index],
                                                                    };
                                                                  } else {
                                                                    //TODO add day
                                                                    schedule[index] = {
                                                                      "day":
                                                                          days[index],
                                                                      "opening":
                                                                          "09:00",
                                                                      "closing":
                                                                          "23:00",
                                                                    };
                                                                  }
                                                                  changeProvider =
                                                                      true;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        if (exists)
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical:
                                                                      8.sp,
                                                                  horizontal:
                                                                      16.sp,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: tertiaryColor
                                                                  .withOpacity(
                                                                    0.7,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12.sp,
                                                                  ),
                                                            ),
                                                            child: IntrinsicHeight(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                spacing: 16.sp,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      var selectedTime =
                                                                          stringToTimeOfDay(
                                                                            entry["opening"],
                                                                          );
                                                                      final TimeOfDay?
                                                                      picked = await pickTimeAppleDialog(
                                                                        context,
                                                                        selectedTime,
                                                                      );
                                                                      setState(() {
                                                                        if (picked !=
                                                                            null) {
                                                                          String
                                                                          formatted =
                                                                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                                                          schedule[index]["opening"] =
                                                                              formatted;
                                                                          changeProvider =
                                                                              true;
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      entry["opening"],
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .bodyLarge!
                                                                          .copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  VerticalDivider(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.5,
                                                                        ),
                                                                    width: 1,
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      var selectedTime =
                                                                          stringToTimeOfDay(
                                                                            entry["closing"],
                                                                          );
                                                                      final TimeOfDay?
                                                                      picked = await pickTimeAppleDialog(
                                                                        context,
                                                                        selectedTime,
                                                                      );
                                                                      setState(() {
                                                                        if (picked !=
                                                                            null) {
                                                                          String
                                                                          formatted =
                                                                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                                                          schedule[index]["closing"] =
                                                                              formatted;
                                                                          changeProvider =
                                                                              true;
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      entry["closing"],
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .bodyLarge!
                                                                          .copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    if (index !=
                                                        days.length - 1)
                                                      Divider(
                                                        color: tertiaryColor
                                                            .withOpacity(0.3),
                                                      ),
                                                  ],
                                                );
                                              }),
                                            ),
                                            if (changeProvider)
                                              Align(
                                                alignment: Alignment.center,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    await supabase
                                                        .from("restaurants")
                                                        .update({
                                                          "schedule": schedule,
                                                        })
                                                        .eq(
                                                          "id",
                                                          ref.watch(
                                                            userDocumentsProvider,
                                                          )['id'],
                                                        )
                                                        .whenComplete(() {
                                                          ref
                                                              .read(
                                                                userDocumentsProvider
                                                                    .notifier,
                                                              )
                                                              .state = {
                                                            ...ref.read(
                                                              userDocumentsProvider,
                                                            ),
                                                            "schedule":
                                                                List<
                                                                  Map<
                                                                    String,
                                                                    dynamic
                                                                  >
                                                                >.from(
                                                                  schedule,
                                                                ),
                                                          };
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        });
                                                  },
                                                  child: Text(
                                                    S.of(context).save,
                                                  ),
                                                ),
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
                      },
                      child: Text(S.of(context).edit),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16.sp),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      ref.watch(userDocumentsProvider)["schedule"].length,
                      (index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(translatedDays[index]),
                                ref
                                        .watch(
                                          userDocumentsProvider,
                                        )["schedule"][index]
                                        .containsKey("opening")
                                    ? RichText(
                                        text: TextSpan(
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${ref.watch(userDocumentsProvider)["schedule"][index]["opening"]}",
                                            ),
                                            TextSpan(text: " • "),
                                            TextSpan(
                                              text:
                                                  "${ref.watch(userDocumentsProvider)["schedule"][index]["closing"]}",
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        S.of(context).day_off,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(color: Colors.red),
                                      ),
                              ],
                            ),
                            if (index !=
                                ref
                                        .watch(
                                          userDocumentsProvider,
                                        )["schedule"]
                                        .length -
                                    1)
                              Divider(color: tertiaryColor.withOpacity(0.3)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // LOCATION SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).location,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                final mapKey = GlobalKey<MapsViewState>();
                                return Dialog(
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(8.sp),
                                  child: IntrinsicWidth(
                                    stepWidth: 100.w,
                                    child: IntrinsicHeight(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.sp),
                                        child: Column(
                                          spacing: 16.sp,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              S.of(context).edit_location,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                            ),
                                            SizedBox(
                                              width: 100.w,
                                              height: 50.h,
                                              child: MapsView(
                                                key: mapKey,
                                                location: LatLng(
                                                  ref.watch(
                                                    userDocumentsProvider,
                                                  )["lat"],
                                                  ref.watch(
                                                    userDocumentsProvider,
                                                  )["lng"],
                                                ),
                                                borderRadius: 24.sp,
                                                myLocationButton: true,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    // Get fresh marker position on each save attempt
                                                    LatLng? markerPosition =
                                                        mapKey
                                                            .currentState
                                                            ?.currentMarker
                                                            ?.position;

                                                    print(
                                                      "Saved location - Marker position is: $markerPosition",
                                                    );

                                                    if (markerPosition !=
                                                        null) {
                                                      // Clear any previous snackbars
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).clearSnackBars();

                                                      print(
                                                        "Getting wilaya name for lat: ${markerPosition.latitude}, lng: ${markerPosition.longitude}",
                                                      );
                                                      String? wilayaName =
                                                          await getWilayaNameFromLatLng(
                                                            markerPosition,
                                                          );
                                                      print(
                                                        "Wilaya name: $wilayaName",
                                                      );

                                                      if (wilayaName != null &&
                                                          wilayaName
                                                              .isNotEmpty) {
                                                        print(
                                                          "Getting matricule for wilaya: $wilayaName",
                                                        );
                                                        int? matricule =
                                                            await getWilayaMatricule(
                                                              wilayaName,
                                                            );
                                                        print(
                                                          "Matricule: $matricule",
                                                        );

                                                        if (matricule != null) {
                                                          await supabase
                                                              .from(
                                                                "restaurants",
                                                              )
                                                              .update({
                                                                "lat":
                                                                    markerPosition
                                                                        .latitude,
                                                                "lng": markerPosition
                                                                    .longitude,
                                                                "wilaya":
                                                                    matricule,
                                                              })
                                                              .eq(
                                                                "id",
                                                                ref.watch(
                                                                  userDocumentsProvider,
                                                                )["id"],
                                                              )
                                                              .whenComplete(() {
                                                                print(
                                                                  "Database updated successfully",
                                                                );
                                                                ref
                                                                    .read(
                                                                      userDocumentsProvider
                                                                          .notifier,
                                                                    )
                                                                    .state = {
                                                                  ...ref.read(
                                                                    userDocumentsProvider,
                                                                  ),
                                                                  "lat": markerPosition
                                                                      .latitude,
                                                                  "lng": markerPosition
                                                                      .longitude,
                                                                  "wilaya":
                                                                      matricule,
                                                                };
                                                                displayMapsKey
                                                                    .currentState!
                                                                    .setMarker(
                                                                      markerPosition,
                                                                    );
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              });
                                                        } else {
                                                          print(
                                                            "Error: Matricule is null",
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).clearSnackBars();
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            ErrorMessage(
                                                              S
                                                                  .of(context)
                                                                  .invalid_location,
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                      } else {
                                                        print(
                                                          "Error: Wilaya name is null or empty",
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).clearSnackBars();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          ErrorMessage(
                                                            S
                                                                .of(context)
                                                                .invalid_location,
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                    } else {
                                                      print(
                                                        "Error: Marker position is null",
                                                      );
                                                    }
                                                  } catch (e, stackTrace) {
                                                    print(
                                                      "Exception caught: $e",
                                                    );
                                                    print(
                                                      "Stack trace: $stackTrace",
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).clearSnackBars();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      ErrorMessage(
                                                        S
                                                            .of(context)
                                                            .invalid_location,
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(S.of(context).save),
                                              ),
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
                      },
                      child: Text(S.of(context).edit),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.sp),
                  width: 100.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.sp),
                    boxShadow: [dropShadow],
                  ),
                  child: MapsView(
                    key: displayMapsKey,
                    location: LatLng(
                      ref.watch(userDocumentsProvider)["lat"],
                      ref.watch(userDocumentsProvider)["lng"],
                    ),
                    borderRadius: 24.sp,
                  ),
                ),
                // GALLERY SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).gallery,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        bool loading = false;
                        List<bool> removeButtonProvider = [false, false, false];
                        showDialog(
                          context: context,
                          builder: (context) {
                            bool changeProvider = false;
                            final indexes = [];
                            List<dynamic> urls = ref.watch(
                              userDocumentsProvider,
                            )["urls"];
                            while (urls.length < 4) {
                              urls.add(null);
                            }
                            return StatefulBuilder(
                              builder: (context, setState) {
                                urls = ref.watch(userDocumentsProvider)["urls"];
                                Future<void> _pickImage({
                                  required WidgetRef ref,
                                  required int index,
                                }) async {
                                  changeProvider = true;
                                  final picker = ImagePicker();
                                  final XFile? picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (picked != null) {
                                    indexes.add(index);
                                    // ref.read(imagesProvider.notifier).state[index] = File(picked.path);
                                    // images = ref.watch(imagesProvider);
                                    urls[index] = File(picked.path);
                                  }
                                  if (index != 0) {
                                    removeButtonProvider[index - 1] = false;
                                  }
                                  setState(() {});
                                }

                                return Dialog(
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(8.sp),
                                  child: IntrinsicWidth(
                                    stepWidth: 100.w,
                                    child: IntrinsicHeight(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.sp),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 16.sp,
                                          children: [
                                            Text(
                                              S.of(context).edit_gallery,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall,
                                            ),
                                            Text(
                                              S.of(context).edit_primary_image,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                            InkWell(
                                              onTap: () => _pickImage(
                                                ref: ref,
                                                index: 0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24.sp),
                                              child: Container(
                                                width: 100.w,
                                                height: 45.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        24.sp,
                                                      ),
                                                  color: Colors.grey[300],
                                                  image: urls[0] is File
                                                      ? DecorationImage(
                                                          image: FileImage(
                                                            urls[0]!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : DecorationImage(
                                                          image: NetworkImage(
                                                            ref.watch(
                                                              userDocumentsProvider,
                                                            )["urls"][0],
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                                // child: images[0] == null && ref.watch(userDocumentsProvider)["urls"][0] == null
                                                //     ? Column(
                                                //         mainAxisAlignment: MainAxisAlignment.center,
                                                //         children: [
                                                //           HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, color: tertiaryColor),
                                                //           Text("Edit Image", style: Theme.of(context).textTheme.bodySmall,)
                                                //         ],
                                                //       )
                                                //     : null,
                                              ),
                                            ),
                                            Text(
                                              S.of(context).edit_album_image,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(3, (i) {
                                                final index = i + 1; // 1, 2, 3
                                                return InkWell(
                                                  onTap: () => _pickImage(
                                                    ref: ref,
                                                    index: index,
                                                  ),
                                                  onLongPress: () {
                                                    if (urls[index] != null) {
                                                      setState(() {
                                                        removeButtonProvider[index -
                                                                1] =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        24.sp,
                                                      ),
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.topRight,
                                                    children: [
                                                      Container(
                                                        width: 28.w,
                                                        height: 28.w,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24.sp,
                                                              ),
                                                          color:
                                                              Colors.grey[300],
                                                          image:
                                                              urls[index] !=
                                                                  null
                                                              ? (urls[index]!
                                                                        is File
                                                                    ? DecorationImage(
                                                                        image: FileImage(
                                                                          urls[index],
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : DecorationImage(
                                                                        image: NetworkImage(
                                                                          urls[index],
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ))
                                                              : null,
                                                        ),
                                                        child:
                                                            urls[index] == null
                                                            ? Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  HugeIcon(
                                                                    icon: HugeIcons
                                                                        .strokeRoundedAddCircle,
                                                                    color:
                                                                        tertiaryColor,
                                                                  ),
                                                                  Text(
                                                                    S
                                                                        .of(
                                                                          context,
                                                                        )
                                                                        .edit,
                                                                    style: Theme.of(
                                                                      context,
                                                                    ).textTheme.bodySmall,
                                                                  ),
                                                                ],
                                                              )
                                                            : null,
                                                      ),
                                                      if (removeButtonProvider[index -
                                                          1])
                                                        AnimatedContainer(
                                                          width: 8.w,
                                                          height: 8.w,
                                                          duration: Duration(
                                                            milliseconds: 200,
                                                          ),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: IconButton(
                                                              onPressed: () async {
                                                                if (removeButtonProvider[index -
                                                                    1]) {
                                                                  await removeImageFromSupabase(
                                                                    urls[index],
                                                                  );
                                                                  setState(() {
                                                                    changeProvider =
                                                                        true;
                                                                    removeButtonProvider[index -
                                                                            1] =
                                                                        false;
                                                                    indexes.removeWhere(
                                                                      (ind) =>
                                                                          ind ==
                                                                          index,
                                                                    );
                                                                    urls[index] =
                                                                        null;
                                                                  });
                                                                }
                                                              },
                                                              icon: HugeIcon(
                                                                icon: HugeIcons
                                                                    .strokeRoundedRemove02,
                                                                color:
                                                                    Colors.red,
                                                                size: 16.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                            if (changeProvider)
                                              Align(
                                                alignment: Alignment.center,
                                                child: !loading
                                                    ? ElevatedButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            loading = true;
                                                          });
                                                          for (var index
                                                              in indexes) {
                                                            var url =
                                                                await uploadImageToSupabase(
                                                                  urls[index]!,
                                                                );
                                                            urls[index] = url!;
                                                            //TODO remove changed or removed images from databases
                                                          }
                                                          try {
                                                            await supabase
                                                                .from(
                                                                  'restaurants',
                                                                )
                                                                .update({
                                                                  'urls': urls,
                                                                })
                                                                .eq(
                                                                  'id',
                                                                  ref.watch(
                                                                    userDocumentsProvider,
                                                                  )["id"],
                                                                )
                                                                .whenComplete(() {
                                                                  ref
                                                                      .read(
                                                                        userDocumentsProvider
                                                                            .notifier,
                                                                      )
                                                                      .state = {
                                                                    ...ref.watch(
                                                                      userDocumentsProvider,
                                                                    ),
                                                                    "urls":
                                                                        urls,
                                                                  };
                                                                  setState(() {
                                                                    loading =
                                                                        false;
                                                                  });
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                });
                                                          } catch (e) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              ErrorMessage(
                                                                S
                                                                    .of(context)
                                                                    .internal_error,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          S.of(context).save,
                                                        ),
                                                      )
                                                    : LoadingSpinner(),
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
                      },
                      child: Text(S.of(context).edit),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.sp),
                  //height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.sp),
                    boxShadow: [dropShadow],
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      spacing: 8.sp,
                      children: [
                        Container(
                          width: 100.w,
                          height: 33.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.sp),
                            boxShadow: [dropShadow],
                            image: DecorationImage(
                              image: NetworkImage(
                                ref.watch(userDocumentsProvider)['urls'][0],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Row(
                          spacing: 8.sp,
                          children: List.generate(
                            ref.watch(userDocumentsProvider)['urls'].length - 1,
                            (index) {
                              return ref.watch(
                                        userDocumentsProvider,
                                      )['urls'][index + 1] !=
                                      null
                                  ? Container(
                                      width: 16.h - 8.sp * 5.5,
                                      height: 16.h - 8.sp * 5.5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          24.sp,
                                        ),
                                        boxShadow: [dropShadow],
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            ref.watch(
                                              userDocumentsProvider,
                                            )['urls'][index + 1],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.sp),
                    boxShadow: [dropShadow],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).delete_account,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          bool loading = false;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.all(16.sp),
                                    actionsAlignment: MainAxisAlignment.center,
                                    content: Text(
                                      S.of(context).delete_account_warning,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    actions: [
                                      !loading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    //FIXME you need to revise this code
                                                    setState(() {
                                                      loading = true;
                                                    });
                                                    try {
                                                      await supabase
                                                          .from("restaurants")
                                                          .delete()
                                                          .eq(
                                                            "id",
                                                            ref.watch(
                                                              userDocumentsProvider,
                                                            )["id"],
                                                          )
                                                          .whenComplete(() async {
                                                            // supabase.auth.admin
                                                            //     .deleteUser(
                                                            //       ref.watch(
                                                            //         userDocumentsProvider,
                                                            //       )["uid"],
                                                            //     );
                                                            AppNavigation
                                                                .navRouter
                                                                .go("/");
                                                            ScaffoldMessenger.maybeOf(
                                                              context,
                                                            )?.showSnackBar(
                                                              SuccessMessage(
                                                                S
                                                                    .of(context)
                                                                    .account_deleted_successfully,
                                                              ),
                                                            );
                                                          });
                                                    } catch (e) {
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                      ScaffoldMessenger.maybeOf(
                                                        context,
                                                      )?.showSnackBar(
                                                        ErrorMessage(
                                                          "${S.of(context).unexpected_error} {$e}",
                                                        ),
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    }
                                                  },
                                                  child: Text(
                                                    S.of(context).yes_i_want,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    S.of(context).cancel,
                                                    style: TextStyle(
                                                      color: tertiaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : LoadingSpinner(),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Text(
                          S.of(context).delete,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
