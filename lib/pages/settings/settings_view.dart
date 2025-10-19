import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/pages/settings/feedback_view.dart';
import 'package:dinney_restaurant/pages/settings/history_view.dart';
import 'package:dinney_restaurant/pages/settings/profile_view.dart';
import 'package:dinney_restaurant/services/functions/system_functions.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/settings_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';

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
    return Scaffold(
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
                //SECTION Legal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.sp,
                  children: [
                    Text(S.of(context).legal, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                    SizedBox(height: 16.sp,),
                    SettingsElement(settingColor: colors[6], onClicked: () {  }, icon: HugeIcons.strokeRoundedShield01, title: S.of(context).privacy_policy,),
                    SettingsElement(settingColor: colors[7], onClicked: () {  }, icon: HugeIcons.strokeRoundedLegalDocument01, title: S.of(context).terms_of_service,),
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
    );
  }

}