import 'dart:collection';
import 'dart:io';

import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/services/functions/array_handlings.dart';
import 'package:dinney_restaurant/services/functions/storage_functions.dart';
import 'package:dinney_restaurant/services/functions/string_handlings.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: must_be_immutable
class UserProfileView extends ConsumerWidget {

  UserProfileView({super.key});
  final displayMapsKey = GlobalKey<MapsViewState>();
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
                            bool loading = false;
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
                                              "Edit information",
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
                                                  onPressed: () async{
                                                    setState((){loading = true;});
                                                    if (emailController.text !=
                                                        ref.watch(userDocumentsProvider)["email"] && 
                                                        nameController.text !=ref.watch(userDocumentsProvider)["name"]
                                                        ) {
                                                      // TODO change email and name at the same time
                                                      try{
                                                        await supabase.auth.updateUser(UserAttributes(email: emailController.text))
                                                        .whenComplete(() async{
                                                          await supabase.from("restaurants")
                                                          .update({
                                                            "email" : emailController.text,
                                                            "name" : nameController.text
                                                          })
                                                          .eq("id", ref.watch(userDocumentsProvider)["id"])
                                                          .whenComplete(() async{
                                                            final newUserData =  await supabase.from("restaurants")
                                                              .select()
                                                              .eq("id", ref.watch(userDocumentsProvider)["id"])
                                                              .single();
                                                              if(newUserData.isNotEmpty){
                                                                ref.read(userDocumentsProvider.notifier).state = newUserData;
                                                              }
                                                              setState((){loading = false;});
                                                            Navigator.of(context).pop();
                                                            ScaffoldMessenger.of(context).showSnackBar(SuccessMessage("Information changed successfully. Check your mail!"));
                                                          });
                                                        });
                                                      }catch(e) {
                                                        Navigator.of(context).pop();
                                                        ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An error occured: {$e}"));
                                                      }
                                                    }else if(emailController.text !=
                                                        ref.watch(userDocumentsProvider)["email"]){
                                                        try{
                                                          await supabase.auth.updateUser(UserAttributes(email: emailController.text))
                                                          .whenComplete(() async{
                                                            await supabase.from("restaurants")
                                                            .update({
                                                              "email" : emailController.text,
                                                            })
                                                            .eq("id", ref.watch(userDocumentsProvider)["id"])
                                                            .whenComplete(() async{
                                                              final newUserData =  await supabase.from("restaurants")
                                                              .select()
                                                              .eq("id", ref.watch(userDocumentsProvider)["id"])
                                                              .single();
                                                              if(newUserData.isNotEmpty){
                                                                ref.read(userDocumentsProvider.notifier).state = newUserData;
                                                              }
                                                              setState((){loading = false;});
                                                              Navigator.of(context).pop();
                                                              ScaffoldMessenger.of(context).showSnackBar(SuccessMessage("Email changed successfully. Check your mail!"));
                                                            });
                                                          });
                                                        }catch(e) {
                                                          Navigator.of(context).pop();
                                                          ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An error occured: {$e}"));
                                                        }
                                                      }else if(nameController.text !=ref.watch(userDocumentsProvider)["name"]){
                                                        try{
                                                          await supabase.from("restaurants")
                                                            .update({
                                                              "name" : nameController.text,
                                                            })
                                                            .eq("id", ref.watch(userDocumentsProvider)["id"])
                                                            .whenComplete(() async{ 
                                                              final newUserData =  await supabase.from("restaurants")
                                                              .select()
                                                              .eq("id", ref.watch(userDocumentsProvider)["id"])
                                                              .single();
                                                              if(newUserData.isNotEmpty){
                                                                ref.read(userDocumentsProvider.notifier).state = newUserData;
                                                              }
                                                              setState((){loading = false;});
                                                              Navigator.of(context).pop();
                                                              ScaffoldMessenger.of(context).showSnackBar(SuccessMessage("Name changed successfully."));
                                                            });
                                                        }catch(e) {
                                                          Navigator.of(context).pop();
                                                          ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An error occured: {$e}"));
                                                        }
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
                              "Saturday"
                            ];
                            List<Map<String, dynamic>> schedule = List.from(
                              ref.read(userDocumentsProvider)["schedule"] ?? []);
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
                                            Text("Edit schedule",style: Theme.of(context).textTheme.headlineSmall,),
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
                                                    ref.read(userDocumentsProvider.notifier).state = {
                                                      ...ref.read(userDocumentsProvider),
                                                      "schedule": List<Map<String, dynamic>>.from(schedule),
                                                    };
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
                      onPressed: () {
                        showDialog(context: context, builder: (context){
                          return StatefulBuilder(builder: (context, setState){
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Edit location", style: Theme.of(context).textTheme.headlineSmall,),
                                        SizedBox(
                                          width: 100.w,
                                          height: 50.h,
                                          child: MapsView(
                                            key: mapKey,
                                            location: LatLng(ref.watch(userDocumentsProvider)["lat"], ref.watch(userDocumentsProvider)["lng"]),
                                            borderRadius: 24.sp,
                                            myLocationButton: true,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: ElevatedButton(
                                            onPressed: () async{
                                              LatLng? markerPosition = mapKey.currentState?.currentMarker?.position;
                                              if(markerPosition != null){
                                                await supabase.from("restaurants")
                                                .update(
                                                  {
                                                    "lat" : markerPosition.latitude,
                                                    "lng" : markerPosition.longitude
                                                  }).eq("id", ref.watch(userDocumentsProvider)["id"])
                                                  .whenComplete((){
                                                    ref.read(userDocumentsProvider.notifier).state = {
                                                      ...ref.read(userDocumentsProvider),
                                                      "lat": markerPosition.latitude,
                                                      "lng": markerPosition.longitude
                                                    };
                                                    displayMapsKey.currentState!.setMarker(markerPosition);
                                                    Navigator.of(context).pop();
                                                  });
                                              }
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
                          });
                        });
                      },
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
                    key: displayMapsKey,
                    location: LatLng(ref.watch(userDocumentsProvider)["lat"], ref.watch(userDocumentsProvider)["lng"]),
                    borderRadius: 24.sp,
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
                      onPressed: () {
                        bool loading = false;
                        final imagesProvider = StateProvider<List<File?>>((ref) => [null, null, null, null]);
                        showDialog(context: context, builder: (context){
                          bool changeProvider = false;
                          var images = ref.watch(imagesProvider);
                          final indexes = [];
                          return StatefulBuilder(builder: (context, setState){
                            Future<void> _pickImage({required WidgetRef ref,required int index,}) async {
                              changeProvider = true;
                              final picker = ImagePicker();
                              final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                indexes.add(index);
                                // final currentImages = ref.read(imagesProvider);
                                // final updatedImages = List<File?>.from(currentImages);
                                // updatedImages[index] = File(picked.path);
                                //ref.read(imagesProvider.notifier).state = updatedImages;
                                ref.read(imagesProvider.notifier).state[index] = File(picked.path);
                                images = ref.watch(imagesProvider);
                                //images.add(File(picked.path));
                                setState((){});
                              }
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 16.sp,
                                      children: [
                                        Text("Edit gallery", style: Theme.of(context).textTheme.headlineSmall,),
                                        Text("Edit Primary Image", style: Theme.of(context).textTheme.bodyMedium,),
                                        InkWell(
                                          onTap: () => _pickImage(ref: ref, index: 0),
                                          borderRadius: BorderRadius.circular(24.sp),
                                          child: Container(
                                            width: 100.w,
                                            height: 45.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(24.sp),
                                              color: Colors.grey[300],
                                              image: images[0] != null
                                                  ? DecorationImage(
                                                      image: FileImage(images[0]!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : DecorationImage(
                                                      image: NetworkImage(ref.watch(userDocumentsProvider)["urls"][0]),
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            child: images[0] == null && ref.watch(userDocumentsProvider)["urls"][0] == null
                                                ? Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, color: tertiaryColor),
                                                      Text("Edit Image", style: Theme.of(context).textTheme.bodySmall,)
                                                    ],
                                                  )
                                                : null,
                                          ),
                                        ),
                                        Text("Edit Album Images", style: Theme.of(context).textTheme.bodyMedium,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: List.generate(3, (i) {
                                            final index = i + 1; // 1, 2, 3
                                            return InkWell(
                                              onTap: () => _pickImage(ref: ref, index: index),
                                              borderRadius: BorderRadius.circular(24.sp),
                                              child: Container(
                                                width: 28.w,
                                                height: 28.w,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(24.sp),
                                                  color: Colors.grey[300],
                                                  image: images[index] != null
                                                      ? DecorationImage(
                                                          image: FileImage(images[index]!),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : DecorationImage(
                                                      image: NetworkImage(ref.watch(userDocumentsProvider)["urls"][index]),
                                                      fit: BoxFit.cover,
                                                    ),
                                                ),
                                                child: images[index] == null && ref.watch(userDocumentsProvider)["urls"][index] == null
                                                    ? Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, color: tertiaryColor),
                                                          Text("Edit", style: Theme.of(context).textTheme.bodySmall),
                                                        ],
                                                      )
                                                    : null,
                                              ),
                                            );
                                          }),
                                        ),
                                        if(changeProvider) Align(
                                          alignment: Alignment.center,
                                          child: !loading? ElevatedButton(
                                            onPressed: () async{
                                              setState((){loading = true;});
                                              List<dynamic> urls = ref.watch(userDocumentsProvider)["urls"] ;
                                              for (var index in indexes){
                                                var url = await uploadImageToSupabase(images[index]!);
                                                if(ref.watch(userDocumentsProvider)["urls"][index] != null){
                                                  //IDEA this means it's just changing image
                                                  urls[index] = url!;
                                                }else {
                                                  //idea when adding a new one
                                                  urls.add(url!);
                                                }
                                                //urls[index]
                                              }
                                              try{
                                                await supabase.from('restaurants')
                                                .update({'urls': urls})
                                                .eq('id', ref.watch(userDocumentsProvider)["id"])
                                                .whenComplete((){
                                                  ref.read(userDocumentsProvider.notifier).state = {
                                                    ...ref.watch(userDocumentsProvider),
                                                    "urls": urls
                                                  };
                                                  setState((){loading = false;});
                                                  Navigator.of(context).pop();
                                                });
                                                
                                              } catch (e){
                                                ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Internarl error, try again!"));
                                              }
                                                
                                            }, 
                                            child: Text("Save")
                                            ) : LoadingSpinner()
                                            ,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        });
                      },
                      child: Text("Edit"),
                    )
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
                                ref.watch(userDocumentsProvider)['urls'][0]
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
                            return Container(
                              width: 16.h - 8.sp * 5.5,
                              height: 16.h - 8.sp * 5.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.sp),
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
                      Text("Delete Account", style: Theme.of(context).textTheme.headlineSmall,),
                      TextButton(
                        onPressed: () {
                          bool loading = false;
                          showDialog(context: context, builder: (context){
                            return StatefulBuilder(builder: (context, setState){
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(16.sp),
                                actionsAlignment: MainAxisAlignment.center,
                                content: Text("Are you sure you want to delete\nthe restaurant account?",
                                textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,),
                                actions: [
                                  !loading? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(onPressed: () async{
                                        //FIXME you need to revise this code
                                        setState((){loading = true;});
                                        try{
                                          await supabase.from("restaurants")
                                          .delete()
                                          .eq("id", ref.watch(userDocumentsProvider)["id"])
                                          .whenComplete(() async{
                                            supabase.auth.admin.deleteUser(ref.watch(userDocumentsProvider)["uid"]);
                                            AppNavigation.navRouter.go("/");
                                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SuccessMessage("Account deleted successfully"));
                                          });
                                        }catch (e){
                                          setState((){loading = false;});
                                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(ErrorMessage("An error occured: {$e}"));
                                          Navigator.of(context).pop();
                                        }
                                      }, child: Text("Yes, i want", style: TextStyle(color: Colors.red),)),
                                      TextButton(onPressed: (){
                                        Navigator.of(context).pop();
                                      }, child: Text("Cancel", style: TextStyle(color: tertiaryColor),)),
                                    ],
                                  ) : LoadingSpinner()
                                ],
                              );
                            });
                          });
                        }, 
                        child: Text("Delete", style: TextStyle(color: Colors.red),)
                      )
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
