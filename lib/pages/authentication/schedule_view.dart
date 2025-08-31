import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/location_selection.dart';
import 'package:dinney_restaurant/services/functions/string_handlings.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/widgets/circles_indicator.dart';
import 'package:dinney_restaurant/widgets/timer_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleView extends ConsumerWidget {
  ScheduleView({super.key});
  final supabase = Supabase.instance.client;
  final ScheduleProvider = StateProvider<List<Map<String, dynamic>>>((ref)=> [
    {"day": "Sunday"},
    {"day": "Monday"},
    {"day": "Tuesday"},
    {"day": "Wednesday"},
    {"day": "Thursday"},
    {"day": "Friday"},
    {"day": "Saturday"}
  ]);
List<String> days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  late List<Map<String, dynamic>> schedule;
  bool changeProvider = false;
  Map<String, dynamic>? getScheduleForDay(List<Map<String, dynamic>> schedule, String dayName) {
    try {
      return schedule.firstWhere((item) => item["day"] == dayName,);
    } catch (e) {
      return null;
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Map<String, dynamic>> schedule = List.from(ref.watch(ScheduleProvider));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            spacing: 16.sp,
            children: [
              ThreeDotsIndicator(),
              Text(
                S.of(context).schedule,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              StatefulBuilder(
              builder: (context, setState) {
                return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16.sp,
                          children: [
                            Column(crossAxisAlignment:CrossAxisAlignment.start,
                              children: List.generate(days.length, (index) {
                                var entry = getScheduleForDay(schedule, days[index]);
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
                                  ref.read(savingLoadingButton.notifier).state = true;
                                  await supabase.from("restaurants")
                                  .update({"schedule" : schedule})
                                  .eq("uid", supabase.auth.currentUser!.id)
                                  .whenComplete((){
                                    ref.read(savingLoadingButton.notifier).state = false;
                                    ref.read(signUpProvider.notifier).state = 4;
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> LocationSelection()));
                                  });
                                  

                                },
                                child: Text(S.of(context).save)
                              ),
                            )
                          ],
                        );
              },
            )
            ],
          ),
        )
      ),
    );
  }
}