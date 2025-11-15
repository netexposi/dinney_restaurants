import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/pages/settings/feedback_view.dart';
import 'package:dinney_restaurant/pages/settings/history_view.dart';
import 'package:dinney_restaurant/pages/settings/profile_view.dart';
import 'package:dinney_restaurant/services/functions/community_operations.dart';
import 'package:dinney_restaurant/services/functions/system_functions.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:dinney_restaurant/widgets/privacy_policy_content.dart';
import 'package:dinney_restaurant/widgets/settings_element.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends ConsumerWidget{
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LanguageList = [
        S.of(context).english, 
        S.of(context).arabic,
        S.of(context).french
        ];
    List<MaterialColor> colors = [Colors.blue, Colors.deepPurple, Colors.deepOrange, Colors.amber, Colors.teal, Colors.lightGreen, Colors.blueGrey, Colors.grey];
    return WillPopScope(
      onWillPop: () async{
        if(ref.watch(savingLoadingButton)){
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settings),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.sp,
                children: [
                  //SECTION Profile and edit profile
                  Column(
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileView()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${ref.watch(userDocumentsProvider)["name"]}", style: Theme.of(context).textTheme.headlineMedium,),
                                Text("${S.of(context).id}: ${ref.watch(userDocumentsProvider)["id"]}", style: Theme.of(context).textTheme.bodySmall,),
                              ],
                            ),
                            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: tertiaryColor)
                          ],
                        ),
                      ),
                      SizedBox(height: 16.sp,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ref.watch(userDocumentsProvider)['active']? Text(S.of(context).emergency_stop, style: Theme.of(context).textTheme.bodyLarge,):
                            Text(S.of(context).status_off, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.red),),
                            ref.watch(userDocumentsProvider)['active']? InkWell(
                              borderRadius: BorderRadius.circular(12.sp),
                              onTap: (){
                                showDialog(
                                  barrierDismissible: false,
                                  context: context, builder: (context){
                                  return AlertDialog(
                                    actionsAlignment: MainAxisAlignment.center,
                                    content: Text(S.of(context).emergency_stop_message, textAlign: TextAlign.center,),
                                    actions: [
                                      ref.watch(savingLoadingButton)? LoadingSpinner() : Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            }, 
                                            child: Text(S.of(context).no, style: TextStyle(color: Colors.black),)
                                          ),
                                          TextButton(
                                            onPressed: () async{
                                              ref.read(savingLoadingButton.notifier).state = true;
                                              //idea cancel first the reservations
                                              final supabase = Supabase.instance.client;
                                              final response = await supabase.from("orders").select("client_fcm").match({
                                                "restaurant_id" : ref.watch(userDocumentsProvider)['id'],
                                                "completed" : false,
                                              });
                                              if(response.isNotEmpty){
                                                for (var element in response) {
                                                  await sendNotification(
                                                    ref.watch(userDocumentsProvider)['name'], 
                                                    "Due to an unexpected emergency at the restaurant, your order has been canceled. We sincerely apologize for the inconvenience.", 
                                                    element['client_fcm']
                                                  );
                                                }
                                                await supabase.from("orders").delete().match(
                                                  {
                                                    "restaurant_id" : ref.watch(userDocumentsProvider)['id'],
                                                    "completed" : false,
                                                  }
                                                ).whenComplete(() async{
                                                  await supabase.from("restaurants").update({
                                                    "active" : false
                                                  }).eq("id", ref.watch(userDocumentsProvider)['id']).whenComplete((){
                                                    if(context.mounted){
                                                      if(Navigator.of(context).canPop()){
                                                        Navigator.of(context).pop();
                                                      }
                                                    }
                                                  });
                                                });
                                              }else{
                                                await supabase.from("restaurants").update({
                                                  "active" : false
                                                }).eq("id", ref.watch(userDocumentsProvider)['id']).whenComplete((){
                                                  if(context.mounted){
                                                    if(Navigator.of(context).canPop()){
                                                      Navigator.of(context).pop();
                                                    }
                                                  }
                                                });
                                              }
                                            }, 
                                            child: Text(S.of(context).yes_cancel, style: TextStyle(color: Colors.red),)
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                });
                                ref.read(savingLoadingButton.notifier).state = false;
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 22.sp, vertical: 12.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  color: Colors.red.withOpacity(0.7)
                                ),
                                child: Text(S.of(context).stop, style: TextStyle(color: Colors.white),),
                              ),
                            ) : InkWell(
                              borderRadius: BorderRadius.circular(12.sp),
                              onTap: () async{
                                ref.watch(savingLoadingButton.notifier).state = true;
                                await supabase.from("restaurants").update({
                                  "active" : true
                                }).eq("id", ref.watch(userDocumentsProvider)['id']).whenComplete((){
                                  ref.watch(savingLoadingButton.notifier).state = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 22.sp, vertical: 12.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  color: Colors.green.withOpacity(0.7)
                                ),
                                child: Text(S.of(context).reactivate, style: TextStyle(color: Colors.white),),
                              ),
                            )
                          ],
                        ),
                      Divider(color: Colors.white,),
                    ],
                  ),
                  //SECTION Account
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.sp,
                    children: [
                      Text(S.of(context).record, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                      SizedBox(height: 16.sp,),
                      //SettingsElement(settingColor: colors[0], onClicked: () {  }, icon: HugeIcons.strokeRoundedAccountSetting01, title: 'Account Information',),
                      SettingsElement(settingColor: colors[1], onClicked: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryView()));
                      }, icon: HugeIcons.strokeRoundedHourglass, title: S.of(context).order_history,),
                    ],
                  ),
                  //SECTION App
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.sp,
                    children: [
                      Text(S.of(context).app, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                      SizedBox(height: 16.sp,),
                      SettingsElement(settingColor: colors[2], onClicked: () {
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: Text(S.of(context).select_your_language, style: Theme.of(context).textTheme.headlineSmall,),
                            content: SizedBox(
                              width: 80.w,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: LanguageList.length,
                                itemBuilder: (context, index){
                                  return ListTile(
                                    onTap: (){
                                      setLanguage(index);
                                      ref.read(languageStateProvider.notifier).state = index;
                                      Navigator.pop(context);
                                    },
                                    leading: Text(flagsList[index], style: TextStyle(fontSize: 24.sp),),
                                    title: Text(LanguageList[index], style: Theme.of(context).textTheme.bodyLarge,),
                                    trailing: ref.watch(languageStateProvider) == index ? Icon(Icons.check, color: secondaryColor,) : null,
                                  );
                                }),
                            ),
                          );
                        });
                      }, icon: HugeIcons.strokeRoundedLanguageCircle, title: S.of(context).langauge, subtitle: LanguageList[ref.watch(languageStateProvider)],),
                    ],
                  ),
                  //SECTION Support
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.sp,
                    children: [
                      Text(S.of(context).support, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                      SizedBox(height: 16.sp,),
                      // SettingsElement(settingColor: colors[3], onClicked: () {
                        
                      // }, icon: HugeIcons.strokeRoundedHelpCircle, title: S.of(context).help_center,),
                      SettingsElement(settingColor: colors[4], onClicked: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> FeedbackView()));
                      }, icon: HugeIcons.strokeRoundedMail01, title: S.of(context).contact_us,),
                      SettingsElement(settingColor: colors[5], onClicked: () {  }, icon: HugeIcons.strokeRoundedAsteroid02, title: S.of(context).rate_our_app,),
                    ],
                  ),
                  SettingsElement(
                      settingColor: colors[4],
                      onClicked: () {
                        showDialog(context: context, 
                        barrierColor: Colors.black.withOpacity(0.2),
                          builder: (context){
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(16.sp),
                            child: BlurryContainer(
                              blurSigma: 4,
                              padding: 16.sp,
                              width: 100.w,
                              borderRadius: BorderRadius.circular(24.sp),
                              child: Column(
                                children: [
                                  Text("${S.of(context).desgined_developed} ${S.of(context).by}", style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
                                  SizedBox(height: 16.sp,),
                                  //section akram
                                  InkWell(
                                    onTap: () async{
                                      final Uri url = Uri.parse('https://hebbadj.me');
                                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                          throw Exception('Could not launch $url');
                                        }
                                    },
                                    borderRadius: BorderRadius.circular(24.sp),
                                    child: Row(
                                      spacing: 16.sp,
                                      children: [
                                        CircleAvatar(
                                          radius: 24.sp,
                                          backgroundImage: AssetImage("assets/images/akram.jpeg"),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(S.of(context).akram_benhebbadj, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
                                            Text("akram.forgh@gmail.com", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.sp,),
                                  //section akram
                                  InkWell(
                                    onTap: () async{
                                      final Uri url = Uri.parse('https://www.linkedin.com/in/mohamed-islam-boussahel-a92929237?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app');
                                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                          throw Exception('Could not launch $url');
                                        }
                                    },
                                    borderRadius: BorderRadius.circular(24.sp),
                                    child: Row(
                                      spacing: 16.sp,
                                      children: [
                                        CircleAvatar(
                                          radius: 24.sp,
                                          backgroundImage: AssetImage("assets/images/islam.jpg"),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(S.of(context).islam_boussahel, style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
                                            Text("boussahelmohmedislam05\n@gmail.com", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ),
                          );
                        });
                      },
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      title: S.of(context).development_team,
                    ),
                  //SECTION Legal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.sp,
                    children: [
                      Text(S.of(context).legal, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                      SizedBox(height: 16.sp,),
                      SettingsElement(settingColor: colors[6], onClicked: () {
                        showAdaptiveDialog(context: context, builder: (context){
                          return Dialog(
                            backgroundColor: Colors.white,
                            insetPadding: EdgeInsets.all(16.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.sp),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 70.h,
                                  child: PrivacyPolicyContent(languageIndex: ref.watch(languageStateProvider),)
                                ),
                              ],
                            ),
                          );
                        });
                      }, icon: HugeIcons.strokeRoundedShield01, title: S.of(context).privacy_policy,),
                      //SettingsElement(settingColor: colors[7], onClicked: () {  }, icon: HugeIcons.strokeRoundedLegalDocument01, title: S.of(context).terms_of_service,),
                    ],
                  ),
                  SettingsElement(settingColor: Colors.red, onClicked: () {
                    supabase.auth.signOut().whenComplete((){
                      AppNavigation.navRouter.go("/");
                    });
                  }, icon: HugeIcons.strokeRoundedLogout03, title: S.of(context).sign_out,),
                ],
              ),
            ),
            )
          ),
      ),
    );
  }

}