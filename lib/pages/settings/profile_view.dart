import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/services/functions/array_handlings.dart';
import 'package:dinney_restaurant/services/functions/string_handlings.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/maps_view.dart';
import 'package:dinney_restaurant/widgets/timer_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class UserProfileView extends ConsumerWidget {

  UserProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
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
                      "Information",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            var changeProvider = false;
                            TextEditingController nameController =
                                TextEditingController(
                                    text: ref
                                        .watch(userDocumentsProvider)["name"]);
                            TextEditingController emailController =
                                TextEditingController(
                                    text: ref
                                        .watch(userDocumentsProvider)["email"]);

                            return StatefulBuilder(
                              builder: (context, setState) {
                                nameController.addListener(() {
                                  setState(() {
                                    changeProvider = true;
                                  });
                                });
                                emailController.addListener(() {
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
                                              "Edit Information",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            InputField(
                                                controller: nameController,
                                                hintText: "Name"),
                                            InputField(
                                                controller: emailController,
                                                hintText: "Email"),
                                            if (changeProvider)
                                              Align(
                                                alignment: Alignment.center,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (nameController.text !=
                                                        ref.watch(userDocumentsProvider)["name"]) {
                                                      // TODO change name in database
                                                    }
                                                    if (emailController.text !=
                                                        ref.watch(userDocumentsProvider)["email"]) {
                                                      // TODO change email in both auth and database
                                                    }
                                                  },
                                                  child: Text("Save"),
                                                ),
                                              )
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
                      child: Text("Edit"),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16.sp),
                  width: 100.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.sp)),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: secondaryColor),
                              children: [
                                TextSpan(
                                  text:
                                      "${calculateAverageRating(ref.watch(userDocumentsProvider)["rating"])} • ${ref.watch(userDocumentsProvider)["rating"].length}",
                                ),
                                TextSpan(
                                  text: ref.watch(userDocumentsProvider)["rating"].length == 1
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
                      )
                    ],
                  ),
                ),
                // SCHEDULE SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Schedule",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            Map<String, dynamic> testMap = {
                              "day": "Thursday",
                            };
                            print(testMap.containsKey("opening"));
                            List<String> days = [
                              "Sunday",
                              "Monday",
                              "Tuesday",
                              "Wednesday",
                              "Thursday",
                              "Friday",
                              "Saturday"
                            ];
                            var schedule = ref.watch(userDocumentsProvider)["schedule"];
                            bool changeProvider = false;
                            Map<String, dynamic>? getScheduleForDay(String dayName) {
                              try {
                                return schedule.firstWhere((item) => item["day"] == dayName,);
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 16.sp,
                                          children: [
                                            Text("Edit Schedule",style: Theme.of(context).textTheme.headlineSmall,),
                                            Column(crossAxisAlignment:CrossAxisAlignment.start,
                                              children: List.generate(days.length, (index) {
                                                var entry = getScheduleForDay(days[index]);
                                                bool exists = entry!.containsKey("opening");
                                                return Column(
                                                  children: [
                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 30.w,
                                                              child: Text(days[index], style: exists? 
                                                                Theme.of(context).textTheme.bodyLarge
                                                                    : Theme.of( context).textTheme.bodyLarge!.copyWith(
                                                                          decoration: TextDecoration.lineThrough,
                                                                          color: Colors.grey,
                                                                        ),
                                                              ),
                                                            ),
                                                            Switch(
                                                              value: exists, 
                                                              activeColor: Colors.green,
                                                              inactiveThumbColor: Colors.red,
                                                              onChanged: (value){
                                                                setState((){
                                                                  if (!value){
                                                                    schedule[index] = {
                                                                      "day" : days[index],
                                                                    };
                                                                  }else {
                                                                    //TODO add day
                                                                    schedule[index] = {
                                                                      "day" : days[index],
                                                                      "opening" : "09:00",
                                                                      "closing" : "23:00"
                                                                    };
                                                                  }
                                                                  changeProvider = true;
                                                                });
                                                              }
                                                            ),
                                                          ],
                                                        ),
                                                        if (exists)
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                                                            decoration: BoxDecoration(
                                                              color: tertiaryColor.withOpacity(0.7),
                                                              borderRadius: BorderRadius.circular(12.sp)
                                                            ),
                                                            child: IntrinsicHeight(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                spacing: 16.sp,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () async{
                                                                      var selectedTime  = stringToTimeOfDay(entry["opening"]);
                                                                      final TimeOfDay? picked = await pickTimeAppleDialog(context, selectedTime);
                                                                      setState((){
                                                                        if(picked != null){
                                                                          schedule[index]["opening"] = "${picked.hour}:${picked.minute}";
                                                                          changeProvider = true;
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Text(entry["opening"], style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),)),
                                                                  VerticalDivider(color: Colors.white.withOpacity(0.5), width: 1, ),
                                                                  InkWell(
                                                                    onTap: () async{
                                                                      var selectedTime  = stringToTimeOfDay(entry["closing"]);
                                                                      final TimeOfDay? picked = await pickTimeAppleDialog(context, selectedTime);
                                                                      setState((){
                                                                        if(picked != null){
                                                                          schedule[index]["closing"] = "${picked.hour}:${picked.minute}";
                                                                          changeProvider = true;
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Text(entry["closing"] ,style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),)),
                                                                ]
                                                              ),
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                    if (index != days.length - 1)
                                                      Divider(color: tertiaryColor.withOpacity(0.3)),
                                                    
                                                  ],
                                                );
                                              }),
                                              
                                            ),
                                            if(changeProvider) Align(
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async{
                                                  await supabase.from("restaurants")
                                                  .update({"schedule" : schedule})
                                                  .eq("id", ref.watch(userDocumentsProvider)['id'])
                                                  .whenComplete((){
                                                    ref.read(userDocumentsProvider.notifier).state["schedule"] = schedule;
                                                    print(ref.watch(userDocumentsProvider)["schedule"]);
                                                    Navigator.of(context).pop();
                                                  });
                                                  

                                                },
                                                child: Text("Save")
                                              ),
                                            )
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
                      child: Text("Edit"),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16.sp),
                  width: 100.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.sp)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(ref.watch(userDocumentsProvider)["schedule"].length, (index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${ref.watch(userDocumentsProvider)["schedule"][index]["day"]}"),
                              ref.watch(userDocumentsProvider)["schedule"][index].containsKey("opening")? RichText(
                                text: TextSpan(
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                        text:
                                            "${ref.watch(userDocumentsProvider)["schedule"][index]["opening"]}"),
                                    TextSpan(text: " • "),
                                    TextSpan(
                                        text:
                                            "${ref.watch(userDocumentsProvider)["schedule"][index]["closing"]}"),
                                  ],
                                ),
                              ) : Text("Day Off", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.red)),
                            ],
                          ),
                          if (index !=
                              ref.watch(userDocumentsProvider)["schedule"].length - 1)
                            Divider(color: tertiaryColor.withOpacity(0.3)),
                        ],
                      );
                    }),
                  ),
                ),
                // LOCATION SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Location",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Edit"),
                    )
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
                    location: LatLng(ref.watch(userDocumentsProvider)["lat"], ref.watch(userDocumentsProvider)["lng"]),
                  )
                ),
                // GALLERY SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Gallery",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Edit"),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8.sp),
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.sp),
                    boxShadow: [dropShadow],
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      children: [
                        Container(
                          width: 100.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.sp),
                            boxShadow: [dropShadow],
                            image: DecorationImage(
                              image: NetworkImage(
                                ref.watch(userDocumentsProvider)['urls'][0]
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(
                              ref.watch(userDocumentsProvider)['urls'].length - 1,
                              (index) {
                            return Container(
                              width: 16.h - 8.sp * 5,
                              height: 16.h - 8.sp * 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.sp),
                                boxShadow: [dropShadow],
                                image: DecorationImage(
                                  image: NetworkImage(
                                    ref.watch(userDocumentsProvider)['urls']
                                        [index + 1],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
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
